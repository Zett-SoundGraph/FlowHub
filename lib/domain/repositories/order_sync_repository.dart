import 'package:flowhub/domain/entities/order/order.dart';

/// Order sync to Flow Cloud: `flow/hub/{storeId}/{hubId}/orders` and its ack.
///
/// Every change to an order publishes the full order snapshot with a
/// per-order version that only goes up. A version is resent until the cloud
/// acks it, and pending versions survive a restart.
abstract class OrderSyncRepository {
  /// Records the current live orders.
  /// 1. An order whose snapshot changed since the last record gets version+1
  ///    and is queued for publishing.
  /// 2. Unchanged orders are left alone; orders no longer live keep their
  ///    pending version until it is acked.
  Future<void> record(List<Order> orders);
}
