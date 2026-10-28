import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flowhub/core/theme/pickup_table_theme_color_registry.dart';
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/usecases/clear_pickup_table_test_orders_usecase.dart';
import 'package:flowhub/domain/usecases/create_pickup_table_test_orders_usecase.dart';
import 'package:flowhub/domain/usecases/reset_pickup_table_theme_usecase.dart';
import 'package:flowhub/domain/usecases/send_pickup_table_theme_usecase.dart';

import 'pickup_table_theme_state.dart';

bool _selectionEquals(PickupTableThemeSelection a, PickupTableThemeSelection b) =>
    a.background == b.background &&
    a.style == b.style &&
    a.dotStyle == b.dotStyle &&
    a.backgroundImage == b.backgroundImage &&
    pickupTableThemeColorOverridesEquals(a.colorOverrides!, b.colorOverrides!);

/// The palette editor's 9 individually-editable swatches — grouped into 5
/// screen rows (labels below) matching the 5 kinds of colored square on
/// the real table: Brew (guide), Call (matched), Call-Expired (timeout),
/// QR-Highlight (receipt-scan), Background. [thankYouColor] isn't here —
/// it's not part of the editor (every built-in theme already agrees it's
/// white), only carried along in [PickupTableThemeColorOverrides] so
/// pickup_table's model still has a value for it.
enum PickupTableThemeColorSlot {
  background,
  guideFill,
  guideStroke,
  matchedFill1,
  matchedFill2,
  timeoutFill1,
  timeoutFill2,
  receiptFill1,
  receiptFill2,
}

extension PickupTableThemeColorSlotX on PickupTableThemeColorSlot {
  /// The label shown ABOVE each pair of swatches — 5 distinct rows even
  /// though there are 9 slots (background is its own row of 1).
  String get rowLabel => switch (this) {
        PickupTableThemeColorSlot.background => 'Background',
        PickupTableThemeColorSlot.guideFill ||
        PickupTableThemeColorSlot.guideStroke =>
          'Brew',
        PickupTableThemeColorSlot.matchedFill1 ||
        PickupTableThemeColorSlot.matchedFill2 =>
          'Call',
        PickupTableThemeColorSlot.timeoutFill1 ||
        PickupTableThemeColorSlot.timeoutFill2 =>
          'Call-Expired',
        PickupTableThemeColorSlot.receiptFill1 ||
        PickupTableThemeColorSlot.receiptFill2 =>
          'QR-Highlight',
      };

  /// The label shown ON each individual swatch, within its row.
  String get swatchLabel => switch (this) {
        PickupTableThemeColorSlot.background => 'Background',
        PickupTableThemeColorSlot.guideFill => 'Fill',
        PickupTableThemeColorSlot.guideStroke => 'Stroke',
        PickupTableThemeColorSlot.matchedFill1 ||
        PickupTableThemeColorSlot.timeoutFill1 ||
        PickupTableThemeColorSlot.receiptFill1 =>
          'Fill 1',
        PickupTableThemeColorSlot.matchedFill2 ||
        PickupTableThemeColorSlot.timeoutFill2 ||
        PickupTableThemeColorSlot.receiptFill2 =>
          'Fill 2',
      };

  Color valueOf(PickupTableThemeColorOverrides colors) => switch (this) {
        PickupTableThemeColorSlot.background => colors.background,
        PickupTableThemeColorSlot.guideFill => colors.guideFill,
        PickupTableThemeColorSlot.guideStroke => colors.guideStroke,
        PickupTableThemeColorSlot.matchedFill1 => colors.matchedFill1,
        PickupTableThemeColorSlot.matchedFill2 => colors.matchedFill2,
        PickupTableThemeColorSlot.timeoutFill1 => colors.timeoutFill1,
        PickupTableThemeColorSlot.timeoutFill2 => colors.timeoutFill2,
        PickupTableThemeColorSlot.receiptFill1 => colors.receiptFill1,
        PickupTableThemeColorSlot.receiptFill2 => colors.receiptFill2,
      };

