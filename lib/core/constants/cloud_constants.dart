/// Flow Cloud (Flow Manager) connection settings.
///
/// Values come from `--dart-define-from-file=env.json` (gitignored). An empty
/// host or API URL turns the matching feature off instead of failing.
class CloudConstants {
  CloudConstants._();

  /// Cloud MQTT broker (Flow Manager side of the `flow/...` topics).
  static const String mqttHost = String.fromEnvironment('CLOUD_MQTT_HOST');
  static const int mqttPort = int.fromEnvironment(
    'CLOUD_MQTT_PORT',
    defaultValue: 1883,
  );
  static const String mqttUsername = String.fromEnvironment(
    'CLOUD_MQTT_USERNAME',
  );
  static const String mqttPassword = String.fromEnvironment(
    'CLOUD_MQTT_PASSWORD',
  );

  /// Flow Manager REST base URL, without `/api/...` (device APIs use x-api-key).
  static const String apiUrl = String.fromEnvironment('FLOW_MANAGER_API_URL');
  static const String apiKey = String.fromEnvironment('FLOW_MANAGER_API_KEY');

  /// Whether the cloud MQTT connection is configured.
  static bool get isMqttConfigured => mqttHost.isNotEmpty;

  /// Whether the Flow Manager REST API is configured.
  static bool get isApiConfigured => apiUrl.isNotEmpty && apiKey.isNotEmpty;
}
