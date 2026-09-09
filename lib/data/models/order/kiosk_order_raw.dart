import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flowhub/domain/entities/index.dart';

part 'kiosk_order_raw.freezed.dart';
part 'kiosk_order_raw.g.dart';

/// Raw payload published to the `beta/kiosk/order` MQTT topic when a
/// customer completes an order on the kiosk — see the shared "MQTT Topic"
/// spec sheet for the authoritative schema.
@freezed
abstract class KioskOrderRaw with _$KioskOrderRaw {
  const KioskOrderRaw._();

  const factory KioskOrderRaw({
    @Default('') String eventId,
    @Default('') String orderNo,
    @Default('') String language,
    @Default(0) int totalCups,
    String? orderTime,
    @Default([]) List<KioskOrderItemRaw> items,
  }) = _KioskOrderRaw;

  factory KioskOrderRaw.fromJson(Map<String, dynamic> json) =>
      _$KioskOrderRawFromJson(json);

  Order toEntity() {
    final now = DateTime.now();
    return Order(
      orderNo: orderNo,
      rawOrderId: orderNo,
      language: language,
      drinkCount: items.length,
      items: items.map((item) => item.toSubItem()).toList(),
      receivedAt: now,
      stateEnteredAt: now,
    );
  }
}

/// One drink within a kiosk order — one `items[]` entry maps 1:1 to one
/// physical cup/[SubItem].
@freezed
abstract class KioskOrderItemRaw with _$KioskOrderItemRaw {
  const KioskOrderItemRaw._();

  const factory KioskOrderItemRaw({
    @Default(0) int seq,
    @Default('') String skuNo,
    @Default('') String menuName,
    @Default('') String temp,
    @Default('') String size,
    @Default([]) List<SelectedOption> options,
  }) = _KioskOrderItemRaw;

  factory KioskOrderItemRaw.fromJson(Map<String, dynamic> json) =>
      _$KioskOrderItemRawFromJson(json);

  SubItem toSubItem() => SubItem.initial(menuName).copyWith(
        skuNo: skuNo,
        temp: temp,
        size: size,
        selectedOptions: options,
      );
}
