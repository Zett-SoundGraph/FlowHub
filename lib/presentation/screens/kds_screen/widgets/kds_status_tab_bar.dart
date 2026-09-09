import 'package:flutter/material.dart';
import 'package:flowhub/core/theme/app_theme.dart';
import 'package:flowhub/presentation/enums/index.dart';

/// Pill-shaped NEW / BREW / CALL / DONE segmented tab bar.
class KdsStatusTabBar extends StatelessWidget {
  final double scale;
  final OrderTab selected;
  final Map<OrderTab, int> counts;
  final Map<OrderTab, bool> hasDelayed;
  final ValueChanged<OrderTab> onSelect;

  const KdsStatusTabBar({
    super.key,
    required this.scale,
    required this.selected,
    required this.counts,
    required this.hasDelayed,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(24 * scale, 24 * scale, 24 * scale, 0),
      padding: EdgeInsets.all(12 * scale),
      height: 88 * scale,
      decoration: BoxDecoration(
        color: KdsColors.navy,
        borderRadius: BorderRadius.circular(44 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0DD6CADE),
            blurRadius: 16 * scale,
            spreadRadius: -1 * scale,
            offset: Offset(0, 9 * scale),
          ),
          BoxShadow(
            color: const Color(0x0F7E7783),
            blurRadius: 32 * scale,
            offset: Offset(3 * scale, 4 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          for (final tab in OrderTab.values) ...[
            if (tab != OrderTab.values.first) SizedBox(width: 16 * scale),
            Expanded(
              child: _TabButton(
                scale: scale,
                tab: tab,
                count: _formatCount(counts[tab] ?? 0),
                selected: selected == tab,
                hasDelayed: hasDelayed[tab] ?? false,
                onSelect: onSelect,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Adds thousands separators (e.g. 2000 -> "2,000") without pulling in intl.
  static String _formatCount(int n) {
    final digits = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final posFromEnd = digits.length - i;
      buffer.write(digits[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }
}

class _TabButton extends StatelessWidget {
  final double scale;
  final OrderTab tab;
  final String count;
  final bool selected;
  final bool hasDelayed;
  final ValueChanged<OrderTab> onSelect;

  const _TabButton({
    required this.scale,
    required this.tab,
    required this.count,
    required this.selected,
    required this.hasDelayed,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(tab),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 64 * scale,
            padding: EdgeInsets.symmetric(horizontal: 8 * scale),
            decoration: BoxDecoration(
              color: selected ? tab.pageBackground : const Color(0x1FFFFFFF),
              borderRadius: BorderRadius.circular(48 * scale),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tab.label,
                    style: TextStyle(
                      fontFamily: kdsFontFamily,
                      fontSize: 28 * scale,
                      height: 36 / 28,
                      letterSpacing: -0.28 * scale,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                      color: selected ? KdsColors.navy : KdsColors.tabInactiveText,
                    ),
                  ),
                  SizedBox(width: 20 * scale),
                  Text(
                    count,
                    style: TextStyle(
                      fontFamily: kdsFontFamily,
                      fontSize: 28 * scale,
                      height: 36 / 28,
                      letterSpacing: -0.28 * scale,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                      color: selected ? KdsColors.navy : KdsColors.tabInactiveText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Delayed-order indicator: 20 from the tab's right edge, 12 from its top.
          if (hasDelayed)
            Positioned(
              top: 12 * scale,
              right: 20 * scale,
              child: Container(
                width: 16 * scale,
                height: 16 * scale,
                decoration: const BoxDecoration(color: Color(0xFFFF6B6B), shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }
}
