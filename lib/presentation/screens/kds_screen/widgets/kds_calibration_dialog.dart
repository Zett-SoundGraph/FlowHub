import 'package:flutter/material.dart';
import 'package:flowhub/core/theme/app_theme.dart';

/// "Start Precision Calibration" popup (figmaImage/8_calibration-3.png),
/// opened from the drawer's Calibration button. Height is entered via a
/// custom keypad (not the OS keyboard). Pressing Start calls the existing
/// [KdsCubit.startCalibration] flow (sends the real START_CALIBRATION signal
/// to the pickup table, height included) via [onStart].
class KdsCalibrationDialog extends StatefulWidget {
  final double scale;
  final int initialHeight;
  final void Function(int height) onStart;

  const KdsCalibrationDialog({
    super.key,
    required this.scale,
    required this.initialHeight,
    required this.onStart,
  });

  static Future<void> show({
    required BuildContext context,
    required double scale,
    required int initialHeight,
    required void Function(int height) onStart,
  }) {
    return showDialog(
      context: context,
      barrierColor: const Color(0x571A1C1E),
      builder: (dialogContext) => KdsCalibrationDialog(
        scale: scale,
        initialHeight: initialHeight,
        onStart: onStart,
      ),
    );
  }

  @override
  State<KdsCalibrationDialog> createState() => _KdsCalibrationDialogState();
}

class _KdsCalibrationDialogState extends State<KdsCalibrationDialog> {
  late String _input = widget.initialHeight.toString();

  void _appendDigit(String digit) {
    setState(() => _input = _input == '0' ? digit : '$_input$digit');
  }

