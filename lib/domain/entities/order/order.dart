import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kds/domain/entities/sub_item/sub_item.dart';
import 'package:kds/domain/enums/order_status.dart';

part 'order.freezed.dart';
part 'order.g.dart';

@freezed
abstract class Order with _$Order {
  const Order._();

  const factory Order({
    @Default('') String orderNo,
    @Default('') String rawOrderId,
    String? nickname,
    @Default([]) List<SubItem> items,
    @Default(0) int drinkCount,
    @Default(0) int foodCount,
    @Default(0) int bottleCount,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  bool get isAllReady =>
      items.isNotEmpty && items.every((item) => item.status == OrderStatus.ready);

  String get displayName =>
      (nickname != null && nickname!.isNotEmpty) ? nickname! : 'NO.$orderNo';

  int get totalCups {
    final count = drinkCount + foodCount + bottleCount;
    return count > 0 ? count : items.length;
  }
}
