import 'package:flowhub/domain/entities/order/order.dart';

abstract class LiveOrdersSnapshotRepository {
  Future<void> save(List<Order> orders);
  Future<List<Order>> load();
  Future<void> clear();
}
