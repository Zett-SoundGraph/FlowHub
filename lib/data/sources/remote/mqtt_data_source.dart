import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/core/constants/flowhub_identity.dart';
import 'package:flowhub/core/constants/local_subnet_resolver.dart';
import 'package:flowhub/core/constants/network.dart';
import 'package:flowhub/core/utils/log.dart';
import 'package:flowhub/data/models/order/kiosk_order_raw.dart';
import 'package:flowhub/domain/entities/index.dart';
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
  /// (beta/pickuptable/calibration_status) — was KdsSocketDataSource's
  /// WebSocket-only calibrationStatusStream until the pickup table's
  /// calibration screen moved onto MQTT too.
  Stream<String> get calibrationStatusStream;
  Map<String, DateTime> get fleetLastSeen;
  Future<void> connect();
  /// Leader-only: tells the pickup table to enter calibration mode
  /// (beta/flowhub/pickuptable, type=START_CALIBRATION).
  Future<void> publishStartCalibration(double height);
  /// Leader-only: tells the pickup table a drink is ready for pickup
  /// (beta/flowhub/pickuptable, type=ORDER_READY).
  Future<void> publishOrderReady(Order order, SubItem subItem);
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
  /// TEMPORARY — backs the floating WLED bench-test toggle on the main KDS
  /// screen (see WledTestToggle). Publishes a plain "ON"/"OFF" string (not
  /// JSON — WLED's own MQTT integration understands this directly once its
  /// Device Topic is set to match). Delete once WLED testing is done.
  Future<void> publishWledPower(bool on);
  /// TEMPORARY — see [publishWledPower]. Publishes [body] as JSON to the
  /// Device Topic's `/api` sub-topic, per WLED's own MQTT convention for its
  /// JSON API (e.g. `{"on":true,"bri":255,"seg":[{"col":[[r,g,b]]}]}` to set
  /// a solid color, or `{"on":false}` to turn off).
  Future<void> publishWledApi(Map<String, dynamic> body);
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
  // only) — was KdsSocketDataSource.calibrationStatusStream over WebSocket.
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
  // TEMPORARY — WLED bench-test topics, see publishWledPower's doc comment.
  static const _topicWledPower = 'beta/flowhub/wled/power';
  // WLED's own convention: JSON API commands go to Device Topic + "/api".
  static const _topicWledApi = '$_topicWledPower/api';
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

  @override
  Stream<bool> get connectionStream => _connectionController.stream;

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

    _client = client;
    // Heartbeat is universal (every device, either role). Everything else is
    // role-specific: only the leader talks to the kiosk/scanners/pickup
    // table directly and needs to hear from followers; only a follower
    // needs to hear the leader's state broadcast.
    client.subscribe(_topicHeartbeatWildcard, MqttQos.atMostOnce);
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

        final Map<String, dynamic> json = jsonDecode(payload);

        if (event.topic == _topicQrOrder) {
          final raw = json['raw']?.toString() ?? '';
          Log.d(_tag, 'beta/qr/order received: $raw');
          if (raw.isNotEmpty) _barcodeScanController.add(raw);
          continue;
        }

        if (event.topic == _topicQrComplete) {
          final raw = json['raw']?.toString() ?? '';
          Log.d(_tag, 'beta/qr/complete received: $raw');
          if (raw.isNotEmpty) _qrCompleteController.add(raw);
          continue;
        }

        if (event.topic == _topicPickupComplete) {
          final orderNo = json['orderNo']?.toString() ?? '';
          Log.d(_tag, 'beta/pickuptable/pickup received: $orderNo');
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
          _kioskOrderController.add(raw.toEntity());
          continue;
        }

        if (event.topic == _topicCalibrationStatus) {
          final type = json['type']?.toString() ?? '';
          Log.d(_tag, '$_topicCalibrationStatus received: $type');
          if (type.isNotEmpty) _calibrationStatusController.add(type);
          continue;
        }

        if (event.topic == _topicLeaderUpdate) {
          final update = LeaderUpdateMessage.fromJson(json);
          Log.d(_tag, 'beta/flowhub/leader/update received: version=${update.version}');
          _leaderUpdateController.add(update);
          continue;
        }

        if (event.topic.startsWith(_topicFollowerUpdatePrefix) &&
            event.topic.endsWith(_topicFollowerUpdateSuffix)) {
          final request = FollowerSyncRequest.fromJson(json);
          Log.d(_tag, '${event.topic} received: sync=${request.sync}');
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
  Future<void> publishStartCalibration(double height) async {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      Log.w(_tag, 'publishStartCalibration skipped — not connected');
      return;
    }
    final payload = jsonEncode({
      'type': 'START_CALIBRATION',
      'height': height,
      'timestamp': DateTime.now().toIso8601String(),
    });
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(payload);
    client.publishMessage(
        _topicPickuptableCommand, MqttQos.atLeastOnce, builder.payload!);
  }

  /// Leader-only: tells the pickup table a drink is ready, so it can put up
  /// a guide circle for the customer to place their cup on — this is what
  /// the KDS "Call" step's completeCooking() triggers. Same JSON shape as
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

  /// TEMPORARY — see the interface doc comment. Retained so a freshly
  /// (re)booted WLED unit picks up the last commanded state immediately
  /// instead of waiting for the next button press.
  @override
  Future<void> publishWledPower(bool on) async {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      Log.w(_tag, 'publishWledPower skipped — not connected');
      return;
    }
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(on ? 'ON' : 'OFF');
    client.publishMessage(
      _topicWledPower,
      MqttQos.atLeastOnce,
      builder.payload!,
      retain: true,
    );
    Log.d(_tag, 'Published $_topicWledPower (${on ? 'ON' : 'OFF'})');
  }

  /// TEMPORARY — see the interface doc comment. Not retained — each call is
  /// a one-off command (set this color / turn off now), not standing state
  /// worth replaying to a freshly (re)connected WLED unit.
  @override
  Future<void> publishWledApi(Map<String, dynamic> body) async {
    final client = _client;
    if (client == null ||
        client.connectionStatus?.state != MqttConnectionState.connected) {
      Log.w(_tag, 'publishWledApi skipped — not connected');
      return;
    }
    final payload = jsonEncode(body);
    final builder = MqttClientPayloadBuilder();
    builder.addUTF8String(payload);
    client.publishMessage(
      _topicWledApi,
      MqttQos.atLeastOnce,
      builder.payload!,
      retain: false,
    );
    Log.d(_tag, 'Published $_topicWledApi ($payload)');
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
    Log.d(_tag, 'Disposed');
  }
}
