import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flowhub/domain/entities/index.dart';

part 'pickup_table_theme_state.freezed.dart';

@freezed
abstract class PickupTableThemeState with _$PickupTableThemeState {
  const factory PickupTableThemeState({
    @Default(PickupTableThemeBackground.forestGreen) PickupTableThemeBackground background,
    // Line style is no longer exposed in the UI (dark+fill was confirmed
    // as the only combination going forward) — defaulted straight to fill.
    @Default(PickupTableThemeStyle.fill) PickupTableThemeStyle style,
    @Default(PickupTableThemeDotStyle.standard) PickupTableThemeDotStyle dotStyle,
    @Default(PickupTableThemeBackgroundImage.menuImage) PickupTableThemeBackgroundImage backgroundImage,
    // The palette editor's current 9 colors (Brew/Call/Call-Expired/
    // QR-Highlight/Background) — starts at [background]'s stock preset
    // (PickupTableThemeColorRegistry) every time [background] is picked,
    // then diverges as the operator tweaks individual swatches. Required
    // (no @Default) — PickupTableThemeCubit's constructor always seeds
    // this explicitly, same as background/style/dotStyle above.
    required PickupTableThemeColorOverrides colors,
    // Same "FlowHub's own local record, not a live readback" caveat as
    // PickupTableThemeState.appliedSelection.
    PickupTableThemeSelection? appliedSelection,
    @Default(false) bool isSending,
  }) = _PickupTableThemeState;
}
