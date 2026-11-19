import 'dart:async';
import 'dart:convert';

import 'package:flowhub/core/constants/cloud_constants.dart';
import 'package:flowhub/core/utils/log.dart';
import 'package:flowhub/domain/entities/cloud/cloud_identity.dart';
import 'package:injectable/injectable.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// One message received from the cloud broker.
typedef CloudMqttMessage = ({String topic, Map<String, dynamic> json});

/// The single MQTT connection to the Flow Cloud broker.
///
/// Separate from [IMqttDataSource] (the store's local broker): different
/// broker, credentials and client ID, and a persistent QoS 1 session so the
/// broker queues cloud → Hub messages while the Hub is offline.
abstract interface class ICloudMqttDataSource {
  /// Connection state changes (`true` = connected).
  Stream<bool> get connectionStream;

  /// Current connection state.
  bool get isConnected;

  /// Every JSON message received on a subscribed topic.
  Stream<CloudMqttMessage> get messages;

  /// The identity of the current session; `null` before [connect].
  CloudIdentity? get identity;

  /// Fires each time [connect] switches to a new identity.
  Stream<CloudIdentity> get identityStream;

  /// Connects as [identity] (MQTT client ID = hub ID). Reconnects when the
  /// identity changed; a no-op when already connected as [identity].
  Future<void> connect(CloudIdentity identity);

  /// Subscribes to [topic] at QoS 1, now if connected and again on every
  /// reconnect.
  void subscribe(String topic);

  /// Publishes [payload] as JSON at QoS 1.
  /// Returns `false` when not connected (the caller keeps it for a resend).
  bool publish(String topic, Map<String, dynamic> payload);
}

@Singleton(as: ICloudMqttDataSource)
class CloudMqttDataSource implements ICloudMqttDataSource {
  static const String _tag = 'CloudMqtt';
  static const Duration _retryInterval = Duration(seconds: 10);
  static const int _keepAliveSeconds = 30;

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  final StreamController<CloudMqttMessage> _messageController =
      StreamController<CloudMqttMessage>.broadcast();
  final StreamController<CloudIdentity> _identityController =
      StreamController<CloudIdentity>.broadcast();
  final Set<String> _subscriptions = <String>{};
  CloudIdentity? _identity;

  MqttServerClient? _client;
  String? _clientId;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _updates;
  Timer? _retryTimer;

  @override
  Stream<bool> get connectionStream => _connectionController.stream;

  @override
  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  @override
  Stream<CloudMqttMessage> get messages => _messageController.stream;

  @override
  CloudIdentity? get identity => _identity;

  @override
  Stream<CloudIdentity> get identityStream => _identityController.stream;

  /// 1. No-op when the broker is not configured, or already connected as
  ///    [identity].
  /// 2. Drops the old client when the identity changed, and announces the
  ///    new one on [identityStream] (topic owners re-subscribe from it).
  /// 3. Connects with a persistent session (no clean start) and auto
  ///    reconnect; a failed first attempt retries every [_retryInterval].
  /// 4. Subscribes every registered topic and starts routing messages.
  @override
  Future<void> connect(CloudIdentity identity) async {
    final String clientId = identity.hubId;
    if (_identity != identity) {
      _identity = identity;
      _identityController.add(identity);
    }
    if (!CloudConstants.isMqttConfigured) {
      Log.w(_tag, 'CLOUD_MQTT_HOST not set — cloud connection disabled');
      return;
    }
    if (_clientId == clientId && isConnected) return;
    _retryTimer?.cancel();
    if (_clientId != clientId) {
      await _updates?.cancel();
      _updates = null;
      _client?.disconnect();
      _client = null;
    }
    _clientId = clientId;

    final MqttServerClient client = MqttServerClient(
      CloudConstants.mqttHost,
      clientId,
    );
    client.port = CloudConstants.mqttPort;
    client.keepAlivePeriod = _keepAliveSeconds;
    client.autoReconnect = true;
    client.resubscribeOnAutoReconnect = false;
    client.logging(on: false);
    client.onConnected = () {
      Log.i(_tag, 'Connected (${CloudConstants.mqttHost}) as $clientId');
      _connectionController.add(true);
    };
    client.onDisconnected = () {
      Log.w(_tag, 'Disconnected');
      _connectionController.add(false);
    };
    client.onAutoReconnected = () {
      Log.i(_tag, 'Auto-reconnected');
      _subscribeAll(client);
      _connectionController.add(true);
    };
    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(
          CloudConstants.mqttUsername,
          CloudConstants.mqttPassword,
        );
    // Persistent session (no startClean()): the broker keeps the QoS 1
    // subscriptions and queues every message while the Hub is offline.
    _client = client;

    try {
      await client.connect();
    } catch (e) {
      Log.e(_tag, 'Connect error: $e — retrying in ${_retryInterval.inSeconds}s');
      client.disconnect();
      _scheduleRetry();
      return;
    }
    if (!isConnected) {
      Log.e(_tag, 'Connect failed: ${client.connectionStatus}');
      client.disconnect();
      _scheduleRetry();
      return;
    }
    _subscribeAll(client);
    await _updates?.cancel();
    _updates = client.updates?.listen(_handleUpdates);
  }

  @override
  void subscribe(String topic) {
    if (!_subscriptions.add(topic)) return;
    final MqttServerClient? client = _client;
    if (client != null && isConnected) {
      client.subscribe(topic, MqttQos.atLeastOnce);
    }
  }

  @override
  bool publish(String topic, Map<String, dynamic> payload) {
    final MqttServerClient? client = _client;
    if (client == null || !isConnected) return false;
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder()
      ..addUTF8String(jsonEncode(payload));
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    return true;
  }

  void _subscribeAll(MqttServerClient client) {
    for (final String topic in _subscriptions) {
      client.subscribe(topic, MqttQos.atLeastOnce);
    }
  }

  void _scheduleRetry() {
    final CloudIdentity? identity = _identity;
    if (identity == null) return;
    _retryTimer?.cancel();
    _retryTimer = Timer(_retryInterval, () => unawaited(connect(identity)));
  }

  /// Decodes each publish as UTF-8 JSON and emits it on [messages]; a payload
  /// that is not a JSON object is logged and dropped.
  void _handleUpdates(List<MqttReceivedMessage<MqttMessage>> events) {
    for (final MqttReceivedMessage<MqttMessage> event in events) {
      final MqttMessage message = event.payload;
      if (message is! MqttPublishMessage) continue;
      final String text = const Utf8Decoder(allowMalformed: true)
          .convert(message.payload.message);
      try {
        final Object? decoded = jsonDecode(text);
        if (decoded is Map<String, dynamic>) {
          _messageController.add((topic: event.topic, json: decoded));
        } else {
          Log.w(_tag, 'Non-object payload on ${event.topic}: $text');
        }
      } catch (e) {
        Log.w(_tag, 'Bad JSON on ${event.topic}: $e');
      }
    }
  }
}
