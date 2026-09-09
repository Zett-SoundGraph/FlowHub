import 'package:flutter/material.dart';
import 'package:flowhub/core/theme/app_theme.dart';

/// Bottom summary bar: total orders, total waiting cups, and the delayed-orders shortcut.
class KdsBottomSummaryBar extends StatelessWidget {
  final double scale;
  final int totalOrders;
  final int totalWaiting;
  final bool isFilteringDelayed;
  final VoidCallback onToggleViewDelayed;

  const KdsBottomSummaryBar({
    super.key,
    required this.scale,
    required this.totalOrders,
    required this.totalWaiting,
    required this.isFilteringDelayed,
    required this.onToggleViewDelayed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96 * scale,
      decoration: BoxDecoration(
        color: KdsColors.bottomBarBg,
        border: Border(
          top: BorderSide(color: const Color(0x1F1A1C1E), width: 1 * scale),
        ),
        boxShadow: [
          BoxShadow(color: const Color(0x1F000000), blurRadius: 16 * scale),
          BoxShadow(color: const Color(0x1F000000), blurRadius: 40 * scale),
          BoxShadow(
            color: const Color(0x61000000),
            blurRadius: 16 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 46.95 * scale),
          Row(
            children: [
              Image.asset(
                'assets/images/Exclude.png',
                width: 34.10 * scale,
                height: 40.5 * scale,
              ),
              SizedBox(width: 22.95 * scale),
              Text(
                '$totalOrders',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontFamily: kdsFontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 36 * scale,
                  height: 50 / 36,
                  letterSpacing: -0.36 * scale,
                  color: KdsColors.badgeBrew,
                ),
              ),
              SizedBox(width: 8 * scale),
              Text(
                'orders',
                style: TextStyle(
                  fontFamily: kdsFontFamily,
                  fontWeight: FontWeight.w400,
                  fontSize: 32 * scale,
                  height: 40 / 32,
                  letterSpacing: -0.32 * scale,
                  color: KdsColors.textPrimary87,
                ),
              ),
            ],
          ),
          SizedBox(width: 48 * scale),
          Container(
            width: 2 * scale,
            height: 32 * scale,
            color: const Color(0x421A1C1E),
          ),
          SizedBox(width: 53.25 * scale),
          Image.asset(
            'assets/images/Subtract.png',
            width: 39.01 * scale,
            height: 40.85 * scale,
          ),
          SizedBox(width: 19.74 * scale),
          Text(
            '$totalWaiting',
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontFamily: kdsFontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 36 * scale,
              height: 50 / 36,
              letterSpacing: -0.36 * scale,
              color: KdsColors.badgeNew,
            ),
          ),
          SizedBox(width: 8 * scale),
          Text(
            'waiting',
            style: TextStyle(
              fontFamily: kdsFontFamily,
              fontWeight: FontWeight.w400,
              fontSize: 32 * scale,
              height: 40 / 32,
              letterSpacing: -0.32 * scale,
              color: KdsColors.textPrimary87,
            ),
          ),
          const Spacer(),
          if (isFilteringDelayed)
            _ViewAllButton(scale: scale, onTap: onToggleViewDelayed)
          else
            OutlinedButton(
              onPressed: onToggleViewDelayed,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0x0DA37B42),
                side: const BorderSide(color: KdsColors.viewDelayedBorder),
                fixedSize: Size(220 * scale, 64 * scale),
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale,
                  vertical: 14 * scale,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16 * scale),
                ),
              ),
              child: Text(
                'View Delayed',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontFamily: kdsFontFamily,
                  fontWeight: FontWeight.w400,
                  fontSize: 28 * scale,
                  height: 36 / 28,
                  letterSpacing: -0.28 * scale,
                  color: KdsColors.textPrimary87,
                ),
              ),
            ),
          SizedBox(width: 40 * scale),
        ],
      ),
    );
  }
}

/// Replaces the "View Delayed" button while the delayed-only filter is
/// active — tapping it (the close.png "x") turns the filter back off.
class _ViewAllButton extends StatelessWidget {
  final double scale;
  final VoidCallback onTap;

  const _ViewAllButton({required this.scale, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16 * scale),
      onTap: onTap,
      child: Container(
        width: 212 * scale,
        height: 64 * scale,
        decoration: BoxDecoration(
          color: KdsColors.navy,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(color: const Color(0xFFA37B42), width: 1 * scale),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 26.95 * scale,
              top: 18.95 * scale,
              child: Image.asset(
                'assets/images/close.png',
                width: 26.1 * scale,
                height: 26.1 * scale,
                color: Colors.white,
              ),
            ),
            Positioned(
              left: 76 * scale,
              top: 14 * scale,
              right: 16 * scale,
              child: Text(
                'View All',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontFamily: kdsFontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 28 * scale,
                  height: 36 / 28,
                  letterSpacing: -0.28 * scale,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
