import 'package:flutter/material.dart';
import 'package:flowhub/core/theme/app_theme.dart';

/// Search (order-number lookup) is fully built — field, numeric keypad,
/// filtering/sorting in FlowHubMainScreen — but parked for now. Flip this back
/// to true to bring the magnifying-glass icon (and the feature behind it)
/// back; nothing else needs to change.
const bool kSearchFeatureEnabled = false;

/// Top bar: hamburger + search on the left, date · time on the right.
/// Sized and positioned per the Figma spec (content height 88 @1280 design
/// width, all offsets measured from the status bar boundary, which
/// [SafeArea] already accounts for) — scaled down/up by [scale] to match
/// the actual device's logical width.
class FlowHubTopBar extends StatelessWidget {
  final double scale;
  final Color backgroundColor;
  final VoidCallback onMenuTap;
  final VoidCallback onSearchTap;
  final bool isSearching;
  final String searchInput;
  final bool searchCommitted;
  final VoidCallback onSearchFieldTap;
  final VoidCallback onCloseSearch;

  const FlowHubTopBar({
    super.key,
    required this.scale,
    required this.backgroundColor,
    required this.onMenuTap,
    required this.onSearchTap,
    required this.isSearching,
    required this.searchInput,
    required this.searchCommitted,
    required this.onSearchFieldTap,
    required this.onCloseSearch,
  });

