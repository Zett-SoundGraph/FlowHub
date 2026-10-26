import 'package:flutter/material.dart';
import 'package:flowhub/core/theme/app_theme.dart';

/// "Reboot FlowHub" confirm popup, opened from the drawer's Reboot button —
/// same card chrome as [FlowHubCalibrationDialog]. Confirming switches the same
/// dialog into a non-dismissible spinner view (per the user's own request:
/// a simple circular progress indicator while the print queue resets and the
/// app relaunches) instead of popping, since there's no "done" state to
/// return to — [onConfirm] ends in a real OS-level process kill, so this
/// dialog (and the whole app) simply disappears once that happens.
class FlowHubRebootDialog extends StatefulWidget {
  final double scale;
  final Future<void> Function() onConfirm;

  const FlowHubRebootDialog({
    super.key,
    required this.scale,
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required double scale,
    required Future<void> Function() onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x571A1C1E),
      builder: (dialogContext) => FlowHubRebootDialog(
        scale: scale,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<FlowHubRebootDialog> createState() => _FlowHubRebootDialogState();
}

class _FlowHubRebootDialogState extends State<FlowHubRebootDialog> {
  bool _isRebooting = false;

  Future<void> _handleConfirm() async {
    setState(() => _isRebooting = true);
    // No further setState on success — the native side kills this process
    // before this await would ever return on a real device, so there's no
    // "finished" UI state to show. It only returns early on a failure deep
    // inside the native/platform-channel call, which has no dedicated error
    // UI here either (the operator's existing fallback — force-quit and
    // relaunch by hand — still works regardless).
    await widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    return PopScope(
      canPop: !_isRebooting,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        elevation: 0,
        child: Container(
          width: 820 * scale,
          padding: EdgeInsets.fromLTRB(
            40 * scale,
            32 * scale,
            40 * scale,
            40 * scale,
          ),
          decoration: BoxDecoration(
            color: FlowHubColors.cardBg,
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
          child: _isRebooting
              ? _RebootingContent(scale: scale)
              : _ConfirmContent(
                  scale: scale,
                  onCancel: () => Navigator.of(context).pop(),
                  onConfirm: _handleConfirm,
                ),
        ),
      ),
    );
  }
}

class _ConfirmContent extends StatelessWidget {
  final double scale;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _ConfirmContent({
    required this.scale,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(8 * scale, 24 * scale, 8 * scale, 0),
          child: Text(
            'Reboot FlowHub',
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
        SizedBox(height: 16 * scale),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8 * scale),
          child: Text(
            'Resets the print queue and relaunches the app. '
            'All current orders — New, Brew, Call, and Done — are kept.',
            style: TextStyle(
              fontFamily: flowhubFontFamily,
              fontWeight: FontWeight.w400,
              fontSize: 28 * scale,
              height: 36 / 28,
              letterSpacing: -0.28 * scale,
              color: const Color(0x941A1C1E),
            ),
          ),
        ),
        SizedBox(height: 64 * scale),
        Row(
          children: [
            Expanded(
              child: _DialogButton(
                scale: scale,
                label: 'Cancel',
                bg: const Color(0x0DA37B42),
                fg: const Color(0x941A1C1E),
                onTap: onCancel,
              ),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: _DialogButton(
                scale: scale,
                label: 'Reboot',
                bg: FlowHubColors.navy,
                fg: Colors.white,
                shadow: true,
                onTap: onConfirm,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RebootingContent extends StatelessWidget {
  final double scale;

  const _RebootingContent({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 24 * scale),
        SizedBox(
          width: 64 * scale,
          height: 64 * scale,
          child: CircularProgressIndicator(
            strokeWidth: 5 * scale,
            color: FlowHubColors.navy,
          ),
        ),
        SizedBox(height: 32 * scale),
        Text(
          'Resetting print queue and restarting…',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: flowhubFontFamily,
            fontWeight: FontWeight.w400,
            fontSize: 28 * scale,
            height: 36 / 28,
            letterSpacing: -0.28 * scale,
            color: const Color(0x941A1C1E),
          ),
        ),
        SizedBox(height: 16 * scale),
      ],
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
        height: 96 * scale,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(48 * scale),
          boxShadow: shadow
              ? [
                  BoxShadow(
                    color: const Color(0x1F1A1C1E),
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
            fontFamily: flowhubFontFamily,
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
