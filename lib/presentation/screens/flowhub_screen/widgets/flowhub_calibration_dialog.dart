import 'package:flutter/material.dart';
import 'package:flowhub/core/theme/app_theme.dart';

/// "Start Precision Calibration" popup (figmaImage/8_calibration-3.png),
/// opened from the drawer's Calibration button. Height and table edge margin
/// are entered via a custom keypad (not the OS keyboard, tap a field to make
/// it the active one); display model is picked from toggle buttons (43"/
/// 50"/55") instead of typed, since a typed model name/size risks a
/// decimal-point typo reaching the sensor's table-geometry math. A fourth
/// "직접입력" (custom) toggle covers any display outside those three presets
/// — picking it dims the inch presets (tapping one still exits custom mode)
/// and reveals two more keypad-driven fields for the display's real
/// width/height in mm, sent straight through instead of a model name; store
/// staff doing a calibration won't have those numbers memorized, so this is
/// an escape hatch for an unlisted panel, not the primary path. Pressing
/// Start calls the existing [FlowHubCubit.startCalibration] flow (sends the real
/// START_CALIBRATION signal to the pickup table) via [onStart].
class FlowHubCalibrationDialog extends StatefulWidget {
  final double scale;
  final int initialHeight;
  final String initialDisplayModel;
  final double initialEdgeMarginMm;
  final void Function(int height, String displayModel, double edgeMarginMm,
      double? displayWidthMm, double? displayHeightMm) onStart;

  const FlowHubCalibrationDialog({
    super.key,
    required this.scale,
    required this.initialHeight,
    required this.initialDisplayModel,
    required this.initialEdgeMarginMm,
    required this.onStart,
  });

  static Future<void> show({
    required BuildContext context,
    required double scale,
    required int initialHeight,
    required String initialDisplayModel,
    required double initialEdgeMarginMm,
    required void Function(int height, String displayModel,
            double edgeMarginMm, double? displayWidthMm, double? displayHeightMm)
        onStart,
  }) {
    return showDialog(
      context: context,
      barrierColor: const Color(0x571A1C1E),
      builder: (dialogContext) => FlowHubCalibrationDialog(
        scale: scale,
        initialHeight: initialHeight,
        initialDisplayModel: initialDisplayModel,
        initialEdgeMarginMm: initialEdgeMarginMm,
        onStart: onStart,
      ),
    );
  }

  @override
  State<FlowHubCalibrationDialog> createState() => _FlowHubCalibrationDialogState();
}

/// Which numeric field the shared keypad is currently editing.
enum _ActiveField { height, margin, displayWidth, displayHeight }

/// Sentinel [_displayModel] value for the "직접입력" (custom) toggle — not a
/// real display_model FlowHub would ever send paired with a null mm size,
/// only used internally to pick which fields this dialog shows.
const _customModelSentinel = 'CUSTOM';

class _FlowHubCalibrationDialogState extends State<FlowHubCalibrationDialog> {
  late String _heightInput = widget.initialHeight.toString();
  late String _marginInput = widget.initialEdgeMarginMm.round().toString();
  late String _displayModel = widget.initialDisplayModel;
  String _widthMmInput = '';
  String _heightMmInput = '';
  _ActiveField _activeField = _ActiveField.height;

  bool get _isCustom => _displayModel == _customModelSentinel;

  String get _activeInput => switch (_activeField) {
        _ActiveField.height => _heightInput,
        _ActiveField.margin => _marginInput,
        _ActiveField.displayWidth => _widthMmInput,
        _ActiveField.displayHeight => _heightMmInput,
      };

  void _setActiveInput(String value) {
    setState(() {
      switch (_activeField) {
        case _ActiveField.height:
          _heightInput = value;
        case _ActiveField.margin:
          _marginInput = value;
        case _ActiveField.displayWidth:
          _widthMmInput = value;
        case _ActiveField.displayHeight:
          _heightMmInput = value;
      }
    });
  }

  void _appendDigit(String digit) {
    final current = _activeInput;
    _setActiveInput(current == '0' ? digit : '$current$digit');
  }

  void _backspace() {
    final current = _activeInput;
    if (current.isEmpty) return;
    _setActiveInput(current.substring(0, current.length - 1));
  }

