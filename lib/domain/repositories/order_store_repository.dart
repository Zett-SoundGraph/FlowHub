import 'package:flowhub/domain/entities/order/order.dart';
import 'package:flowhub/domain/entities/order_sync/order_sync_rejection.dart';

/// The leader's local order table (SQLite): keeps the live orders across a
/// restart and syncs every order to Flow Manager.
///
/// Every change to an order raises its version in the same write. The
/// latest full snapshot is then sent on MQTT; REST is the safety net
/// (fallback and the hourly sweep). An order stays until Flow Manager has
/// acked its latest version.
abstract class OrderStoreRepository {
  /// Saves the current live orders.
  /// 1. Stores each order as it is now, so [loadLive] can restore it.
  /// 2. An order whose sync snapshot changed gets version+1 and is sent.
  /// 3. Orders not in [orders] stay stored but are no longer live.
  Future<void> save(List<Order> orders);

  /// The orders that were live at the last [save], for the restore after a
  /// restart. Empty after [clearLive].
  Future<List<Order>> loadLive();

  /// Takes every order off the board (daily rollover). The orders stay
  /// stored until they are synced.
  Future<void> clearLive();

  /// Order versions Flow Manager rejected for good.
  Stream<OrderSyncRejection> get rejections;
}