  static const _weekdayNames = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];
  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(
        const Duration(seconds: 1),
        (_) => DateTime.now(),
      ),
      initialData: DateTime.now(),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        final dateText =
            '${_monthNames[now.month - 1]} ${now.day}, ${now.year} (${_weekdayNames[now.weekday - 1]})';
        final timeText =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

        return Container(
          height: 88 * scale,
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              bottom: BorderSide(
                color: const Color(0x0F1A1C1E),
                width: 2 * scale,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x1F1A1C1E),
                blurRadius: 12 * scale,
                offset: Offset(0, 4 * scale),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (kSearchFeatureEnabled && isSearching)
                Positioned(
                  left: 24 * scale,
                  top: (88 - 72) / 2 * scale,
                  child: _SearchField(
                    scale: scale,
                    input: searchInput,
                    committed: searchCommitted,
                    onTap: onSearchFieldTap,
                    onClose: onCloseSearch,
                  ),
                )
              else ...[
                Positioned(
                  left: 42 * scale,
                  top: 30 * scale,
                  child: InkWell(
                    onTap: onMenuTap,
                    child: Image.asset(
                      'assets/images/hamburger-button.png',
                      width: 36 * scale,
                      height: 28 * scale,
                      color: FlowHubColors.orderNoText,
                    ),
                  ),
                ),
                if (kSearchFeatureEnabled)
                  Positioned(
                    left: (42 + 36 + 49.05) * scale,
                    top: 23 * scale,
                    child: InkWell(
                      onTap: onSearchTap,
                      child: Image.asset(
                        'assets/images/search-button.png',
                        width: 41.35 * scale,
                        height: 41.35 * scale,
                        color: FlowHubColors.orderNoText,
                      ),
                    ),
                  ),
              ],
              Positioned(
                // No fixed width: the 267 Figma box was sized for one exact
                // sample string, and real device font metrics render slightly
                // wider — a fixed box either clipped text (wrap) or bled into
                // the dot/time (visible overflow). Sizing to content and
                // anchoring only the right edge avoids both.
                right: (32 + 160 + 22.24 + 5.52 + 16) * scale,
                top: 26 * scale,
                child: Text(
                  dateText,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontFamily: flowhubFontFamily,
                    fontWeight: FontWeight.w400,
                    fontSize: 28 * scale,
                    height: 36 / 28,
                    letterSpacing: -0.28 * scale,
                    color: FlowHubColors.textPrimary87,
                    // Fixed-width digits so the day-of-month doesn't shift the
                    // rest of the row as it changes.
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              Positioned(
                right: (32 + 160 + 22.24) * scale,
                // Raw spec value. An earlier "+6" nudge here was based on a
                // screenshot taken while the app-wide textScaler bug was still
                // live (see main_dev.dart) — once that got fixed, the nudge
                // over-corrected, so this is back to the original number.
                top: 41.24 * scale,
                child: Container(
                  width: 5.52 * scale,
                  height: 5.52 * scale,
                  decoration: const BoxDecoration(
                    color: FlowHubColors.textPrimary87,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                // Same reasoning as the date box above: no fixed width, so
                // the 32px right margin from the spec is never eaten into.
                right: 32 * scale,
                top: 19 * scale,
                child: _TabularClockText(
                  text: timeText,
                  style: TextStyle(
                    fontFamily: flowhubFontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 36 * scale,
                    height: 50 / 36,
                    letterSpacing: -0.36 * scale,
                    color: FlowHubColors.textPrimary87,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Renders a HH:MM:SS-shaped string with every digit pinned to the same
/// fixed cell width, so the clock never shifts horizontally as narrow digits
/// (e.g. "1") swap for wide ones (e.g. "8") each second — LineSeedJP doesn't
/// honor [FontFeature.tabularFigures], so its normal proportional digit
/// widths would otherwise make the whole block (and its gap to the "·")
/// jitter left/right on every tick.
class _TabularClockText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _TabularClockText({required this.text, required this.style});

  double _measure(String s) {
    final painter = TextPainter(
      text: TextSpan(text: s, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }

  @override
  Widget build(BuildContext context) {
    final digitWidth = [
      for (var i = 0; i < 10; i++) _measure('$i'),
    ].reduce((a, b) => a > b ? a : b);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final char in text.split(''))
          SizedBox(
            width: RegExp(r'[0-9]').hasMatch(char)
                ? digitWidth
                : _measure(char),
            child: Text(
              char,
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              style: style,
            ),
          ),
      ],
    );
  }
}

/// Order-number search field (figmaImage/7_search_1-2.png / -4.png). Two
/// color states: white while the keypad is open for typing, navy once
/// Search has been pressed and the list below is filtered.
class _SearchField extends StatelessWidget {
  final double scale;
  final String input;
  final bool committed;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _SearchField({
    required this.scale,
    required this.input,
    required this.committed,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = committed ? const Color(0xB2FFFFFF) : FlowHubColors.navy;
    final textColor = committed ? Colors.white : FlowHubColors.navy;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 478 * scale,
        height: 72 * scale,
        padding: EdgeInsets.symmetric(horizontal: 24 * scale),
        decoration: BoxDecoration(
          color: committed ? FlowHubColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(36 * scale),
          border: committed
              ? null
              : Border.all(color: const Color(0xFF235973), width: 3 * scale),
          boxShadow: [
            BoxShadow(
              color: const Color(0x421A1C1E),
              blurRadius: 12 * scale,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/search-button.png',
              width: 24.12 * scale,
              height: 24.12 * scale,
              color: iconColor,
            ),
            SizedBox(width: 24 * scale),
            Expanded(
              child: input.isEmpty
                  ? Text(
                      'Search by order number',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: flowhubFontFamily,
                        fontWeight: FontWeight.w400,
                        fontSize: 26 * scale,
                        height: 32 / 26,
                        letterSpacing: -0.26 * scale,
                        color: const Color(0x611A1C1E),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          input,
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            fontFamily: flowhubFontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 32 * scale,
                            height: 40 / 32,
                            letterSpacing: -0.32 * scale,
                            color: textColor,
                          ),
                        ),
                        if (!committed) ...[
                          SizedBox(width: 4 * scale),
                          Container(
                            width: 2 * scale,
                            height: 36 * scale,
                            color: FlowHubColors.navy,
                          ),
                        ],
                      ],
                    ),
            ),
            SizedBox(width: 24 * scale),
            InkWell(
              borderRadius: BorderRadius.circular(20 * scale),
              onTap: onClose,
              // close_search.png (gray circle + white X) matches the white
              // (typing) state as-is. close_search_result.png — provided for
              // the navy/white state — turned out to be just a plain white
              // circle with no X baked in (checked the raw pixels: solid
              // white at every opacity level, nothing dark), so the X is
              // still drawn on top with Icons.close rather than being part
              // of the asset.
              child: committed
                  ? SizedBox(
                      width: 33.33 * scale,
                      height: 33.33 * scale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/close_search_result.png',
                            width: 33.33 * scale,
                            height: 33.33 * scale,
                          ),
                          Icon(
                            Icons.close,
                            size: 20 * scale,
                            color: FlowHubColors.navy,
                          ),
                        ],
                      ),
                    )
                  : Image.asset(
                      'assets/images/close_search.png',
                      width: 33.33 * scale,
                      height: 33.33 * scale,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
