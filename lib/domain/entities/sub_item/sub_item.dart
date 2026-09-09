import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flowhub/domain/entities/selected_option/selected_option.dart';
import 'package:flowhub/domain/enums/order_status.dart';
import 'package:flowhub/domain/enums/production_stage.dart';

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
    // Real per-order customer selections, from a real kiosk order — e.g.
    // 'ICED'/'HOT', 'MD'/'LG', and the exact options+quantities picked.
    // Empty for orders with no real data yet (e.g. the dev test-order
    // button), in which case the UI falls back to the menu's static
    // default-recipe resolution instead.
    @Default('') String skuNo,
    @Default('') String temp,
    @Default('') String size,
    @Default([]) List<SelectedOption> selectedOptions,
    // Estimated-time gauge phase tracking (see GetRecipeTimingUseCase) — ALL
    // production types use this same estimated-duration engine, not real
    // hardware telemetry (Caye's own 0x24 packets only carry meaningful
    // values for straight espresso, so they're display-text-only now — see
    // _applyProgressToSubItem). The leader's periodic tick interpolates
    // `progress` between phaseStartProgress and phaseTargetProgress over
    // phaseDurationSeconds: the Nudof phase starts at label-DETACH (no real
    // signal exists at all for it), the Caye phase starts at Caye's real
    // 0x22 status=1 signal, and both hold just below their target until a
    // real signal (Caye 0x22 status=3, or the QR complete scan for the
    // final 1.0) snaps the value exactly. Null phaseStartedAt means no
    // phase is currently active (e.g. still Pending, or already finalized).
    DateTime? phaseStartedAt,
    @Default(0.0) double phaseStartProgress,
    @Default(0.0) double phaseTargetProgress,
    @Default(0) int phaseDurationSeconds,
    // Bottom-bar-message-worthy production event — see ProductionStage.
    @Default(ProductionStage.none) ProductionStage stage,
  }) = _SubItem;

  factory SubItem.initial(String menuName) => SubItem(
        menuName: menuName,
        logs: ['⏳ Pending...'],
      );

  factory SubItem.fromJson(Map<String, dynamic> json) =>
      _$SubItemFromJson(json);
}