  void _backspace() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  void _clear() => setState(() => _input = '');

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    // Content width (820 - 40 - 40 padding) = 740, exactly matching
    // Cancel(240) + gap(16) + Start(484) below — the input field/keypad
    // (692 wide) are narrower and just centered within that same 740.
    const contentWidth = 740.0;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      elevation: 0,
      child: Container(
        width: 820 * scale,
        padding: EdgeInsets.all(40 * scale),
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
        // mainAxisSize.min lets the column shrink-wrap to the sum of its
        // children (which already adds up to exactly 1100*scale per the
        // spec's own gap math) instead of forcing a hard 1100*scale height —
        // a hardcoded height overflowed by a sub-pixel amount because text
        // line-height metrics don't round to *exactly* the same fraction of
        // a pixel as the fixed container height at every scale factor.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16 * scale), // 56 from container top - 40 padding
            Text(
              'Start Precision Calibration',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kdsFontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 36 * scale,
                height: 50 / 36,
                letterSpacing: -0.36 * scale,
                color: const Color(0xDE1A1C1E),
              ),
            ),
            SizedBox(height: 24 * scale),
            Text(
              'Please enter the current sensor height.\nRequired for accurate calibration.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kdsFontFamily,
                fontWeight: FontWeight.w400,
                fontSize: 28 * scale,
                height: 36 / 28,
                letterSpacing: -0.28 * scale,
                color: const Color(0x941A1C1E),
              ),
            ),
            SizedBox(height: 72 * scale),
            SizedBox(
              width: contentWidth * scale,
              child: Center(
                child: _HeightField(scale: scale, value: _input),
              ),
            ),
            SizedBox(height: 56 * scale),
            SizedBox(
              width: contentWidth * scale,
              child: Center(
                child: _CalibrationKeypad(
                  scale: scale,
                  onDigit: _appendDigit,
                  onBackspace: _backspace,
                  onClear: _clear,
                  backspaceEnabled: _input.isNotEmpty,
                ),
              ),
            ),
            SizedBox(height: 64 * scale),
            SizedBox(
              width: contentWidth * scale,
              child: Row(
                children: [
                  _DialogButton(
                    scale: scale,
                    width: 240,
                    label: 'Cancel',
                    bg: const Color(0x0DA37B42),
                    fg: const Color(0x941A1C1E),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: 16 * scale),
                  Expanded(
                    child: _DialogButton(
                      scale: scale,
                      width: null,
                      label: 'Start',
                      bg: KdsColors.navy,
                      fg: Colors.white,
                      shadow: true,
                      onTap: () {
                        final height =
                            int.tryParse(_input) ?? widget.initialHeight;
                        Navigator.of(context).pop();
                        widget.onStart(height);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Outlined "Height (mm)" field with a floating label, matching a Material
/// outline-text-field look — not a real TextField, since input comes only
/// from [_CalibrationKeypad].
class _HeightField extends StatelessWidget {
  final double scale;
  final String value;

  const _HeightField({required this.scale, required this.value});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 692 * scale,
          height: 138 * scale,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: KdsColors.navy, width: 3 * scale),
            borderRadius: BorderRadius.circular(28 * scale),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40 * scale),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? '0' : value,
                    style: TextStyle(
                      fontFamily: kdsFontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 40 * scale,
                      height: 58 / 40,
                      letterSpacing: -0.005 * 40 * scale,
                      color: const Color(0xFF1A1C1E),
                    ),
                  ),
                ),
                Text(
                  'mm',
                  style: TextStyle(
                    fontFamily: kdsFontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 32 * scale,
                    height: 40 / 32,
                    letterSpacing: -0.32 * scale,
                    color: const Color(0x941A1C1E),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 32 * scale,
          top: -12 * scale,
          child: Container(
            color: KdsColors.cardBg,
            padding: EdgeInsets.symmetric(horizontal: 8 * scale),
            child: Text(
              'Height (mm)',
              style: TextStyle(
                fontFamily: kdsFontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 26 * scale,
                height: 32 / 26,
                letterSpacing: -0.26 * scale,
                color: const Color(0xFF33383C),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 4-column keypad (7 8 9 C / 4 5 6 ⌫ / 1 2 3 0), matching
/// figmaImage/8_calibration-3.png.
class _CalibrationKeypad extends StatelessWidget {
  final double scale;
  final void Function(String digit) onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final bool backspaceEnabled;

  const _CalibrationKeypad({
    required this.scale,
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
    required this.backspaceEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 692 * scale,
      height: 432 * scale,
      padding: EdgeInsets.all(48 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAE3),
        borderRadius: BorderRadius.circular(40 * scale),
      ),
      child: Column(
        children: [
          _row([
            _KeyDef.digit('7', onDigit),
            _KeyDef.digit('8', onDigit),
            _KeyDef.digit('9', onDigit),
            _KeyDef.action('C', onClear),
          ]),
          SizedBox(height: 16 * scale),
          _row([
            _KeyDef.digit('4', onDigit),
            _KeyDef.digit('5', onDigit),
            _KeyDef.digit('6', onDigit),
            _KeyDef.backspace(onBackspace, backspaceEnabled),
          ]),
          SizedBox(height: 16 * scale),
          _row([
            _KeyDef.digit('1', onDigit),
            _KeyDef.digit('2', onDigit),
            _KeyDef.digit('3', onDigit),
            _KeyDef.digit('0', onDigit),
          ]),
        ],
      ),
    );
  }

  Widget _row(List<_KeyDef> keys) {
    return Expanded(
      child: Row(
        children: [
          for (int i = 0; i < keys.length; i++) ...[
            if (i != 0) SizedBox(width: 16 * scale),
            Expanded(child: _Key(scale: scale, def: keys[i])),
          ],
        ],
      ),
    );
  }
}

class _KeyDef {
  final String label;
  final VoidCallback? onTap;
  final bool isBackspace;
  // C and backspace get the darker tan (#E0D5C8) background; digit keys get
  // the lighter cardBg (#FFFCF7).
  final bool tinted;

  const _KeyDef._(this.label, this.onTap, this.isBackspace, this.tinted);

  factory _KeyDef.digit(String label, void Function(String) onDigit) =>
      _KeyDef._(label, () => onDigit(label), false, false);

  factory _KeyDef.action(String label, VoidCallback onTap) =>
      _KeyDef._(label, onTap, false, true);

  factory _KeyDef.backspace(VoidCallback onTap, bool enabled) =>
      _KeyDef._('←', enabled ? onTap : null, true, true);
}

class _Key extends StatelessWidget {
  final double scale;
  final _KeyDef def;

  const _Key({required this.scale, required this.def});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(32 * scale),
      splashColor: const Color(0xFFE5DDD1),
      highlightColor: const Color(0xFFE5DDD1),
      onTap: def.onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: def.tinted ? const Color(0xFFE0D5C8) : KdsColors.cardBg,
          borderRadius: BorderRadius.circular(32 * scale),
          boxShadow: [
            BoxShadow(
              color: const Color(0xCCB6AA9B),
              blurRadius: 9 * scale,
              offset: Offset(0, 3 * scale),
            ),
          ],
        ),
        child: Opacity(
          opacity: def.isBackspace && def.onTap == null ? 0.4 : 1,
          child: Text(
            def.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kdsFontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 36 * scale,
              height: 50 / 36,
              letterSpacing: -0.36 * scale,
              color: const Color(0xFF1A1C1E),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final double scale;
  final double? width;
  final String label;
  final Color bg;
  final Color fg;
  final bool shadow;
  final VoidCallback onTap;

  const _DialogButton({
    required this.scale,
    required this.width,
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
        width: width == null ? null : width! * scale,
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
