import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kds/domain/enums/order_status.dart';

part 'sub_item.freezed.dart';
part 'sub_item.g.dart';

@freezed
abstract class SubItem with _$SubItem {
  const SubItem._();

  const factory SubItem({
    @Default('') String menuName,
    @Default(OrderStatus.pending) OrderStatus status,
    @Default(0.0) double progress,
    @Default([]) List<String> logs,
    @Default(false) bool isExtracting,
    @Default(false) bool isError,
    String? errorCode,
    @Default('Pending') String currentStage,
  }) = _SubItem;

  factory SubItem.initial(String menuName) => SubItem(
        menuName: menuName,
        logs: ['⏳ Pending...'],
      );

  factory SubItem.fromJson(Map<String, dynamic> json) =>
      _$SubItemFromJson(json);
}
