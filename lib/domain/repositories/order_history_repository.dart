import 'package:flowhub/domain/entities/order/order.dart';

abstract class OrderHistoryRepository {
  /// Records [order] as having just completed — see
  /// [IOrderHistoryDataSource.appendCompletedOrder] for the append-only,
  /// no-overwrite semantics.
  Future<void> appendCompletedOrder(Order order);
}
