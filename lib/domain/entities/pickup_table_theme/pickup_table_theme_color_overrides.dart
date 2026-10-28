import 'package:flutter/material.dart';

/// Mirrors pickup_table's own PickupTableThemeColorOverrides (separate
/// Flutter app, no shared package — kept in sync by hand). Raw per-slot
/// colors FlowHub's palette editor lets the operator tweak under a named
/// theme — see pickup_table's PickupTableThemeRegistry.resolveSelection
/// for how these get turned into the real gradients that actually render.
///
/// Names mirror FlowHub's screen labels: guideFill/guideStroke = "Brew",
/// matchedFill1/2 = "Call", timeoutFill1/2 = "Call-Expired",
/// receiptFill1/2 = "QR-Highlight".
class PickupTableThemeColorOverrides {
  final Color background;
  final Color guideFill;
  final Color guideStroke;
  final Color matchedFill1;
  final Color matchedFill2;
  final Color timeoutFill1;
  final Color timeoutFill2;
  final Color receiptFill1;
  final Color receiptFill2;
  final Color thankYouColor;

  const PickupTableThemeColorOverrides({
    required this.background,
    required this.guideFill,
    required this.guideStroke,
    required this.matchedFill1,
    required this.matchedFill2,
    required this.timeoutFill1,
    required this.timeoutFill2,
    required this.receiptFill1,
    required this.receiptFill2,
    required this.thankYouColor,
  });

  PickupTableThemeColorOverrides copyWith({
    Color? background,
    Color? guideFill,
    Color? guideStroke,
    Color? matchedFill1,
    Color? matchedFill2,
    Color? timeoutFill1,
    Color? timeoutFill2,
    Color? receiptFill1,
    Color? receiptFill2,
    Color? thankYouColor,
  }) =>
      PickupTableThemeColorOverrides(
        background: background ?? this.background,
        guideFill: guideFill ?? this.guideFill,
        guideStroke: guideStroke ?? this.guideStroke,
        matchedFill1: matchedFill1 ?? this.matchedFill1,
        matchedFill2: matchedFill2 ?? this.matchedFill2,
        timeoutFill1: timeoutFill1 ?? this.timeoutFill1,
        timeoutFill2: timeoutFill2 ?? this.timeoutFill2,
        receiptFill1: receiptFill1 ?? this.receiptFill1,
        receiptFill2: receiptFill2 ?? this.receiptFill2,
        thankYouColor: thankYouColor ?? this.thankYouColor,
      );
}

/// Field-by-field equality — deliberately not a `==` override (this class
/// stays a plain value holder, same convention as PickupTableThemeSelection
/// on both sides), used by PickupTableThemeCubit to decide whether a
/// preview actually differs from the last applied selection.
bool pickupTableThemeColorOverridesEquals(
  PickupTableThemeColorOverrides a,
  PickupTableThemeColorOverrides b,
) =>
    a.background == b.background &&
    a.guideFill == b.guideFill &&
    a.guideStroke == b.guideStroke &&
    a.matchedFill1 == b.matchedFill1 &&
    a.matchedFill2 == b.matchedFill2 &&
    a.timeoutFill1 == b.timeoutFill1 &&
    a.timeoutFill2 == b.timeoutFill2 &&
    a.receiptFill1 == b.receiptFill1 &&
    a.receiptFill2 == b.receiptFill2 &&
    a.thankYouColor == b.thankYouColor;

extension PickupTableThemeColorOverridesJson on PickupTableThemeColorOverrides {
  Map<String, dynamic> toJson() {
    String hex(Color c) => c.value.toRadixString(16).padLeft(8, '0');
    return {
      'background': hex(background),
      'guideFill': hex(guideFill),
      'guideStroke': hex(guideStroke),
      'matchedFill1': hex(matchedFill1),
      'matchedFill2': hex(matchedFill2),
      'timeoutFill1': hex(timeoutFill1),
      'timeoutFill2': hex(timeoutFill2),
      'receiptFill1': hex(receiptFill1),
      'receiptFill2': hex(receiptFill2),
      'thankYouColor': hex(thankYouColor),
    };
  }
}
