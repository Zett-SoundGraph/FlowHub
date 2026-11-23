// Replaced by the SQLite order table (OrderStoreRepository /
// order_local_data_source.dart), which keeps the live orders and their
// cloud sync state in one place. Kept commented out for reference.
//
// import 'package:flowhub/domain/entities/order/order.dart';
//
// abstract class LiveOrdersSnapshotRepository {
//   Future<void> save(List<Order> orders);
//   Future<List<Order>> load();
//   Future<void> clear();
// }
