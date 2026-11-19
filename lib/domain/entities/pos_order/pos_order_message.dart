import 'package:flowhub/domain/entities/order/order.dart';

/// NEW or CANCEL.
enum PosOrderMessageType { newOrder, cancel, unknown }

/// One message on `flow/hub/{storeId}/{hubId}/pos-order`: a POS (Smaregi)
/// order sent by Flow Cloud, or its cancel.
///
/// The same message can arrive many times (resends, broker redelivery); it
/// is deduped on [orderNo], never on [messageId] or attempt.
class PosOrderMessage {
  const PosOrderMessage({
    required this.raw,
    required this.schemaVersion,
    required this.messageId,
    required this.type,
    required this.storeId,
    required this.hubId,
    required this.orderNo,
    this.expiresAt,
    this.order,
    this.cancelledAt,
    this.cancelledBy,
    this.error,
  });

  /// The message as received, for the ack's copied fields.
  final Map<String, dynamic> raw;
  final int schemaVersion;

  /// Echoed in the ack; stable across resends.
  final String messageId;
  final PosOrderMessageType type;
  final String storeId;
  final String hubId;

  /// Dedupe key; stored unchanged as the order's orderNo and rawOrderId.
  final String orderNo;

  /// NEW only: create nothing at or after this time.
  final DateTime? expiresAt;

  /// NEW only: the order to create (receivedAt is set by the Hub).
  final Order? order;

  /// CANCEL only.
  final DateTime? cancelledAt;
  final String? cancelledBy;

  /// Why the message can't be used (MISSING_FIELD, FIELD_TOO_LONG,
  /// INVALID_TIMESTAMP, ...); `null` when it is readable.
  final String? error;
}
