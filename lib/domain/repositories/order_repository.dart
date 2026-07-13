import 'package:kds/domain/entities/index.dart';

typedef FleetHeartbeatEvent = ({
  String deviceId,
  DateTime timestamp,
  String topic,
  String payload,
  String qos,
  bool retain,
});

abstract class OrderRepository {
  Stream<bool> get connectionStream;
  Stream<({String orderNo, String menuName})> get pickupCompleteStream;
  Stream<String> get calibrationStatusStream;
  Stream<String> get barcodeScanStream;
  Stream<FleetHeartbeatEvent> get fleetHeartbeatStream;
  Map<String, DateTime> get fleetLastSeen;

  Future<void> connect();
  void disconnect();
  void sendStartCalibration(double height);

  Future<bool> completeCooking(Order order, SubItem subItem);
  Future<bool> completePickup(Order order);
}