  PickupTableThemeColorOverrides apply(PickupTableThemeColorOverrides colors, Color value) =>
      switch (this) {
        PickupTableThemeColorSlot.background => colors.copyWith(background: value),
        PickupTableThemeColorSlot.guideFill => colors.copyWith(guideFill: value),
        PickupTableThemeColorSlot.guideStroke => colors.copyWith(guideStroke: value),
        PickupTableThemeColorSlot.matchedFill1 => colors.copyWith(matchedFill1: value),
        PickupTableThemeColorSlot.matchedFill2 => colors.copyWith(matchedFill2: value),
        PickupTableThemeColorSlot.timeoutFill1 => colors.copyWith(timeoutFill1: value),
        PickupTableThemeColorSlot.timeoutFill2 => colors.copyWith(timeoutFill2: value),
        PickupTableThemeColorSlot.receiptFill1 => colors.copyWith(receiptFill1: value),
        PickupTableThemeColorSlot.receiptFill2 => colors.copyWith(receiptFill2: value),
      };
}

/// The 5 screen rows, top to bottom, each with 1 or 2 slots.
const List<List<PickupTableThemeColorSlot>> pickupTableThemeColorRows = [
  [PickupTableThemeColorSlot.background],
  [PickupTableThemeColorSlot.guideFill, PickupTableThemeColorSlot.guideStroke],
  [PickupTableThemeColorSlot.matchedFill1, PickupTableThemeColorSlot.matchedFill2],
  [PickupTableThemeColorSlot.timeoutFill1, PickupTableThemeColorSlot.timeoutFill2],
  [PickupTableThemeColorSlot.receiptFill1, PickupTableThemeColorSlot.receiptFill2],
];

/// Drives the "Pickup Table Theme 2" drawer screen — [PickupTableThemeCubit]'s
/// independent counterpart (see PickupTableThemeSelection's own doc
/// comment for why this is a separate feature rather than a 6th entry on
/// the original one): named color theme picker (seeds the palette editor
/// below it from [PickupTableThemeColorRegistry]), the 9-swatch palette
/// editor itself, guide dot size + Apply/Reset, publishing
/// SET_PICKUP_TABLE_THEME over the same beta/flowhub/pickuptable channel.
/// Reuses the SAME test-orders usecases as the original screen (grid
/// mode/test orders are theme-agnostic on the pickup table side).
///
/// Tapping a swatch's palette (or the color-theme/dot-size pickers) now
/// previews it on the real pickup table LIVE (see [_previewCurrent])
/// instead of waiting for Apply — Apply only commits that preview as the
/// new baseline ([_lastApplied]) to revert back to if a later visit
/// previews something and leaves without applying (see [close]). A fresh
/// [PickupTableThemeCubit] instance is created every time this screen is
/// opened (not a DI singleton), so [_lastApplied] is a static field
/// instead of instance state — it must survive across those instances to
/// have anything to revert to.
@injectable
class PickupTableThemeCubit extends Cubit<PickupTableThemeState> {
  final SendPickupTableThemeUseCase _sendTheme;
  final ResetPickupTableThemeUseCase _resetTheme;
  final CreatePickupTableTestOrdersUseCase _createTestOrders;
  final ClearPickupTableTestOrdersUseCase _clearTestOrders;

  // Forest Green is the confirmed default look for the pickup table (see
  // PickupTableState.themeOverride2's own default on the pickup_table
  // side) — free/untargeted matching (null) is no longer the boot-up
  // default, only reachable via the Reset button, which sets this to null.
  static PickupTableThemeSelection? _lastApplied = PickupTableThemeSelection(
    background: PickupTableThemeBackground.forestGreen,
    style: PickupTableThemeStyle.fill,
    colorOverrides: PickupTableThemeColorRegistry.resolve(PickupTableThemeBackground.forestGreen),
  );

  // What the picker/palette should show on open — the last applied
  // selection, or (only right after a Reset, when _lastApplied is null)
  // Forest Green as a reasonable starting point, even though nothing is
  // actually "applied" (see appliedSelection below, which stays null).
  static PickupTableThemeSelection get _pickerSeed =>
      _lastApplied ??
      PickupTableThemeSelection(
        background: PickupTableThemeBackground.forestGreen,
        style: PickupTableThemeStyle.fill,
        colorOverrides:
            PickupTableThemeColorRegistry.resolve(PickupTableThemeBackground.forestGreen),
      );

