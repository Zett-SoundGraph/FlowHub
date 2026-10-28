/// Fixed 16-color rotation used to tell each drink (SubItem) in an order
/// apart on the Caye/Nudof WLED guidance lights — see FlowHubCubit's
/// _handleKioskOrder (assignment) and _handlePrinterStatus/
/// _publishCayeWledOffForCaye0x22 (consumption). Deliberately a flat
/// round-robin, NOT random: two drinks in the SAME order must never land on
/// the same color (the whole point is disambiguating which light is for
/// which drink), and cycling through a fixed list — rather than rerolling —
/// guarantees that for any order with 16 or fewer items.
class DrinkLedColors {
  const DrinkLedColors._();

  static const List<String> palette = [
    '#FF0000', // red
    '#FF7F00', // orange
    '#FFD400', // yellow
    '#9ACD32', // yellow-green
    '#00C853', // green
    '#00E5A8', // spring green
    '#00E5FF', // cyan
    '#0091EA', // azure
    '#2962FF', // blue
    '#651FFF', // indigo
    '#AA00FF', // violet
    '#D500F9', // magenta
    '#FF4081', // pink
    '#FF1744', // rose
    '#8D6E63', // warm brown (visually distinct from the reds/pinks above)
    '#FFFFFF', // white (last resort / easiest to tell apart from all above)
  ];

  static int _nextIndex = 0;

  /// Returns the next color in rotation and advances the shared counter.
  /// Call once per drink, in order, as an order's items are first created —
  /// never re-call for the same drink later (its color must stay fixed for
  /// its whole lifetime).
  static String next() {
    final color = palette[_nextIndex % palette.length];
    _nextIndex++;
    return color;
  }
}
