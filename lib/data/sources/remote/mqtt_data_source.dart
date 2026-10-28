import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/core/constants/flowhub_identity.dart';
import 'package:flowhub/core/constants/local_subnet_resolver.dart';
import 'package:flowhub/core/constants/network.dart';
import 'package:flowhub/core/utils/log.dart';
import 'package:flowhub/core/utils/mqtt_order_audit_logger.dart';
import 'package:flowhub/data/models/order/kiosk_order_raw.dart';
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/enums/index.dart';
import 'package:flowhub/domain/repositories/order_repository.dart'
    show FleetHeartbeatEvent;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

abstract interface class IMqttDataSource {
  Stream<bool> get connectionStream;
  Stream<({String orderNo, String menuName})> get pickupCompleteStream;
  Stream<String> get barcodeScanStream;
  /// Raw `beta/qr/complete` scan — the same pipe-delimited label format as
  /// [barcodeScanStream], just scanned at the "this drink is done" station
  /// instead of the "start brewing" one.
  Stream<String> get qrCompleteStream;
  Stream<FleetHeartbeatEvent> get fleetHeartbeatStream;
  Stream<Order> get kioskOrderStream;
  /// Follower-side: the leader's full-state broadcast.
  Stream<LeaderUpdateMessage> get leaderUpdateStream;
  /// Leader-side: an action request from any follower.
  Stream<FollowerSyncRequest> get followerSyncRequestStream;
  /// Leader-side: VALIDATION_MODE / CALIB_EXIT from the pickup table
  /// (beta/pickuptable/calibration_status) — was FlowHubSocketDataSource's
  /// WebSocket-only calibrationStatusStream until the pickup table's
  /// calibration screen moved onto MQTT too.
  Stream<String> get calibrationStatusStream;
  Map<String, DateTime> get fleetLastSeen;
  Future<void> connect();
  /// Leader-only: tells the pickup table to enter calibration mode
  /// (beta/flowhub/pickuptable, type=START_CALIBRATION). displayModel/
  /// edgeMarginMm let the pickup table relay the table's physical geometry
  /// on to the ToF sensor's own control channel (see PickupTableRepository.
  /// publishControlCommand's set_table_geometry) before calibration starts.
  /// displayWidthMm/displayHeightMm are only passed for a display outside
  /// the 430A/500A/550A presets, entered as raw mm on the calibration
  /// dialog's "직접입력" (custom) option instead of picked from the list.
  Future<void> publishStartCalibration(
    double height, {
    required String displayModel,
    required double edgeMarginMm,
    double? displayWidthMm,
    double? displayHeightMm,
  });
  /// Leader-only: tells the pickup table a drink is ready for pickup
  /// (beta/flowhub/pickuptable, type=ORDER_READY).
  Future<void> publishOrderReady(Order order, SubItem subItem);
  /// Leader-only: tells the pickup table to switch its guide/placed/thank-
  /// you rendering to this theme (beta/flowhub/pickuptable,
  /// type=SET_PICKUP_TABLE_THEME) — see FlowHub's Pickup Table Theme
  /// screen. Not retained — a fresh pickup table boot always starts back
  /// at the original unthemed rendering until FlowHub sends this again.
  Future<void> publishPickupTableTheme(PickupTableThemeSelection selection);
  /// Leader-only: tells the pickup table to drop [publishPickupTableTheme]'s
  /// override and go back to its original, unthemed rendering (same
  /// topic/type, with `background` omitted — see pickup_table's MqttService
  /// for how it reads that as Reset).
  Future<void> publishPickupTableThemeReset();
  /// Leader-only: tells the pickup table to generate its fixed batch of
  /// synthetic test orders (5×single-cup + one each of 2/3/5-cup) so every
  /// themed color/shape can be checked without waiting for real orders —
  /// see pickup_table's PickupTableCubit._createTestOrders' doc comment
  /// for exactly what gets created. Same topic/type-field convention as
  /// [publishPickupTableTheme]. Not retained.
  Future<void> publishCreateTestOrders();
  /// Leader-only: tells the pickup table to remove every order
  /// [publishCreateTestOrders] created (and nothing else). Not retained.
  Future<void> publishClearTestOrders();
  /// Leader-only: broadcasts the current full state to all followers.
  Future<void> publishLeaderUpdate(LeaderUpdateMessage message);
  /// Follower-only: asks the leader to perform an action.
  Future<void> publishFollowerSync(FollowerSyncRequest request);
  /// Leader-only: broadcasts the lightweight order summary display boards need.
  Future<void> publishBoardUpdate(BoardUpdateMessage message);
  /// Leader-only: broadcasts the order/waiting counts the kiosk mirrors.
  Future<void> publishKioskUpdate(KioskUpdateMessage message);
  /// Leader-only: broadcasts a Caye 0x30 Fault Report.
  Future<void> publishCayeFault(CayeFaultMessage message);
  /// Leader-only: broadcasts a Caye 0x31 Query Running Status response.
  Future<void> publishCayeStatus(CayeStatusMessage message);
  /// Leader-only: broadcasts a Caye 0x12 Rinsing Event Report.
  Future<void> publishCayeRinsing(CayeEventMessage message);
  /// Leader-only: broadcasts a Caye 0x03 Cleaning Event Report.
  Future<void> publishCayeCleaning(CayeEventMessage message);
  /// Publishes [body] as JSON to [device]'s own `<topicKey>/api` sub-topic,
  /// per WLED's own MQTT convention for its JSON API (e.g.
  /// `{"on":true,"bri":255,"seg":[{"col":[[r,g,b]]}]}` to set a solid color,
  /// or `{"on":false}` to turn off). One physical WLED unit per [WledDevice]
  /// value — see its own doc comment for the topic-naming convention.
  Future<void> publishWledApi(WledDevice device, Map<String, dynamic> body);
  /// Each physical WLED unit's own presence topic — WLED's native MQTT
  /// integration publishes "online" to `<Device Topic>/status` on connect
  /// (retained) and sets that same topic as its Last Will ("offline",
  /// retained) so the broker announces it automatically on an ungraceful
  /// disconnect. Distinct from [connectionStream] (this FlowHub device's own
  /// broker connection) the same way [nudofOnlineStream] is distinct from it
  /// — a WLED unit can be powered off/unreachable while FlowHub itself is
  /// perfectly connected to the broker.
  Stream<({WledDevice device, bool online})> get wledOnlineStream;
  /// Snapshot of each WLED unit's last known online state — same reasoning
  /// as [isNudofOnline] for why a snapshot getter exists alongside the
  /// stream (a fresh listener otherwise only sees FUTURE transitions).
  Map<WledDevice, bool> get wledOnlineByDevice;
  /// Nudof dispenser's Shelly Plug M Gen3 — raw `beta/nudof/status/switch:0`
  /// payload (Gen2+ Switch component status: id/source/output/apower/
  /// voltage/current/…), used to both show live power draw and (as a
  /// test/logging feature — see NudofControlCubit) detect dispensing
  /// start/end from its change pattern.
  Stream<Map<String, dynamic>> get nudofSwitchStatusStream;
  /// Turns the Nudof dispenser's Shelly plug on/off via its Gen2+ RPC
  /// channel (`beta/nudof/rpc`, method Switch.Set) — a one-off command, not
  /// standing state, so the resulting output change is only ever observed
  /// back via [nudofSwitchStatusStream] once the plug reports it.
  Future<void> publishNudofSwitchSet(bool on);
  /// The Shelly plug's own reachability — its Gen2+ `<topic_prefix>/online`
  /// topic (retained "true"/"false", backed by an MQTT Last Will so it flips
  /// to false automatically on an ungraceful disconnect). Distinct from
  /// [connectionStream]/[isConnected] above, which only say whether THIS
  /// FlowHub device is connected to the broker — the broker and this device
  /// can both be fine while the plug itself has lost power/WiFi.
  Stream<bool> get nudofOnlineStream;
  /// Snapshot of the plug's last known online state — see [isConnected]'s
  /// doc comment for why a snapshot getter exists alongside the stream (a
  /// fresh listener otherwise only sees FUTURE transitions, missing the
  /// retained value already delivered at subscribe time).
  bool get isNudofOnline;
  void dispose();
}