  void _clear() => _setActiveInput('');

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
                fontFamily: flowhubFontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 36 * scale,
                height: 50 / 36,
                letterSpacing: -0.36 * scale,
                color: const Color(0xDE1A1C1E),
              ),
            ),
            SizedBox(height: 24 * scale),
            Text(
              'Select the display model and enter the sensor height and\ntable edge margin. Required for accurate calibration.',
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
            SizedBox(height: 48 * scale),
            SizedBox(
              width: contentWidth * scale,
              child: Center(
                child: _DisplayModelToggle(
                  scale: scale,
                  selected: _displayModel,
                  onSelect: (model) => setState(() => _displayModel = model),
                ),
              ),
            ),
            SizedBox(height: 32 * scale),
            SizedBox(
              width: contentWidth * scale,
              child: Row(
                children: [
                  Expanded(
                    child: _NumericField(
                      scale: scale,
                      label: 'Height (mm)',
                      value: _heightInput,
                      active: _activeField == _ActiveField.height,
                      onTap: () =>
                          setState(() => _activeField = _ActiveField.height),
                    ),
                  ),
                  SizedBox(width: 24 * scale),
                  Expanded(
                    child: _NumericField(
                      scale: scale,
                      label: 'Edge Margin (mm)',
                      value: _marginInput,
                      active: _activeField == _ActiveField.margin,
                      onTap: () =>
                          setState(() => _activeField = _ActiveField.margin),
                    ),
                  ),
                ],
              ),
            ),
            // Only shown for the "직접입력" (custom) toggle — a display
            // outside the 43"/50"/55" presets needs its real mm size
            // instead of a model name. See _isCustom.
            if (_isCustom) ...[
              SizedBox(height: 24 * scale),
              SizedBox(
                width: contentWidth * scale,
                child: Row(
                  children: [
                    Expanded(
                      child: _NumericField(
                        scale: scale,
                        label: 'Display Width (mm)',
                        value: _widthMmInput,
                        active: _activeField == _ActiveField.displayWidth,
                        onTap: () => setState(
                            () => _activeField = _ActiveField.displayWidth),
                      ),
                    ),
                    SizedBox(width: 24 * scale),
                    Expanded(
                      child: _NumericField(
                        scale: scale,
                        label: 'Display Height (mm)',
                        value: _heightMmInput,
                        active: _activeField == _ActiveField.displayHeight,
                        onTap: () => setState(
                            () => _activeField = _ActiveField.displayHeight),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 40 * scale),
            SizedBox(
              width: contentWidth * scale,
              child: Center(
                child: _CalibrationKeypad(
                  scale: scale,
                  onDigit: _appendDigit,
                  onBackspace: _backspace,
                  onClear: _clear,
                  backspaceEnabled: _activeInput.isNotEmpty,
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
                      bg: FlowHubColors.navy,
                      fg: Colors.white,
                      shadow: true,
                      onTap: () {
                        final height = int.tryParse(_heightInput) ??
                            widget.initialHeight;
                        final marginMm = double.tryParse(_marginInput) ??
                            widget.initialEdgeMarginMm;
                        final widthMm = _isCustom
                            ? double.tryParse(_widthMmInput)
                            : null;
                        final heightMm = _isCustom
                            ? double.tryParse(_heightMmInput)
                            : null;
                        Navigator.of(context).pop();
                        widget.onStart(
                            height, _displayModel, marginMm, widthMm, heightMm);
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

/// Outlined "<label> (mm)" field with a floating label, matching a Material
/// outline-text-field look — not a real TextField, since input comes only
/// from [_CalibrationKeypad] once tapped to become the active field. The
/// active field is highlighted (navy border/label) so it's clear which one
/// the keypad below is currently editing.
class _NumericField extends StatelessWidget {
  final double scale;
  final String label;
  final String value;
  final bool active;
  final VoidCallback onTap;

  const _NumericField({
    required this.scale,
    required this.label,
    required this.value,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = active ? FlowHubColors.navy : const Color(0x331A1C1E);
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 138 * scale,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderColor, width: 3 * scale),
              borderRadius: BorderRadius.circular(28 * scale),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32 * scale),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value.isEmpty ? '0' : value,
                      style: TextStyle(
                        fontFamily: flowhubFontFamily,
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
                      fontFamily: flowhubFontFamily,
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
            left: 24 * scale,
            top: -12 * scale,
            child: Container(
              color: FlowHubColors.cardBg,
              padding: EdgeInsets.symmetric(horizontal: 8 * scale),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: flowhubFontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 26 * scale,
                  height: 32 / 26,
                  letterSpacing: -0.26 * scale,
                  color: active ? FlowHubColors.navy : const Color(0xFF33383C),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Four-pill toggle for the pickup table's display model — 43"/50"/55" are
/// the fixed presets (so a decimal-point slip can't send the wrong table
/// geometry), plus "직접입력" for any display outside that list. Picking
/// "직접입력" dims the three preset pills (see [_ModelPill.dimmed]) to show
/// they're no longer the active source of truth, without disabling them —
/// tapping one still exits custom mode straight back to that preset.
class _DisplayModelToggle extends StatelessWidget {
  final double scale;
  final String selected;
  final void Function(String model) onSelect;

  const _DisplayModelToggle({
    required this.scale,
    required this.selected,
    required this.onSelect,
  });

  static const _models = [
    ('AIO_430A', '43"'),
    ('AIO_500A', '50"'),
    ('AIO_550A', '55"'),
    (_customModelSentinel, '직접입력'),
  ];

  @override
  Widget build(BuildContext context) {
    final isCustom = selected == _customModelSentinel;
    return Row(
      children: [
        for (int i = 0; i < _models.length; i++) ...[
          if (i != 0) SizedBox(width: 16 * scale),
          Expanded(
            child: _ModelPill(
              scale: scale,
              label: _models[i].$2,
              selected: selected == _models[i].$1,
              dimmed: isCustom && _models[i].$1 != _customModelSentinel,
              onTap: () => onSelect(_models[i].$1),
            ),
          ),
        ],
      ],
    );
  }
}

class _ModelPill extends StatelessWidget {
  final double scale;
  final String label;
  final bool selected;
  final bool dimmed;
  final VoidCallback onTap;

  const _ModelPill({
    required this.scale,
    required this.label,
    required this.selected,
    this.dimmed = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.4 : 1.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(28 * scale),
        onTap: onTap,
        child: Container(
          height: 88 * scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? FlowHubColors.navy : const Color(0x0DA37B42),
            borderRadius: BorderRadius.circular(28 * scale),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: flowhubFontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 30 * scale,
              height: 40 / 30,
              letterSpacing: -0.3 * scale,
              color: selected ? Colors.white : const Color(0x941A1C1E),
            ),
          ),
        ),
      ),
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
          color: def.tinted ? const Color(0xFFE0D5C8) : FlowHubColors.cardBg,
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
              fontFamily: flowhubFontFamily,
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
