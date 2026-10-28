import 'package:flowhub/domain/entities/pickup_table_theme/pickup_table_theme_color_overrides.dart';

/// line = outline-only cards (border + solid corner tag).
/// fill = solid-filled cards (fill + inverted corner tag). [style] below is
/// fixed to [fill] on the FlowHub side, but the enum is kept (rather than
/// removed) so the wire format/pickup_table side don't need a matching
/// structural change — see [PickupTableThemeSelection.style]'s doc comment.
enum PickupTableThemeStyle { line, fill }

/// Mirrors pickup_table's own PickupTableThemeBackground (separate
/// Flutter app, no shared package — kept in sync by hand) — each value is
/// a complete, independent named color theme (background + every accent
/// color) on the pickup table side, replacing the old 5-value light/dark-
/// grouped system. Kept the enum's type name (rather than renaming to
/// e.g. PickupTableThemePalette) to avoid touching the freezed-generated
/// PickupTableThemeState type reference.
enum PickupTableThemeBackground {
  forestGreen,
  charcoal,
  deepNavy,
  slateBlue,
  theme05,
  theme06,
  starbucks,
  mammoth,
  maga,
  doutor,
  supreme,
}

extension PickupTableThemeBackgroundLabel on PickupTableThemeBackground {
  String get displayLabel => switch (this) {
        PickupTableThemeBackground.forestGreen => 'Forest Green',
        PickupTableThemeBackground.charcoal => 'Charcoal',
        PickupTableThemeBackground.deepNavy => 'Deep Navy',
        PickupTableThemeBackground.slateBlue => 'Slate Blue',
        PickupTableThemeBackground.theme05 => '#05',
        PickupTableThemeBackground.theme06 => '#06',
        PickupTableThemeBackground.starbucks => 'STARBUCKS',
        PickupTableThemeBackground.mammoth => 'MAMMOTH',
        PickupTableThemeBackground.maga => 'MAGA',
        PickupTableThemeBackground.doutor => 'DOUTOR',
        PickupTableThemeBackground.supreme => 'SUPREME',
      };
}

/// Mirrors pickup_table's own PickupTableThemeDotStyle — an A/B/C
/// comparison knob for the guide slot's dotted border size, purely to
/// compare on a live device (not a design decision either way yet).
enum PickupTableThemeDotStyle { standard, medium, large }

extension PickupTableThemeDotStyleLabel on PickupTableThemeDotStyle {
  String get displayLabel => switch (this) {
        PickupTableThemeDotStyle.standard => 'Standard',
        PickupTableThemeDotStyle.medium => 'Medium',
        PickupTableThemeDotStyle.large => 'Large',
      };
}

/// Mirrors pickup_table's own PickupTableThemeBackgroundImage — which
/// static background image file is shown behind the themed grid,
/// independent of [PickupTableThemeBackground] (that's the named *color*
/// palette; this is purely which bitmap asset pickup_table draws under it).
/// Add a new value here whenever a new background image is dropped into
/// pickup_table's assets — the actual asset-path mapping lives entirely on
/// the pickup_table side, this side only ever sends the enum name.
enum PickupTableThemeBackgroundImage { menuImage, techImage, loopMenuImages }

extension PickupTableThemeBackgroundImageLabel on PickupTableThemeBackgroundImage {
  String get displayLabel => switch (this) {
        PickupTableThemeBackgroundImage.menuImage => 'Menu Image',
        PickupTableThemeBackgroundImage.techImage => 'Tech Image',
        PickupTableThemeBackgroundImage.loopMenuImages => 'Loop Menu Images',
      };
}

/// Selection for the Pickup Table Theme feature — mirrors pickup_table's
/// own entity of the same name (separate Flutter app, no shared package —
/// kept in sync by hand). [style] is fixed to fill on the FlowHub side
/// (dark + fill was confirmed as the only combination going forward) —
/// kept as a field rather than removed so the wire format/pickup_table
/// side don't need a matching structural change.
class PickupTableThemeSelection {
  final PickupTableThemeBackground background;
  final PickupTableThemeStyle style;
  final PickupTableThemeDotStyle dotStyle;
  final PickupTableThemeBackgroundImage backgroundImage;
  // The palette editor's current 9 colors (Brew/Call/Call-Expired/
  // QR-Highlight/Background) — sent alongside [background] so pickup_table
  // renders these exact colors instead of re-deriving them from its own
  // built-in registry (see PickupTableThemeRegistry.resolveSelection).
  final PickupTableThemeColorOverrides? colorOverrides;

  const PickupTableThemeSelection({
    required this.background,
    required this.style,
    this.dotStyle = PickupTableThemeDotStyle.standard,
    this.backgroundImage = PickupTableThemeBackgroundImage.menuImage,
    this.colorOverrides,
  });
}

extension PickupTableThemeSelectionJson on PickupTableThemeSelection {
  Map<String, dynamic> toJson() => {
        'background': background.name,
        'style': style.name,
        'dotStyle': dotStyle.name,
        'backgroundImage': backgroundImage.name,
        if (colorOverrides != null) 'colorOverrides': colorOverrides!.toJson(),
      };
}
