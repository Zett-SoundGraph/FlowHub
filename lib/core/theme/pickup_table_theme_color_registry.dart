import 'package:flutter/material.dart';

import 'package:flowhub/domain/entities/index.dart';

/// Mirrors pickup_table's own PickupTableThemeRegistry (separate Flutter
/// app, no shared package — kept in sync by hand) — the stock fill1/fill2
/// values for each named theme, used to seed FlowHub's palette editor when
/// a theme chip is tapped. pickup_table's own registry is the authoritative
/// source (this only needs to match closely enough that the palette editor
/// starts from the same place the real table would show before any edits).
class PickupTableThemeColorRegistry {
  const PickupTableThemeColorRegistry._();

  static PickupTableThemeColorOverrides resolve(PickupTableThemeBackground background) =>
      _presets[background]!;

  static const Map<PickupTableThemeBackground, PickupTableThemeColorOverrides> _presets = {
    PickupTableThemeBackground.forestGreen: PickupTableThemeColorOverrides(
      background: Color(0xFF2C3D2F),
      guideFill: Color(0x1AFDF6E2),
      guideStroke: Color(0xFFFDF6E2),
      matchedFill1: Color(0xFFFDF6E2),
      matchedFill2: Color(0xFFFDF6E2),
      timeoutFill1: Color(0xFFFF6B6B),
      timeoutFill2: Color(0xFFFFABAB),
      receiptFill1: Color(0xFFF4CF33),
      receiptFill2: Color(0xFFF4CF33),
      thankYouColor: Color(0xFFFFFFFF),
    ),
    PickupTableThemeBackground.charcoal: PickupTableThemeColorOverrides(
      background: Color(0xFF202422),
      guideFill: Color(0x1AFDF6E2),
      guideStroke: Color(0xFFFDF6E2),
      matchedFill1: Color(0xFFFDF6E2),
      matchedFill2: Color(0xFFFDF6E2),
      timeoutFill1: Color(0xFFFF6B6B),
      timeoutFill2: Color(0xFFFFABAB),
      receiptFill1: Color(0xFFC4A96E),
      receiptFill2: Color(0xFFE2D0A8),
      thankYouColor: Color(0xFFFFFFFF),
    ),
    PickupTableThemeBackground.deepNavy: PickupTableThemeColorOverrides(
      background: Color(0xFF182649),
      guideFill: Color(0x1AFDF6E2),
      guideStroke: Color(0xFFFDF6E2),
      matchedFill1: Color(0xFFB5BCCA),
      matchedFill2: Color(0xFFB5BCCA),
      timeoutFill1: Color(0xFFFF6B6B),
      timeoutFill2: Color(0xFFFFABAB),
      receiptFill1: Color(0xFFB99174),
      receiptFill2: Color(0xFFB99174),
      thankYouColor: Color(0xFFFFFFFF),
    ),
    PickupTableThemeBackground.slateBlue: PickupTableThemeColorOverrides(
      background: Color(0xFF2C2310),
      guideFill: Color(0x1AA4C3E1),
      guideStroke: Color(0xFFA4C3E1),
      matchedFill1: Color(0xFFA4C3E1),
      matchedFill2: Color(0xFFA4C3E1),
      timeoutFill1: Color(0xFFFF6B6B),
      timeoutFill2: Color(0xFFFFABAB),
      receiptFill1: Color(0xFFDECBA1),
      receiptFill2: Color(0xFFE6E2D9),
      thankYouColor: Color(0xFFFFFFFF),
    ),
    PickupTableThemeBackground.theme05: PickupTableThemeColorOverrides(
      background: Color(0xFF2C1414),
      guideFill: Color(0x1ADECBA1),
      guideStroke: Color(0xFFDECBA1),
      matchedFill1: Color(0xFFDECBA1),
      matchedFill2: Color(0xFFDECBA1),
      timeoutFill1: Color(0xFFFF6B6B),
      timeoutFill2: Color(0xFFFFABAB),
      receiptFill1: Color(0xFFECC060),
      receiptFill2: Color(0xFFECC060),
      thankYouColor: Color(0xFFFFFFFF),
    ),
    // Guide fill (DDCAA0) vs guide stroke (DECBA1) are two different
    // hexes — confirmed per spec, not a typo.
    PickupTableThemeBackground.theme06: PickupTableThemeColorOverrides(
      background: Color(0xFF032843),
      guideFill: Color(0x1ADDCAA0),
      guideStroke: Color(0xFFDECBA1),
      matchedFill1: Color(0xFF6EB7DB),
      matchedFill2: Color(0xFF6EB7DB),
      timeoutFill1: Color(0xFFFF6B6B),
      timeoutFill2: Color(0xFFFFABAB),
      receiptFill1: Color(0xFFDDCAA0),
      receiptFill2: Color(0xFFDDCAA0),
      thankYouColor: Color(0xFFFFFFFF),
    ),
    // Guide fill (D4E9E2) vs guide stroke (DECBA1) are two different
    // hexes — confirmed per spec, not a typo (same pattern as "#06").
    PickupTableThemeBackground.starbucks: PickupTableThemeColorOverrides(
      background: Color(0xFF1E3932),
      guideFill: Color(0x1AD4E9E2),
      guideStroke: Color(0xFFDECBA1),
      matchedFill1: Color(0xFFD4E9E2),
      matchedFill2: Color(0xFFD4E9E2),
      timeoutFill1: Color(0xFFE75B52),
      timeoutFill2: Color(0xFFE75B52),
      receiptFill1: Color(0xFFCBA258),
      receiptFill2: Color(0xFFCBA258),
      thankYouColor: Color(0xFFFFFFFF),
    ),
    PickupTableThemeBackground.mammoth: PickupTableThemeColorOverrides(
      background: Color(0xFF231F20),
      guideFill: Color(0x1AF7F1EB),
      guideStroke: Color(0xFFF7F1EB),
      matchedFill1: Color(0xFFF7F1EB),
      matchedFill2: Color(0xFFF7F1EB),
      timeoutFill1: Color(0xFFEE4045),
      timeoutFill2: Color(0xFFEE4045),
      receiptFill1: Color(0xFFBD9075),
      receiptFill2: Color(0xFFBD9075),
      thankYouColor: Color(0xFFFFFFFF),
    ),
    PickupTableThemeBackground.maga: PickupTableThemeColorOverrides(
      background: Color(0xFF271411),
      guideFill: Color(0x1AF6F6F6),
      guideStroke: Color(0xFFF6F6F6),
      matchedFill1: Color(0xFFB5BCCA),
      matchedFill2: Color(0xFFB5BCCA),
      timeoutFill1: Color(0xFFF04B5E),
      timeoutFill2: Color(0xFFF04B5E),
      receiptFill1: Color(0xFFF6F6F6),
      receiptFill2: Color(0xFFF6F6F6),
      thankYouColor: Color(0xFFFFFFFF),
    ),
    PickupTableThemeBackground.doutor: PickupTableThemeColorOverrides(
      background: Color(0xFF000000),
      guideFill: Color(0x1AFDB813),
      guideStroke: Color(0xFFFDB813),
      matchedFill1: Color(0xFFF1F1F1),
      matchedFill2: Color(0xFFF1F1F1),
      timeoutFill1: Color(0xFFFF6641),
      timeoutFill2: Color(0xFFFF6641),
      receiptFill1: Color(0xFFF6F6F6),
      receiptFill2: Color(0xFFF6F6F6),
      thankYouColor: Color(0xFFFFFFFF),
    ),
    PickupTableThemeBackground.supreme: PickupTableThemeColorOverrides(
      background: Color(0xFF17110C),
      guideFill: Color(0x1AFAFAF2),
      guideStroke: Color(0xFFFAFAF2),
      matchedFill1: Color(0xFFF3E7D4),
      matchedFill2: Color(0xFFF3E7D4),
      timeoutFill1: Color(0xFFFF2725),
      timeoutFill2: Color(0xFFFF2725),
      receiptFill1: Color(0xFF009BE3),
      receiptFill2: Color(0xFF009BE3),
      thankYouColor: Color(0xFFFFFFFF),
    ),
  };
}