@Singleton(as: IMqttDataSource)
class MqttDataSource implements IMqttDataSource {
  static const _tag = 'MqttClient';
  static const _topicQrOrder = 'beta/qr/order';
  static const _topicQrComplete = 'beta/qr/complete';
  static const _topicPickupComplete = 'beta/pickuptable/pickup';
  static const _topicKioskOrder = 'beta/kiosk/order';
  // ORDER_READY / START_CALIBRATION going OUT to the pickup table (leader
  // only) share one topic, distinguished by the `type` field — mirrors how
  // the old WebSocket relay dispatched both over the same connection. See
  // PiMqttManager (ToF-백업파일/include/PiMqtt_Man.h) for the analogous
  // Raspberry Pi side of this migration.
  static const _topicPickuptableCommand = 'beta/flowhub/pickuptable';
  // VALIDATION_MODE / CALIB_EXIT coming IN from the pickup table (leader
  // only) — was FlowHubSocketDataSource.calibrationStatusStream over WebSocket.
  static const _topicCalibrationStatus = 'beta/pickuptable/calibration_status';
  static const _topicHeartbeatPrefix = 'beta/system/heartbeat/';
  static const _topicHeartbeatWildcard = '$_topicHeartbeatPrefix+';
  static const _topicLeaderUpdate = 'beta/flowhub/leader/update';
  // Deliberately separate from _topicLeaderUpdate — see the doc comment on
  // BoardUpdateMessage for why boards get their own topic/payload shape
  // instead of sharing the follower-sync one.
  static const _topicBoardUpdate = 'beta/flowhub/board/update';
  // Its own topic too — the kiosk only needs the two bottom-bar counts, an
  // even smaller/differently-shaped need than boards get.
  static const _topicKioskUpdate = 'beta/flowhub/kiosk/update';
  // Caye machine diagnostics — one topic per content type rather than one
  // shared topic, since fault/status are standing state (retained) while
  // rinsing/cleaning are one-off events (not retained); see the discussion
  // that settled on `beta/flowhub/caye/{content}` over encoding a receiver
  // name into the path.
  static const _topicCayeFault = 'beta/flowhub/caye/fault';
  static const _topicCayeStatus = 'beta/flowhub/caye/status';
  static const _topicCayeRinsing = 'beta/flowhub/caye/rinsing';
  static const _topicCayeCleaning = 'beta/flowhub/caye/cleaning';
  // One MQTT "Device Topic" per physical WLED unit — see WledDevice's own
  // doc comment. WLED's own convention: JSON API commands go to that
  // Device Topic + "/api".
  static String _topicWledBaseFor(WledDevice device) =>
      'beta/flowhub/wled/${device.topicKey}';
  static String _topicWledApiFor(WledDevice device) =>
      '${_topicWledBaseFor(device)}/api';
  static String _topicWledStatusFor(WledDevice device) =>
      '${_topicWledBaseFor(device)}/status';
  // Nudof dispenser's Shelly Plug M Gen3 — MQTT-native device (unlike Caye,
  // which FlowHub bridges from a raw TCP socket), so it gets a plain
  // `beta/<device>` prefix rather than `beta/flowhub/<device>` — see the
  // topic-prefix discussion that settled on this distinction.
  static const _topicNudofStatusSwitch = 'beta/nudof/status/switch:0';
  static const _topicNudofRpc = 'beta/nudof/rpc';
  static const _topicNudofOnline = 'beta/nudof/online';
  static const _topicFollowerUpdatePrefix = 'beta/flowhub/follower/';
  static const _topicFollowerUpdateSuffix = '/update';
  static const _topicFollowerUpdateWildcard =
      '$_topicFollowerUpdatePrefix+$_topicFollowerUpdateSuffix';
  static String get _topicFollowerUpdateOwn =>
      '$_topicFollowerUpdatePrefix${NetworkConstants.mqttDeviceId}$_topicFollowerUpdateSuffix';
  // No longer a compile-time const — mqttDeviceId is resolved at runtime
  // from this device's own IP (see FlowHubIdentity), not hardcoded per build.
  static String get _topicHeartbeat =>
      '$_topicHeartbeatPrefix${NetworkConstants.mqttDeviceId}';
  // Message Hub's online-timeout window sits between 6s (stable) and 9s
  // (flapping) — 5s keeps a safety margin under that threshold.
  static const _heartbeatInterval = Duration(seconds: 5);

