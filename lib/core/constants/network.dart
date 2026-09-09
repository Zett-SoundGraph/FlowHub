import 'package:flowhub/core/constants/flowhub_identity.dart';
import 'package:flowhub/core/constants/local_subnet_resolver.dart';

class NetworkConstants {
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);

  // Every Cafe Beta device on one site shares a subnet (see
  // LocalSubnetResolver) — only the last octet is fixed per role, so a new
  // site (a different third octet) needs no code change or reinstall, just
  // its router pre-configured with these devices' addresses reserved.
  static String get cayeMachineIp => '${LocalSubnetResolver.prefix}.221';
  static const int cayeMachinePort = 31255;

  // The label printer's native (Kotlin) TCP connection reads this too — see
  // PrinterDataSource, which hands it to native via the 'setPrinterIp'
  // method call before it ever starts listening for status.
  static String get labelPrinterIp => '${LocalSubnetResolver.prefix}.203';

  static String get mqttBrokerHost => '${LocalSubnetResolver.prefix}.240';
  static const int mqttBrokerPort = 1883;
  static const String mqttUsername = String.fromEnvironment('MQTT_USERNAME');
  static const String mqttPassword = String.fromEnvironment('MQTT_PASSWORD');

  // Identity per physical unit — used as the MQTT client ID and the
  // heartbeat topic suffix. Leader/follower is the same codebase; which one
  // this build is gets resolved automatically from its own IP at startup
  // (see FlowHubIdentity.resolve, called from setupLocator) rather than
  // hand-edited here per build.
  static String get mqttDeviceId => FlowHubIdentity.deviceId;
  // Display label shown on the Message Hub dashboard.
  static String get mqttDeviceName => FlowHubIdentity.deviceName;
}
