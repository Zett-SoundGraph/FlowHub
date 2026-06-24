import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kds/domain/entities/index.dart';

part 'order_raw.freezed.dart';
part 'order_raw.g.dart';

@freezed
abstract class OrderRaw with _$OrderRaw {
  const OrderRaw._();

  const factory OrderRaw({
    @Default('') String orderNo,
    @Default('') String rawOrderId,
    String? nickname,
    @Default([]) List<String> menuNames,
    @Default(0) int drinkCount,
    @Default(0) int foodCount,
    @Default(0) int bottleCount,
  }) = _OrderRaw;

  factory OrderRaw.fromJson(Map<String, dynamic> json) =>
      _$OrderRawFromJson(json);

  Order toEntity() {
    return Order(
      orderNo: orderNo,
      rawOrderId: rawOrderId,
      nickname: nickname,
      drinkCount: drinkCount,
      foodCount: foodCount,
      bottleCount: bottleCount,
      items: menuNames.map((name) => SubItem.initial(name)).toList(),
    );
  }
}
