class NetworkConstants {
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);

  // [TODO] 매장 IP 확정 후 변경 필요
  static const String cayeMachineIp = '192.168.10.193';
  static const int cayeMachinePort = 31255;
}
