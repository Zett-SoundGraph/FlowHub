import 'package:freezed_annotation/freezed_annotation.dart';

part 'manufacturing_queue_item.freezed.dart';

@freezed
abstract class ManufacturingQueueItem with _$ManufacturingQueueItem {
  const factory ManufacturingQueueItem({
    required String machineIp,
    required String productKey,
    required String machineOrderNo, // format: "1001.01" — sent to Caye machine
    required String orderNo, // format: "1001" — used to look up KDS order list
    required int subItemIndex, // index within Order.items
    @Default(false) bool isExtraShot,
    @Default('') String qrData, // QR payload for label printing
  }) = _ManufacturingQueueItem;
}