  PickupTableThemeCubit({
    required SendPickupTableThemeUseCase sendTheme,
    required ResetPickupTableThemeUseCase resetTheme,
    required CreatePickupTableTestOrdersUseCase createTestOrders,
    required ClearPickupTableTestOrdersUseCase clearTestOrders,
  })  : _sendTheme = sendTheme,
        _resetTheme = resetTheme,
        _createTestOrders = createTestOrders,
        _clearTestOrders = clearTestOrders,
        super(PickupTableThemeState(
          background: _pickerSeed.background,
          style: _pickerSeed.style,
          dotStyle: _pickerSeed.dotStyle,
          backgroundImage: _pickerSeed.backgroundImage,
          colors: _pickerSeed.colorOverrides!,
          appliedSelection: _lastApplied,
        ));

  /// Picking a named theme RESETS the palette to that theme's stock
  /// colors (any manual swatch edits from a previous theme are discarded)
  /// — matches "선택하면 그 테마 색상으로 바로 적용" from the spec.
  void selectBackground(PickupTableThemeBackground background) {
    emit(state.copyWith(
      background: background,
      colors: PickupTableThemeColorRegistry.resolve(background),
    ));
    _previewCurrent();
  }

  // No longer called from the screen (dark + fill was confirmed as the
  // only combination going forward) — kept rather than deleted in case
  // line style needs to come back for a future comparison.
  void selectStyle(PickupTableThemeStyle style) => emit(state.copyWith(style: style));

  void selectDotStyle(PickupTableThemeDotStyle dotStyle) {
    emit(state.copyWith(dotStyle: dotStyle));
    _previewCurrent();
  }

  void selectBackgroundImage(PickupTableThemeBackgroundImage backgroundImage) {
    emit(state.copyWith(backgroundImage: backgroundImage));
    _previewCurrent();
  }

  /// A single swatch's palette changed — updates just that one color
  /// within the current palette and previews live. Does NOT change
  /// [PickupTableThemeState.background] (the named-theme picker's own
  /// selection stays as a "started from" marker even once colors diverge
  /// from that theme's stock preset).
  void updateColorSlot(PickupTableThemeColorSlot slot, Color value) {
    emit(state.copyWith(colors: slot.apply(state.colors, value)));
    _previewCurrent();
  }

  // Whether any preview was actually live-sent this visit — lets [close]
  // skip reverting (e.g. a redundant reset-to-null resend) when the
  // operator opened the screen and left without touching anything at all.
  bool _touchedThisVisit = false;

  /// Sends whatever's currently picked straight to the real pickup table
  /// so the operator can browse colors live — a preview only, doesn't
  /// touch [_lastApplied]/[PickupTableThemeState.appliedSelection].
  void _previewCurrent() {
    _touchedThisVisit = true;
    unawaited(_sendTheme(_currentSelection()));
  }

  PickupTableThemeSelection _currentSelection() => PickupTableThemeSelection(
        background: state.background,
        style: state.style,
        dotStyle: state.dotStyle,
        backgroundImage: state.backgroundImage,
        colorOverrides: state.colors,
      );

  Future<void> apply() async {
    final selection = _currentSelection();
    emit(state.copyWith(isSending: true));
    await _sendTheme(selection);
    _lastApplied = selection;
    if (!isClosed) emit(state.copyWith(isSending: false, appliedSelection: selection));
  }

  Future<void> reset() async {
    emit(state.copyWith(isSending: true));
    await _resetTheme();
    _lastApplied = null;
    if (!isClosed) emit(state.copyWith(isSending: false, appliedSelection: null));
  }

  Future<void> createTestOrders() async {
    emit(state.copyWith(isSending: true));
    await _createTestOrders();
    if (!isClosed) emit(state.copyWith(isSending: false));
  }

  Future<void> clearTestOrders() async {
    emit(state.copyWith(isSending: true));
    await _clearTestOrders();
    if (!isClosed) emit(state.copyWith(isSending: false));
  }

  @override
  Future<void> close() {
    // Left the screen mid-preview without pressing Apply — put the real
    // table back to whatever was last actually applied (or back to
    // free/untargeted matching if that's what _lastApplied is). Skipped
    // entirely if nothing was ever touched this visit (nothing was
    // live-sent, so the table's real state was never disturbed).
    if (_touchedThisVisit) {
      final current = _currentSelection();
      final applied = _lastApplied;
      if (applied == null) {
        unawaited(_resetTheme());
      } else if (!_selectionEquals(current, applied)) {
        unawaited(_sendTheme(applied));
      }
    }
    return super.close();
  }
}
