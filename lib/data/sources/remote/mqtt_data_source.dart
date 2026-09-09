import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:kds/core/constants/network.dart';
import 'package:kds/core/utils/log.dart';
import 'package:kds/domain/repositories/order_repository.dart' show FleetHeartbeatEvent;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

abstract interface class IMqttDataSource {
  Stream<bool> get connectionStream;
  Stream<({String orderNo, String menuName})> get pickupCompleteStream;
  Stream<String> get barcodeScanStream;
  Stream<FleetHeartbeatEvent> get fleetHeartbeatStream;
  Map<String, DateTime> get fleetLastSeen;
  Future<void> connect();
  void dispose();
}

@Singleton(as: IMqttDataSource)
class MqttDataSource implements IMqttDataSource {
  static const _tag = 'MqttClient';
  static const _topicQrOrder = 'beta/qr/order';
  static const _topicPickupComplete = 'beta/pickuptable/pickup';
  static const _topicHeartbeatPrefix = 'beta/system/heartbeat/';
  static const _topicHeartbeatWildcard = '$_topicHeartbeatPrefix+';
  static const _topicHeartbeat =
      '$_topicHeartbeatPrefix${NetworkConstants.mqttDeviceId}';
  // Message Hub's online-timeout window sits between 6s (stable) and 9s
  // (flapping) — 5s keeps a safety margin under that threshold.
  static const _heartbeatInterval = Duration(seconds: 5);

  MqttServerClient? _client;
  Timer? _heartbeatTimer;

  /// Last-seen timestamp per deviceId, keyed by the heartbeat topic's device
  /// suffix. Seeded immediately from retained heartbeat messages on connect.
  final Map<String, DateTime> _fleetLastSeen = {};

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  final StreamController<({String orderNo, String menuName})>
      _pickupCompleteController =
      StreamController<({String orderNo, String menuName})>.broadcast();
  final StreamController<String> _barcodeScanController =
      StreamController<String>.broadcast();
  final StreamController<FleetHeartbeatEvent> _fleetHeartbeatController =
      StreamController<FleetHeartbeatEvent>.broadcast();

  @override
  Stream<bool> get connectionStream => _connectionController.stream;

  @override
  Stream<({String orderNo, String menuName})> get pickupCompleteStream =>
      _pickupCompleteController.stream;

  @override
  Stream<String> get barcodeScanStream => _barcodeScanController.stream;

  @override
  Stream<FleetHeartbeatEvent> get fleetHeartbeatStream =>
      _fleetHeartbeatController.stream;

  @override
  Map<String, DateTime> get fleetLastSeen => Map.unmodifiable(_fleetLastSeen);

  /// Connects to the local MQTT broker and subscribes to order-related topics.
  /// 1. No-op if already connected; disconnect any stale client otherwise
  ///    (guards against duplicate live connections under the same client ID)
  /// 2. Configure the client with credentials and a client identifier
  /// 3. Connect and verify the resulting connection state
  /// 4. Subscribe to beta/qr/order, beta/pickuptable/pickup, and the
  ///    beta/system/heartbeat/+ wildcard (fleet monitoring)
  /// 5. Start the periodic heartbeat publish
  @override
  Future<void> connect() async {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      Log.d(_tag, 'connect() called while already connected — ignoring');
      return;
    }
    _client?.disconnect();

    final client = MqttServerClient(
      NetworkConstants.mqttBrokerHost,
      NetworkConstants.mqttDeviceId,
    );
    client.port = NetworkConstants.mqttBrokerPort;
    client.keepAlivePeriod = 30;
    client.autoReconnect = true;
    // Temporarily enabled for flapping diagnosis — surfaces protocol-level
    // detail (CONNACK codes, PING timing, broker-initiated disconnects) that
    // our own callbacks alone don't capture. Turn back off once diagnosed.
    client.logging(on: true);
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
      Log.e(_tag, 'Connect error: $e');
      client.disconnect();
      return;
    }

    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      Log.e(_tag, 'Connection failed: ${client.connectionStatus}');
      client.disconnect();
      return;
    }

    _client = client;
    client.subscribe(_topicQrOrder, MqttQos.atLeastOnce);
    client.subscribe(_topicPickupComplete, MqttQos.atLeastOnce);
    client.subscribe(_topicHeartbeatWildcard, MqttQos.atMostOnce);
    client.updates!.listen(_handleMessage);

    _startHeartbeat();
  }

  /// Parses incoming publish messages and routes them by topic.
  /// 1. Decode the payload bytes into a UTF-8 JSON string
  /// 2. beta/qr/order → extract the 'raw' scan string → [_barcodeScanController]
  /// 3. beta/pickuptable/pickup → extract orderNo → [_pickupCompleteController]
  /// 4. beta/system/heartbeat/{deviceId} → record last-seen time → [_fleetHeartbeatController]
  void _handleMessage(List<MqttReceivedMessage<MqttMessage>> events) {
    for (final event in events) {
      try {
        final message = event.payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);
        final Map<String, dynamic> json = jsonDecode(payload);

        if (event.topic == _topicQrOrder) {
          final raw = json['raw']?.toString() ?? '';
          Log.d(_tag, 'beta/qr/order received: $raw');
          if (raw.isNotEmpty) _barcodeScanController.add(raw);
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
        Log.e(_tag, 'Message handling error: $e');
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
    builder.addString(jsonEncode({
      'status': 'online',
      'deviceName': NetworkConstants.mqttDeviceName,
      'deviceId': NetworkConstants.mqttDeviceId,
    }));
    client.publishMessage(
      _topicHeartbeat,
      MqttQos.atMostOnce,
      builder.payload!,
      retain: true,
    );
  }

  /// Tears down this data source.
  /// 1. Stop the heartbeat timer
  /// 2. Disconnect from the broker
  /// 3. Close all exposed stream controllers
  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _client?.disconnect();
    _connectionController.close();
    _pickupCompleteController.close();
    _barcodeScanController.close();
    _fleetHeartbeatController.close();
    Log.d(_tag, 'Disposed');
  }
}
