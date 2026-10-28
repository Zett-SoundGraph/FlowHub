import 'package:freezed_annotation/freezed_annotation.dart';

part 'manufacturing_queue_item.freezed.dart';

@freezed
abstract class ManufacturingQueueItem with _$ManufacturingQueueItem {
  const factory ManufacturingQueueItem({
    required String machineIp,
    required String productKey,
    required String machineOrderNo, // format: "1001.01" — sent to Caye machine
    required String orderNo, // format: "1001" — used to look up FlowHub order list
    required int subItemIndex, // index within Order.items
    @Default(false) bool isExtraShot,
    // Skips the normal 2s "place cup" wait after the machine reports ready —
    // for the consecutive-shot test button (Caye Machine Control screen),
    // where cups aren't actually being swapped between shots so there's
    // nothing to wait for.
    @Default(false) bool skipReadyDelay,
    @Default('') String qrData, // QR payload for label printing
  }) = _ManufacturingQueueItem;
}