  MqttServerClient? _client;
  Timer? _heartbeatTimer;
  Timer? _retryTimer;
  bool _isNudofOnline = false;
  final Map<WledDevice, bool> _wledOnlineByDevice = {
    for (final d in WledDevice.values) d: false,
  };
  int _nudofRpcId = 0;
  // autoReconnect only takes over once a client has connected successfully
  // at least once — it never fires for a connect() call that fails outright
  // (e.g. broker/network not up yet), so a failed FIRST attempt would
  // otherwise never retry on its own. Most visible at boot: a race against
  // this device's own network stack coming up can lose once and then sit
  // disconnected forever without this.
  static const _retryInterval = Duration(seconds: 5);

  /// Last-seen timestamp per deviceId, keyed by the heartbeat topic's device
  /// suffix. Seeded immediately from retained heartbeat messages on connect.
  final Map<String, DateTime> _fleetLastSeen = {};

  // beta/kiosk/order is subscribed at-least-once, so the same event can be
  // redelivered — eventId is the spec's own dedup key. Bounded (rather than
  // an ever-growing Set) since this runs for the length of an exhibition day;
  // redelivery happens within seconds, so a few hundred recent ids is ample.
  static const _maxTrackedKioskEventIds = 500;
  final LinkedHashSet<String> _processedKioskEventIds = LinkedHashSet<String>();

  bool _isDuplicateKioskEvent(String eventId) {
    if (eventId.isEmpty) return false;
    if (!_processedKioskEventIds.add(eventId)) return true;
    if (_processedKioskEventIds.length > _maxTrackedKioskEventIds) {
      _processedKioskEventIds.remove(_processedKioskEventIds.first);
    }
    return false;
  }

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  final StreamController<({String orderNo, String menuName})>
      _pickupCompleteController =
      StreamController<({String orderNo, String menuName})>.broadcast();
  final StreamController<String> _barcodeScanController =
      StreamController<String>.broadcast();
  final StreamController<String> _qrCompleteController =
      StreamController<String>.broadcast();
  final StreamController<FleetHeartbeatEvent> _fleetHeartbeatController =
      StreamController<FleetHeartbeatEvent>.broadcast();
  final StreamController<Order> _kioskOrderController =
      StreamController<Order>.broadcast();
  final StreamController<LeaderUpdateMessage> _leaderUpdateController =
      StreamController<LeaderUpdateMessage>.broadcast();
  final StreamController<FollowerSyncRequest> _followerSyncRequestController =
      StreamController<FollowerSyncRequest>.broadcast();
  final StreamController<String> _calibrationStatusController =
      StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _nudofSwitchStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<bool> _nudofOnlineController =
      StreamController<bool>.broadcast();
  final StreamController<({WledDevice device, bool online})>
      _wledOnlineController =
      StreamController<({WledDevice device, bool online})>.broadcast();

  @override
  Stream<bool> get connectionStream => _connectionController.stream;

  @override
  Stream<Map<String, dynamic>> get nudofSwitchStatusStream =>
      _nudofSwitchStatusController.stream;

  @override
  Stream<bool> get nudofOnlineStream => _nudofOnlineController.stream;

  @override
  bool get isNudofOnline => _isNudofOnline;

  @override
  Stream<({WledDevice device, bool online})> get wledOnlineStream =>
      _wledOnlineController.stream;

  @override
  Map<WledDevice, bool> get wledOnlineByDevice =>
      Map.unmodifiable(_wledOnlineByDevice);

  @override
  Stream<({String orderNo, String menuName})> get pickupCompleteStream =>
      _pickupCompleteController.stream;

  @override
  Stream<String> get barcodeScanStream => _barcodeScanController.stream;

  @override
  Stream<String> get qrCompleteStream => _qrCompleteController.stream;

  @override
  Stream<FleetHeartbeatEvent> get fleetHeartbeatStream =>
      _fleetHeartbeatController.stream;

  @override
  Stream<Order> get kioskOrderStream => _kioskOrderController.stream;

  @override
  Stream<LeaderUpdateMessage> get leaderUpdateStream => _leaderUpdateController.stream;

  @override
  Stream<FollowerSyncRequest> get followerSyncRequestStream =>
      _followerSyncRequestController.stream;

  @override
  Stream<String> get calibrationStatusStream =>
      _calibrationStatusController.stream;

  @override
  Map<String, DateTime> get fleetLastSeen => Map.unmodifiable(_fleetLastSeen);

  /// Connects to the local MQTT broker and subscribes to role-appropriate
  /// topics.
  /// 1. No-op if already connected; disconnect any stale client otherwise
  ///    (guards against duplicate live connections under the same client ID)
  /// 2. Configure the client with credentials and a client identifier
  /// 3. Connect and verify the resulting connection state
  /// 4. Subscribe to beta/system/heartbeat/+ (both roles), plus
  ///    beta/qr/order, beta/pickuptable/pickup, beta/kiosk/order, and the
  ///    follower-update wildcard if leader — or just beta/flowhub/leader/
  ///    update if follower (see [FlowHubIdentity])
  /// 5. Start the periodic heartbeat publish
  @override
  Future<void> connect() async {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      Log.d(_tag, 'connect() called while already connected — ignoring');
      return;
    }
    _retryTimer?.cancel();
    _client?.disconnect();

