import 'package:kds/domain/entities/index.dart';

abstract class OrderRepository {
  Stream<bool> get connectionStream;
  Stream<({String orderNo, String menuName})> get pickupCompleteStream;
  Stream<String> get calibrationStatusStream;
  Stream<String> get barcodeScanStream;

  Future<void> connect();
  void disconnect();
  void sendStartCalibration(double height);

  Future<bool> completeCooking(Order order, SubItem subItem);
  Future<bool> completePickup(Order order);
}
