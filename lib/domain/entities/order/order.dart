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
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  String get displayName =>
      (nickname != null && nickname!.isNotEmpty) ? nickname! : 'NO.$orderNo';

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