    // Waits for this device's own subnet to be confirmed before ever
    // dialing out — unlike Caye's IP (threaded through some genuinely
    // synchronous call sites), connect() is already async end to end, so
    // there's no reason to race a possibly-wrong fallback address the way
    // NetworkConstants.cayeMachineIp still does. A brand-new site (whose
    // subnet doesn't match the currently-deployed-site fallback) would
    // otherwise always waste a doomed first attempt before self-correcting.
    await LocalSubnetResolver.ready;

    final client = MqttServerClient(
      NetworkConstants.mqttBrokerHost,
      NetworkConstants.mqttDeviceId,
    );
    client.port = NetworkConstants.mqttBrokerPort;
    // 15s — comfortably above the 5s heartbeat interval, but short enough
    // that a dead connection gets noticed (and auto-reconnect kicks in)
    // quickly instead of taking up to 30s.
    client.keepAlivePeriod = 15;
    client.autoReconnect = true;
    client.logging(on: false);
    client.onConnected = () {
      Log.d(_tag,
          'Connected to broker (${NetworkConstants.mqttBrokerHost}:${NetworkConstants.mqttBrokerPort})');
      _connectionController.add(true);
    };
    client.onDisconnected = () {
      Log.d(_tag, 'Disconnected from broker');
      _connectionController.add(false);
    };
    client.onAutoReconnect = () => Log.d(_tag, 'Auto-reconnecting to broker');
    client.onAutoReconnected = () => Log.d(_tag, 'Auto-reconnect sequence completed');

    // Assigned here — BEFORE client.connect() below — not after it succeeds.
    // mqtt_client invokes onConnected() (which fires _connectionController,
    // waking up anything awaiting connectionStream) synchronously as part of
    // its own internal handshake, i.e. WHILE still inside client.connect()'s
    // Future, which completes before this function would otherwise reach the
    // old post-await assignment point. A caller using _awaitConnected (e.g.
    // publishWledApi) could already be scheduled to run by then, see _client
    // still null, and crash on `_client!` — confirmed directly: two
    // "Null check operator used on a null value" crashes in publishWledApi
    // right as "Connected to broker" logged, from the two guidance-light
    // commands now fired at leader startup. Assigning the reference up front
    // closes that window; every check elsewhere already keys off
    // `connectionStatus?.state == connected`, not just non-null, so a
    // not-yet-connected (or later failed) client sitting in [_client] during
    // the handshake doesn't change any of that logic.
    _client = client;

    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(NetworkConstants.mqttDeviceId)
        .authenticateAs(
          NetworkConstants.mqttUsername,
          NetworkConstants.mqttPassword,
        );
    // Persistent session (no .startClean()) — testing whether Message Hub's
    // flapping detection is tied to clean-session reconnects looking like a
    // brand-new client each time.

