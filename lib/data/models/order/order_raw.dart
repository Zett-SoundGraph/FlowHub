import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kds/domain/entities/order/order.dart';
import 'package:kds/domain/enums/index.dart';

part 'order_raw.freezed.dart';
part 'order_raw.g.dart';

@freezed
abstract class OrderRaw with _$OrderRaw {
  const OrderRaw._();

  const factory OrderRaw({
    @Default('') String orderNo,
    @Default('') String menuName,
    @Default(OrderStatus.pending) OrderStatus status,
  }) = _OrderRaw;

  factory OrderRaw.fromJson(Map<String, dynamic> json) =>
      _$OrderRawFromJson(json);

  Order toEntity() {
    return Order(
      orderNo: orderNo,
      menuName: menuName,
      status: status,
    );
  }
}
