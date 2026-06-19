import 'package:kds/domain/entities/index.dart';

abstract class OrderRepository {
  Stream<bool> get connectionStream;
  Future<void> connect();
  void disconnect();
  
  Future<bool> completeCooking(Order order);
  Future<bool> completePickup(Order order);
}
