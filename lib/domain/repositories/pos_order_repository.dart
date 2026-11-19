import 'package:flowhub/domain/entities/pos_order/pos_order_ack.dart';
import 'package:flowhub/domain/entities/pos_order/pos_order_message.dart';

/// POS (Smaregi) orders from Flow Cloud: `pos-order` in, `pos-order-ack` out,
/// plus the cancel tombstones that make a late NEW answer ALREADY_CANCELLED.
abstract class PosOrderRepository {
  /// Every `pos-order` message for this Hub's current cloud identity.
  Stream<PosOrderMessage> get messages;

  /// Publishes the ack for [message] (QoS 1). Returns `false` when not
  /// connected: the cloud resends the message, and the same answer is
  /// given again.
  Future<bool> ack(PosOrderMessage message, PosOrderAck ack);

  /// Whether a CANCEL arrived for [orderNo] before its order existed.
  Future<bool> hasTombstone(String orderNo);

  /// Stores a tombstone for [orderNo] (kept at least 7 days).
  Future<void> addTombstone(String orderNo, DateTime cancelledAt);
}
