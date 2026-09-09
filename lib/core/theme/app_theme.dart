import 'package:flutter/material.dart';

/// Font family registered in pubspec.yaml — used for both the KDS
/// main-screen UI (figmaImage/1_main-*.png) and printed order labels
/// ([AppTextStyles], formerly JetBrainsMono).
const kdsFontFamily = 'LineSeedJP';

/// App-level text styles for printed order labels.
/// Use these constants in widgets directly (e.g. in screenshot capture contexts
/// where Theme.of(context) is not available).
///
/// Label typography. Spacing/margins/gaps in OrderLabelWidget are the
/// original Figma spec numbers, untouched. Font SIZES here are boosted well
/// past the spec's own numbers — at the printer's real 203dpi, the spec's
/// literal px values (e.g. 14px ≈ 1.75mm) print too small to read on a
/// 58mm-wide label, confirmed by checking the printer's own DPI/media-width
/// settings (no hardware/firmware scaling issue — the spec numbers
/// themselves are just physically tiny at 1:1 dot printing).
class AppTextStyles {

  /// Left column's rotated order number + sequence (e.g. "M1027 . 02/02").
  static const TextStyle labelTitle = TextStyle(
    fontFamily: kdsFontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 64.0,
    height: 1.0,
    letterSpacing: 0.64,
    color: Colors.black,
  );

  /// "[PRODUCT]" / "[OPTION]" section headers.
  static const TextStyle labelSectionHeader = TextStyle(
    fontFamily: kdsFontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 30.0,
    letterSpacing: 0.0,
    color: Colors.black,
  );

  /// The menu name line (e.g. "Banana Milk Latte").
  static const TextStyle labelMenuName = TextStyle(
    fontFamily: kdsFontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 26.0,
    letterSpacing: 0.26,
    color: Colors.black,
  );

  /// Version line + option list items — identical spec.
  static const TextStyle labelProduct = TextStyle(
    fontFamily: kdsFontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 24.0,
    letterSpacing: 0.24,
    color: Colors.black,
  );

  /// ORDER TIME / BUILD BY footer lines — same spec as [labelProduct], kept
  /// as its own named style since it's a semantically distinct section.
  static const TextStyle labelFooter = TextStyle(
    fontFamily: kdsFontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 22.0,
    letterSpacing: 0.22,
    color: Colors.black,
  );
}

/// App-wide theme configuration.
class AppTheme {
  static ThemeData get dark => ThemeData.dark().copyWith(
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.labelTitle,
          bodyLarge: AppTextStyles.labelProduct,
          bodyMedium: AppTextStyles.labelFooter,
        ),
      );
}

/// Design tokens for the KDS main screen, lifted from the Figma export
/// (figmaImage/1_main-*.png, 1280x1752).
class KdsColors {
  const KdsColors._();

  static const pageBg = Color(0xFFE3ECF0);
  static const navy = Color(0xFF05334A);
  static const tabInactiveText = Color(0xFFE5F0F7);
  static const cardBg = Color(0xFFFFFCF7);
  static const avatarBg = Color(0xFFF1EFEA);
  static const orderNoText = Color(0xFF33383C);
  static const timestampText = Color(0xFF7A7A79);
  static const divider = Color(0xFFF0EAE3);
  static const progressFill = Color(0xFFEEB123);
  static const bottomBarBg = Color(0xFFFFF8EF);
  static const viewDelayedBorder = Color(0xFFA37B42);

  static const badgeNew = Color(0xFF235973);
  static const badgeBrew = Color(0xFF825412);
  static const badgeCall = Color(0xFF254A22);
  static const badgeDone = Color(0xFF5C646C);
  static const badgeFood = Color(0xFFAFAFAF);

  /// rgba(26,28,30,87%) — the top bar's primary text/dot color from the spec.
  static const textPrimary87 = Color(0xDE1A1C1E);
}

/// The KDS Figma frames are 1280 logical px wide. Physical KDS tablets don't
/// all share that logical width/density, so every raw Figma value must be
/// multiplied by [KdsScale.of] before use — that keeps proportions matching
/// the design regardless of the actual device.
class KdsScale {
  const KdsScale._();

  static const figmaWidth = 1280.0;

  static double of(BuildContext context) => MediaQuery.sizeOf(context).width / figmaWidth;
}
