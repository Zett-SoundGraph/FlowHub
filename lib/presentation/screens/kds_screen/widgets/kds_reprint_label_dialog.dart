import 'package:flutter/material.dart';
import 'package:flowhub/core/theme/app_theme.dart';

/// Confirmation popup shown before (re)printing a label — either the header
/// print button (all beverages) or a single item's QR button (one
/// beverage), matching figmaImage/4_reprintLabel-1.png / -2.png.
class KdsReprintLabelDialog extends StatelessWidget {
  final double scale;
  final String title;
  final String subtitle;
  final VoidCallback onReprint;

  const KdsReprintLabelDialog({
    super.key,
    required this.scale,
    required this.title,
    required this.subtitle,
    required this.onReprint,
  });

  static Future<void> show({
    required BuildContext context,
    required double scale,
    required String title,
    required String subtitle,
    required VoidCallback onReprint,
  }) {
    return showDialog(
      context: context,
      // No scrim value was given in the spec text, so this was measured by
      // pixel-sampling the page background outside the popup in both
      // figmaImage/4_reprintLabel-*.png against the known (undimmed)
      // NEW/BREW tab colors — both independently landed on ~34% black.
      barrierColor: const Color(0x571A1C1E),
      builder: (dialogContext) => KdsReprintLabelDialog(
        scale: scale,
        title: title,
        subtitle: subtitle,
        onReprint: onReprint,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      elevation: 0,
      child: Container(
        width: 576 * scale,
        height: 394 * scale,
        // The dialog's own padding is 40/32/40/40 (L/T/R/B) — the title and
        // subtitle sit 8px further right and 24px further down than that
        // (see the two inner Paddings below), but the buttons sit flush
        // against this padding at exactly left:40, matching the spec. With
        // this padding, the interior is exactly 576-40-40=496 wide — which
        // is exactly 240+16+240, so the buttons fit with zero slack; the
        // earlier "8px overflow" was from wrongly giving the buttons the
        // text's 48-left inset instead of the dialog's real 40.
        padding: EdgeInsets.fromLTRB(
          40 * scale,
          32 * scale,
          40 * scale,
          40 * scale,
        ),
        decoration: BoxDecoration(
          color: KdsColors.cardBg,
          borderRadius: BorderRadius.circular(40 * scale),
          boxShadow: [
            BoxShadow(color: const Color(0x1F1A1C1E), blurRadius: 104 * scale),
            BoxShadow(
              color: const Color(0x611A1C1E),
              blurRadius: 16 * scale,
              offset: Offset(0, 8 * scale),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8 * scale, top: 24 * scale),
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: kdsFontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 36 * scale,
                  height: 50 / 36,
                  letterSpacing: -0.36 * scale,
                  color: KdsColors.textPrimary87,
                ),
              ),
            ),
            SizedBox(height: 16 * scale),
            Padding(
              padding: EdgeInsets.only(left: 8 * scale),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontFamily: kdsFontFamily,
                  fontWeight: FontWeight.w400,
                  fontSize: 28 * scale,
                  height: 36 / 28,
                  letterSpacing: -0.28 * scale,
                  color: const Color(0x941A1C1E),
                ),
              ),
            ),
            SizedBox(height: 60 * scale),
            Row(
              children: [
                _DialogButton(
                  scale: scale,
                  label: 'Cancel',
                  bg: const Color(0x0DA37B42),
                  fg: const Color(0x941A1C1E),
                  onTap: () => Navigator.of(context).pop(),
                ),
                SizedBox(width: 16 * scale),
                _DialogButton(
                  scale: scale,
                  label: 'Reprint',
                  bg: KdsColors.navy,
                  fg: Colors.white,
                  shadow: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    onReprint();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final double scale;
  final String label;
  final Color bg;
  final Color fg;
  final bool shadow;
  final VoidCallback onTap;

  const _DialogButton({
    required this.scale,
    required this.label,
    required this.bg,
    required this.fg,
    this.shadow = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(48 * scale),
      onTap: onTap,
      child: Container(
        width: 240 * scale,
        height: 96 * scale,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: 12 * scale,
          vertical: 28 * scale,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(48 * scale),
          boxShadow: shadow
              ? [
                  BoxShadow(
                    color: const Color(0x1F000000),
                    blurRadius: 4 * scale,
                    offset: Offset(0, 4 * scale),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: kdsFontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 32 * scale,
            height: 40 / 32,
            letterSpacing: -0.32 * scale,
            color: fg,
          ),
        ),
      ),
    );
  }
}
