import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flowhub/domain/entities/sub_item/sub_item.dart';

part 'order.freezed.dart';
part 'order.g.dart';

@freezed
abstract class Order with _$Order {
  const Order._();

  const factory Order({
    @Default('') String orderNo,
    @Default('') String rawOrderId,
    String? nickname,
    // From the kiosk order — carried through untouched so it can be
    // forwarded to display boards (e.g. Flow Board's status-bar copy) for
    // localization, even though nothing in FlowHub itself renders it yet.
    @Default('') String language,
    @Default([]) List<SubItem> items,
    @Default(0) int drinkCount,
    @Default(0) int foodCount,
    @Default(0) int bottleCount,
    DateTime? receivedAt,
    DateTime? stateEnteredAt,
    // POS (Smaregi) orders: the customer-facing number, sales channel and
    // amounts, kept as given and sent back through order sync. Empty / null
    // for kiosk orders (displayNo then falls back to orderNo).
    @Default('') String displayNo,
    @Default('') String channel,
    int? totalAmount,
    String? currency,
    String? paymentStatus,
    // Set when the order was cancelled at the POS; a cancelled order counts
    // as finished and syncs with tab CANCELLED.
    DateTime? cancelledAt,
    String? cancelledBy,
    // Device that recorded the pickup (e.g. `flow-pickup-table`, or this
    // Hub for a pickup completed by hand); sent through order sync.
    String? pickedUpBy,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  /// Whether the order was cancelled at the POS.
  bool get isCancelled => cancelledAt != null;

  /// POS orders show their customer-facing [displayNo]; kiosk orders, which
  /// have none, show [orderNo].
  String get displayName => (nickname != null && nickname!.isNotEmpty)
      ? nickname!
      : 'NO.${displayNo.isNotEmpty ? displayNo : orderNo}';

  int get totalCups {
    final count = drinkCount + foodCount + bottleCount;
    return count > 0 ? count : items.length;
  }

  /// Order-level gauge value for display boards — the average of every
  /// item's own estimated-time/real-telemetry progress (see SubItem's
  /// phase-tracking fields), so it naturally reaches exactly 1.0 only once
  /// every item is individually confirmed complete.
  double get aggregateProgress => items.isEmpty
      ? 0.0
      : items.map((i) => i.progress).reduce((a, b) => a + b) / items.length;
}
