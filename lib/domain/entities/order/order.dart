import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kds/domain/enums/index.dart';

part 'order.freezed.dart';
part 'order.g.dart';

@freezed
abstract class Order with _$Order {
  const factory Order({
    @Default('') String orderNo,
    @Default('') String menuName,
    @Default(OrderStatus.pending) OrderStatus status,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
