class NetworkConstants {
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);

  static const String cayeMachineIp = '192.168.10.221';
  static const int cayeMachinePort = 31255;

  static const String mqttBrokerHost = '192.168.10.240';
  static const int mqttBrokerPort = 1883;
  static const String mqttUsername = String.fromEnvironment('MQTT_USERNAME');
  static const String mqttPassword = String.fromEnvironment('MQTT_PASSWORD');

  // Fixed identity — never change once registered with Message Hub (used as
  // the MQTT client ID and the heartbeat topic suffix).
  static const String mqttDeviceId = 'flowhub-main';
  // Display label shown on the Message Hub dashboard — safe to change anytime.
  static const String mqttDeviceName = 'FlowHub-Leader';
}