    try {
      await client.connect();
    } catch (e) {
      Log.e(_tag, 'Connect error: $e — retrying in ${_retryInterval.inSeconds}s');
      client.disconnect();
      _scheduleRetry();
      return;
    }

    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      Log.e(_tag,
          'Connection failed: ${client.connectionStatus} — retrying in ${_retryInterval.inSeconds}s');
      client.disconnect();
      _scheduleRetry();
      return;
    }

    // Heartbeat is universal (every device, either role). Everything else is
    // role-specific: only the leader talks to the kiosk/scanners/pickup
    // table directly and needs to hear from followers; only a follower
    // needs to hear the leader's state broadcast.
    client.subscribe(_topicHeartbeatWildcard, MqttQos.atMostOnce);
    // Universal like the heartbeat — the Nudof plug is its own independent
    // MQTT-native device, not gated by leader/follower role the way Caye's
    // TCP-socket ownership is (see NudofRepository's doc comment).
    client.subscribe(_topicNudofStatusSwitch, MqttQos.atMostOnce);
    client.subscribe(_topicNudofOnline, MqttQos.atMostOnce);
    // Universal like the Nudof plug's online topic above — each WLED unit's
    // presence is broker-broadcast and visible to every FlowHub instance
    // directly, independent of leader/follower role.
    for (final device in WledDevice.values) {
      client.subscribe(_topicWledStatusFor(device), MqttQos.atMostOnce);
    }
    if (FlowHubIdentity.role == FlowHubRole.leader) {
      client.subscribe(_topicQrOrder, MqttQos.atLeastOnce);
      client.subscribe(_topicQrComplete, MqttQos.atLeastOnce);
      client.subscribe(_topicPickupComplete, MqttQos.atLeastOnce);
      client.subscribe(_topicKioskOrder, MqttQos.atLeastOnce);
      client.subscribe(_topicCalibrationStatus, MqttQos.atLeastOnce);
      client.subscribe(_topicFollowerUpdateWildcard, MqttQos.atLeastOnce);
    } else {
      client.subscribe(_topicLeaderUpdate, MqttQos.atLeastOnce);
    }
    client.updates!.listen(_handleMessage);

    _startHeartbeat();
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(_retryInterval, () => unawaited(connect()));
  }

  /// Parses incoming publish messages and routes them by topic.
  /// 1. Decode the payload bytes into a UTF-8 JSON string
  /// 2. beta/qr/order → extract the 'raw' scan string → [_barcodeScanController]
  /// 3. beta/pickuptable/pickup → extract orderNo → [_pickupCompleteController]
  /// 4. beta/kiosk/order → parse into a real [Order] → [_kioskOrderController]
  /// 5. beta/flowhub/leader/update → [_leaderUpdateController] (follower-side)
  /// 6. beta/flowhub/follower/{id}/update → [_followerSyncRequestController] (leader-side)
  /// 7. beta/system/heartbeat/{deviceId} → record last-seen time → [_fleetHeartbeatController]
  void _handleMessage(List<MqttReceivedMessage<MqttMessage>> events) {
    for (final event in events) {
      try {
        final message = event.payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);

        // An empty payload on a retained topic is the standard MQTT way to
        // CLEAR that retained message (some brokers/clients send this on
        // disconnect or an explicit clear) — not a malformed message, so it
        // shouldn't hit the catch-all error log below.
        if (payload.trim().isEmpty) {
          final rawBytes = message.payload.message;
          if (rawBytes.isEmpty) {
            Log.d(_tag, '${event.topic}: empty payload (0 raw bytes) — treating as retained-clear, ignoring');
          } else {
            // Non-zero bytes that still failed UTF-8 decoding — not a real
            // retained-clear, almost certainly a bad-encoding bug on
            // whichever device PUBLISHED this (see the addString vs.
            // addUTF8String issue this session fixed on our own publishes).
            // Base64-dumped so the exact bytes can be handed to that
            // device's team for comparison against what they meant to send.
            // TEMPORARY — remove once the kiosk-side encoding bug is fixed.
            Log.w(
              _tag,
              '${event.topic}: ${rawBytes.length} raw bytes failed UTF-8 decode '
              '(NOT a retained-clear) — base64: ${base64Encode(rawBytes)}',
            );
          }
          continue;
        }

        // beta/nudof/online's payload is a bare "true"/"false" (Shelly's own
        // convention, not one of ours) — not a JSON object, so it must be
        // handled before the generic jsonDecode-to-Map cast below, which
        // would otherwise throw on it (jsonDecode("true") is a valid JSON
        // bool literal, but not a Map).
        if (event.topic == _topicNudofOnline) {
          final online = payload.trim().toLowerCase() == 'true';
          Log.d(_tag, '$_topicNudofOnline received: $online');
          _isNudofOnline = online;
          _nudofOnlineController.add(online);
          continue;
        }

        // Same reasoning as _topicNudofOnline above — WLED's own `.../status`
        // presence topic is a bare "online"/"offline" string (its own
        // convention), not JSON.
        WledDevice? wledDevice;
        for (final d in WledDevice.values) {
          if (event.topic == _topicWledStatusFor(d)) {
            wledDevice = d;
            break;
          }
        }
        if (wledDevice != null) {
          final online = payload.trim().toLowerCase() == 'online';
          Log.d(_tag, '${event.topic} received: $online');
          _wledOnlineByDevice[wledDevice] = online;
          _wledOnlineController.add((device: wledDevice, online: online));
          continue;
        }

        final Map<String, dynamic> json = jsonDecode(payload);

        if (event.topic == _topicQrOrder) {
          final raw = json['raw']?.toString() ?? '';
          Log.d(_tag, 'beta/qr/order received: $raw');
          unawaited(MqttOrderAuditLogger.log(
            topic: event.topic,
            direction: 'in',
            orderNo: raw.isEmpty ? null : raw,
            payload: json,
          ));
          if (raw.isNotEmpty) _barcodeScanController.add(raw);
          continue;
        }

        if (event.topic == _topicQrComplete) {
          final raw = json['raw']?.toString() ?? '';
          Log.d(_tag, 'beta/qr/complete received: $raw');
          unawaited(MqttOrderAuditLogger.log(
            topic: event.topic,
            direction: 'in',
            orderNo: raw.isEmpty ? null : raw,
            payload: json,
          ));
          if (raw.isNotEmpty) _qrCompleteController.add(raw);
          continue;
        }

        if (event.topic == _topicPickupComplete) {
          final orderNo = json['orderNo']?.toString() ?? '';
          Log.d(_tag, 'beta/pickuptable/pickup received: $orderNo');
          unawaited(MqttOrderAuditLogger.log(
            topic: event.topic,
            direction: 'in',
            orderNo: orderNo.isEmpty ? null : orderNo,
            payload: json,
          ));
          if (orderNo.isNotEmpty) {
            _pickupCompleteController.add((orderNo: orderNo, menuName: ''));
          }
          continue;
        }

        if (event.topic == _topicKioskOrder) {
          // Raw payload first, unconditionally — this is the one topic real
          // kiosk hardware will publish to for the first time during
          // upcoming order tests, so if the schema doesn't quite match
          // what's expected, the exact bytes received are what's needed to
          // diagnose it (the parsed-field logs below may be empty/wrong).
          Log.i(_tag, 'beta/kiosk/order raw payload: $payload');
          final raw = KioskOrderRaw.fromJson(json);
          if (_isDuplicateKioskEvent(raw.eventId)) {
            Log.d(_tag, 'beta/kiosk/order duplicate eventId=${raw.eventId} — ignoring');
            continue;
          }
          Log.i(
            _tag,
            'beta/kiosk/order parsed: orderNo=${raw.orderNo} eventId=${raw.eventId} '
            'language=${raw.language} totalCups=${raw.totalCups} orderTime=${raw.orderTime} '
            'items=${raw.items.length}',
          );
          for (final item in raw.items) {
            final options = item.options
                .map((o) => '${o.optionNo}x${o.quantity}')
                .join(', ');
            Log.i(
              _tag,
              '  seq=${item.seq} skuNo=${item.skuNo} menuName=${item.menuName} '
              'temp=${item.temp} size=${item.size} options=[$options]',
            );
          }
          if (raw.orderNo.isEmpty || raw.items.isEmpty) {
            Log.w(
              _tag,
              'beta/kiosk/order rejected — orderNo or items empty (check the raw payload above against the schema)',
            );
            continue;
          }
          unawaited(MqttOrderAuditLogger.log(
            topic: event.topic,
            direction: 'in',
            orderNo: raw.orderNo,
            payload: json,
          ));
          _kioskOrderController.add(raw.toEntity());
          continue;
        }

        if (event.topic == _topicCalibrationStatus) {
          final type = json['type']?.toString() ?? '';
          Log.d(_tag, '$_topicCalibrationStatus received: $type');
          if (type.isNotEmpty) _calibrationStatusController.add(type);
          continue;
        }

        if (event.topic == _topicNudofStatusSwitch) {
          _nudofSwitchStatusController.add(json);
          continue;
        }

        if (event.topic == _topicLeaderUpdate) {
          final update = LeaderUpdateMessage.fromJson(json);
          Log.d(_tag, 'beta/flowhub/leader/update received: version=${update.version}');
          unawaited(MqttOrderAuditLogger.log(
            topic: event.topic,
            direction: 'in',
            // Full-fleet state sync, not one order — the order numbers it
            // carries are recorded in `payload` itself, not this field.
            orderNo: null,
            payload: json,
          ));
          _leaderUpdateController.add(update);
          continue;
        }

        if (event.topic.startsWith(_topicFollowerUpdatePrefix) &&
            event.topic.endsWith(_topicFollowerUpdateSuffix)) {
          final request = FollowerSyncRequest.fromJson(json);
          Log.d(_tag, '${event.topic} received: sync=${request.sync}');
          unawaited(MqttOrderAuditLogger.log(
            topic: event.topic,
            direction: 'in',
            orderNo: null,
            payload: json,
          ));
          _followerSyncRequestController.add(request);
          continue;
        }

        if (event.topic.startsWith(_topicHeartbeatPrefix)) {
          final deviceId = json['deviceId']?.toString() ??
              event.topic.substring(_topicHeartbeatPrefix.length);
          final timestamp = DateTime.now();
          _fleetLastSeen[deviceId] = timestamp;
          _fleetHeartbeatController.add((
            deviceId: deviceId,
            timestamp: timestamp,
            topic: event.topic,
            payload: payload,
            qos: message.header?.qos.toString() ?? 'unknown',
            retain: message.header?.retain ?? false,
          ));
          continue;
        }
      } catch (e) {
        Log.e(_tag, 'Message handling error on ${event.topic}: $e');
      }
    }
  }

  /// Starts publishing a recurring online heartbeat.
  /// 1. Cancel any previously running heartbeat timer
  /// 2. Publish immediately so the device appears online without delay
  /// 3. Schedule further publishes on [_heartbeatInterval]
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _publishHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) => _publishHeartbeat());
  }

  /// Publishes a single retained heartbeat message if the broker is connected.
  /// 1. Skip silently when there is no live connection
  /// 2. Build the {status, deviceName, deviceId} JSON payload
  /// 3. Publish to beta/system/heartbeat/{deviceId} with retain=true
  void _publishHeartbeat() {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }

    final builder = MqttClientPayloadBuilder();
    // addUTF8String, NOT addString — addString packs Dart's UTF-16 code
    // units as raw 1-or-2-byte values, which is NOT valid UTF-8 for any
    // character above code unit 255. It only looks fine for ASCII-only
    // payloads; the moment a value contains Korean text or an emoji, the
    // bytes it produces fail utf8.decode() on the receiving end.
    final payload = jsonEncode({
      'status': 'online',
      'deviceName': NetworkConstants.mqttDeviceName,
      'deviceId': NetworkConstants.mqttDeviceId,
    });
    builder.addUTF8String(payload);
    client.publishMessage(
      _topicHeartbeat,
      MqttQos.atMostOnce,
      builder.payload!,
      retain: true,
    );
  }

  /// Leader-only: tells the pickup table to enter calibration mode. Not
  /// retained — a one-off command, not standing state (a pickup table that
  /// reconnects later shouldn't replay a stale calibration trigger).
  @override
  Future<void> publishStartCalibration(
    double height, {
    required String displayModel,
    required double edgeMarginMm,
    double? displayWidthMm,
    double? displayHeightMm,
  }) async {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      Log.w(_tag, 'publishStartCalibration skipped — not connected');
      return;
    }
    final payload = jsonEncode({
      'type': 'START_CALIBRATION',
      'height': height,
      'displayModel': displayModel,
      'edgeMarginMm': edgeMarginMm,
      if (displayWidthMm != null) 'displayWidthMm': displayWidthMm,
      if (displayHeightMm != null) 'displayHeightMm': displayHeightMm,
      'timestamp': DateTime.now().toIso8601String(),
    });
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(payload);
    client.publishMessage(
        _topicPickuptableCommand, MqttQos.atLeastOnce, builder.payload!);
  }

  /// Leader-only: tells the pickup table a drink is ready, so it can put up
  /// a guide circle for the customer to place their cup on — this is what
  /// the FlowHub "Call" step's completeCooking() triggers. Same JSON shape as
  /// the old WebSocket sendOrderReady. Not retained, same reasoning as
  /// [publishStartCalibration].
  @override
  Future<void> publishOrderReady(Order order, SubItem subItem) async {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      Log.w(_tag, 'publishOrderReady skipped — not connected');
      return;
    }
    final payload = jsonEncode({
      'type': 'ORDER_READY',
      'orderNo': order.orderNo,
      'menuName': subItem.menuName,
      'drinkCount': order.drinkCount,
      'foodCount': order.foodCount,
      'bottleCount': order.bottleCount,
      'nickname': order.nickname ?? '',
      'totalRequired': order.totalCups,
      'lang': order.language,
      'timestamp': DateTime.now().toIso8601String(),
    });
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(payload);
    client.publishMessage(
        _topicPickuptableCommand, MqttQos.atLeastOnce, builder.payload!);
    Log.d(_tag, 'ORDER_READY published: ${order.orderNo} (${subItem.menuName})');
    unawaited(MqttOrderAuditLogger.log(
      topic: _topicPickuptableCommand,
      direction: 'out',
      orderNo: order.orderNo,
      payload: jsonDecode(payload),
    ));
  }

  /// Leader-only: see the interface doc comment. Not retained — same
  /// reasoning as [publishStartCalibration]/[publishOrderReady] above,
  /// which share this exact topic.
  @override
  Future<void> publishPickupTableTheme(PickupTableThemeSelection selection) async {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      Log.w(_tag, 'publishPickupTableTheme skipped — not connected');
      return;
    }
    final payload = jsonEncode({
      'type': 'SET_PICKUP_TABLE_THEME',
      ...selection.toJson(),
    });
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(payload);
    client.publishMessage(
        _topicPickuptableCommand, MqttQos.atLeastOnce, builder.payload!);
    Log.d(_tag, 'SET_PICKUP_TABLE_THEME published: $payload');
  }

  @override
  Future<void> publishPickupTableThemeReset() async {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      Log.w(_tag, 'publishPickupTableThemeReset skipped — not connected');
      return;
    }
    // `background` deliberately omitted — pickup_table's MqttService reads
    // a missing/empty `background` field as Reset (no `theme` name field
    // exists for this feature — see its SET_PICKUP_TABLE_THEME dispatch
    // branch).
    final payload = jsonEncode({'type': 'SET_PICKUP_TABLE_THEME'});
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(payload);
    client.publishMessage(
        _topicPickuptableCommand, MqttQos.atLeastOnce, builder.payload!);
    Log.d(_tag, 'SET_PICKUP_TABLE_THEME reset published');
  }

  @override
  Future<void> publishCreateTestOrders() async {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      Log.w(_tag, 'publishCreateTestOrders skipped — not connected');
      return;
    }
    final payload = jsonEncode({'type': 'CREATE_TEST_ORDERS'});
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(payload);
    client.publishMessage(
        _topicPickuptableCommand, MqttQos.atLeastOnce, builder.payload!);
    Log.d(_tag, 'CREATE_TEST_ORDERS published');
  }

  @override
  Future<void> publishClearTestOrders() async {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      Log.w(_tag, 'publishClearTestOrders skipped — not connected');
      return;
    }
    final payload = jsonEncode({'type': 'CLEAR_TEST_ORDERS'});
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(payload);
    client.publishMessage(
        _topicPickuptableCommand, MqttQos.atLeastOnce, builder.payload!);
    Log.d(_tag, 'CLEAR_TEST_ORDERS published');
  }

  /// Leader-only: broadcasts the full state snapshot to all followers +
  /// Flow Board. Retained so a follower that (re)connects late immediately
  /// gets the current state rather than waiting for the next change.
  @override
  Future<void> publishLeaderUpdate(LeaderUpdateMessage message) async {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      Log.w(_tag, 'publishLeaderUpdate skipped — not connected');
      return;
    }
    final payload = jsonEncode(message.toJson());
    final builder = MqttClientPayloadBuilder();
    // addUTF8String — see the comment in _publishHeartbeat. This payload
    // always contains non-ASCII bytes (e.g. the "⏳ Pending..." log seeded
    // in SubItem.initial()), so addString's raw UTF-16-packing here would
    // reliably corrupt every broadcast that includes at least one order.
    builder.addUTF8String(payload);
    client.publishMessage(
      _topicLeaderUpdate,
      MqttQos.atLeastOnce,
      builder.payload!,
      retain: true,
    );
    Log.d(
      _tag,
      'Published beta/flowhub/leader/update (version=${message.version}, '
      '${message.orders.length} orders, ${payload.length} bytes)',
    );
    unawaited(MqttOrderAuditLogger.log(
      topic: _topicLeaderUpdate,
      direction: 'out',
      // Full-fleet state sync, not one order — order numbers it carries are
      // in `payload` itself.
      orderNo: null,
      payload: jsonDecode(payload),
    ));
  }

  /// Leader-only: broadcasts the lightweight order summary for display
  /// boards. Retained so a board that (re)connects late immediately gets the
  /// current state rather than waiting for the next change.
  @override
  Future<void> publishBoardUpdate(BoardUpdateMessage message) async {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      Log.w(_tag, 'publishBoardUpdate skipped — not connected');
      return;
    }
    final payload = jsonEncode(message.toJson());
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(payload);
    client.publishMessage(
      _topicBoardUpdate,
      MqttQos.atLeastOnce,
      builder.payload!,
      retain: true,
    );
    Log.d(
      _tag,
      'Published beta/flowhub/board/update (version=${message.version}, '
      '${message.orders.length} orders, ${payload.length} bytes)',
    );
    unawaited(MqttOrderAuditLogger.log(
      topic: _topicBoardUpdate,
      direction: 'out',
      orderNo: null,
      payload: jsonDecode(payload),
    ));
  }

  /// Leader-only: broadcasts the order/waiting counts the kiosk mirrors in
  /// its own bottom bar. Retained so the kiosk gets the current counts
  /// immediately on (re)connect rather than waiting for the next change.
  @override
  Future<void> publishKioskUpdate(KioskUpdateMessage message) async {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      Log.w(_tag, 'publishKioskUpdate skipped — not connected');
      return;
    }
    final payload = jsonEncode(message.toJson());
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(payload);
    client.publishMessage(
      _topicKioskUpdate,
      MqttQos.atLeastOnce,
      builder.payload!,
      retain: true,
    );
    Log.d(
      _tag,
      'Published beta/flowhub/kiosk/update (version=${message.version}, '
      'orders=${message.orders}, waiting=${message.waiting})',
    );
    unawaited(MqttOrderAuditLogger.log(
      topic: _topicKioskUpdate,
      direction: 'out',
      orderNo: null,
      payload: jsonDecode(payload),
    ));
  }

  /// Leader-only: broadcasts a Caye 0x30 Fault Report. Retained so a
  /// subscriber that (re)connects late immediately sees the machine's
  /// current fault state rather than waiting for the next change.
  @override
  Future<void> publishCayeFault(CayeFaultMessage message) async {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      Log.w(_tag, 'publishCayeFault skipped — not connected');
      return;
    }
    final payload = jsonEncode(message.toJson());
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(payload);
    client.publishMessage(
      _topicCayeFault,
      MqttQos.atLeastOnce,
      builder.payload!,
      retain: true,
    );
    Log.d(_tag,
        'Published $_topicCayeFault (version=${message.version}, ${message.errors.length} errors)');
  }

  /// Leader-only: broadcasts a Caye 0x31 Query Running Status response.
  /// Retained so a subscriber that (re)connects late immediately sees the
  /// machine's current state rather than waiting for the next query.
  @override
  Future<void> publishCayeStatus(CayeStatusMessage message) async {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      Log.w(_tag, 'publishCayeStatus skipped — not connected');
      return;
    }
    final payload = jsonEncode(message.toJson());
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(payload);
    client.publishMessage(
      _topicCayeStatus,
      MqttQos.atLeastOnce,
      builder.payload!,
      retain: true,
    );
    Log.d(_tag, 'Published $_topicCayeStatus (version=${message.version})');
  }

  /// Leader-only: broadcasts a Caye 0x12 Rinsing Event Report. Not
  /// retained — this is a one-off event, not standing state.
  @override
  Future<void> publishCayeRinsing(CayeEventMessage message) async {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      Log.w(_tag, 'publishCayeRinsing skipped — not connected');
      return;
    }
    final payload = jsonEncode(message.toJson());
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(payload);
    client.publishMessage(
      _topicCayeRinsing,
      MqttQos.atLeastOnce,
      builder.payload!,
      retain: false,
    );
    Log.d(_tag,
        'Published $_topicCayeRinsing (version=${message.version}, status=${message.status})');
  }

  /// Leader-only: broadcasts a Caye 0x03 Cleaning Event Report. Not
  /// retained — this is a one-off event, not standing state.
  @override
  Future<void> publishCayeCleaning(CayeEventMessage message) async {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      Log.w(_tag, 'publishCayeCleaning skipped — not connected');
      return;
    }
    final payload = jsonEncode(message.toJson());
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(payload);
    client.publishMessage(
      _topicCayeCleaning,
      MqttQos.atLeastOnce,
      builder.payload!,
      retain: false,
    );
    Log.d(_tag,
        'Published $_topicCayeCleaning (version=${message.version}, status=${message.status})');
  }

  // How long a WLED guidance-light command waits for the broker connection
  // to come up before giving up. Exists because — unlike every other
  // publish method in this class, which only ever fires once the app has
  // been running a while — a WLED command can fire within the first second
  // or two after a fresh app launch (first label scan right after rebuild),
  // racing connect()'s own handshake. Silently dropping that first command
  // (the old behavior) left a WLED unit showing a stale color from whatever
  // it was last set to before the app restarted, which looked like a wrong
  // color rather than a connectivity hiccup. 5s mirrors _retryInterval.
  static const _wledConnectionWaitTimeout = Duration(seconds: 5);

  /// Resolves once the broker connection is up, or false if [timeout]
  /// elapses first. [connectionStream] only ever emits FUTURE transitions
  /// (no replay of the current state), so the already-connected case must
  /// be checked separately before falling back to waiting on the stream.
  Future<bool> _awaitConnected(Duration timeout) async {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      return true;
    }
    try {
      return await connectionStream.firstWhere((connected) => connected).timeout(timeout);
    } on TimeoutException {
      return false;
    }
  }

  /// See the interface doc comment. Not retained — each call is a one-off
  /// command (set this color / turn off now), not standing state worth
  /// replaying to a freshly (re)connected WLED unit.
  @override
  Future<void> publishWledApi(WledDevice device, Map<String, dynamic> body) async {
    if (!await _awaitConnected(_wledConnectionWaitTimeout)) {
      Log.w(_tag, 'publishWledApi skipped — not connected after waiting ${_wledConnectionWaitTimeout.inSeconds}s');
      return;
    }
    final client = _client!;
    final topic = _topicWledApiFor(device);
    final payload = jsonEncode(body);
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(payload);
    client.publishMessage(
      topic,
      MqttQos.atLeastOnce,
      builder.payload!,
      retain: false,
    );
    Log.d(_tag, 'Published $topic ($payload)');
  }

  /// Turns the Nudof dispenser's Shelly plug on/off. Per Shelly's Gen2+ RPC
  /// protocol, any JSON-RPC method (here Switch.Set) can be invoked by
  /// publishing the request frame to `<topic_prefix>/rpc` — see
  /// shelly-api-docs.shelly.cloud/gen2/Components/Switch#switchset. Not
  /// retained — a one-off command; the resulting state is observed back via
  /// [nudofSwitchStatusStream], not read from this call.
  @override
  Future<void> publishNudofSwitchSet(bool on) async {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      Log.w(_tag, 'publishNudofSwitchSet skipped — not connected');
      return;
    }
    final payload = jsonEncode({
      'id': ++_nudofRpcId,
      'method': 'Switch.Set',
      'params': {'id': 0, 'on': on},
    });
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(payload);
    client.publishMessage(
      _topicNudofRpc,
      MqttQos.atLeastOnce,
      builder.payload!,
      retain: false,
    );
    Log.d(_tag, 'Published $_topicNudofRpc (Switch.Set on=$on)');
  }

  /// Follower-only: publishes under this device's OWN follower id so the
  /// leader (subscribed to the `+` wildcard) knows who asked. Not retained —
  /// this is a one-off action request, not standing state.
  @override
  Future<void> publishFollowerSync(FollowerSyncRequest request) async {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      Log.w(_tag, 'publishFollowerSync skipped — not connected');
      return;
    }
    final payload = jsonEncode(request.toJson());
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(payload);
    client.publishMessage(
      _topicFollowerUpdateOwn,
      MqttQos.atLeastOnce,
      builder.payload!,
    );
    Log.d(
      _tag,
      'Published $_topicFollowerUpdateOwn (sync=${request.sync}, version=${request.version})',
    );
    unawaited(MqttOrderAuditLogger.log(
      topic: _topicFollowerUpdateOwn,
      direction: 'out',
      orderNo: null,
      payload: jsonDecode(payload),
    ));
  }

  /// Tears down this data source.
  /// 1. Stop the heartbeat timer
  /// 2. Disconnect from the broker
  /// 3. Close all exposed stream controllers
  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _retryTimer?.cancel();
    _client?.disconnect();
    _connectionController.close();
    _pickupCompleteController.close();
    _barcodeScanController.close();
    _qrCompleteController.close();
    _fleetHeartbeatController.close();
    _kioskOrderController.close();
    _leaderUpdateController.close();
    _followerSyncRequestController.close();
    _nudofSwitchStatusController.close();
    _nudofOnlineController.close();
    _wledOnlineController.close();
    Log.d(_tag, 'Disposed');
  }
}
