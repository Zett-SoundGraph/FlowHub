import 'package:flutter/material.dart';
import 'package:flowhub/core/theme/app_theme.dart';

/// Numeric keypad for the order-number search field
/// (figmaImage/7_search_1-2.png / -3.png).
class KdsSearchKeypad extends StatelessWidget {
  final double scale;
  final String currentInput;
  final void Function(String digit) onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onCancel;
  final VoidCallback onSearch;

  const KdsSearchKeypad({
    super.key,
    required this.scale,
    required this.currentInput,
    required this.onDigit,
    required this.onBackspace,
    required this.onCancel,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1280 * scale,
      height: 736 * scale,
      // Content (grid + Cancel/Search row) is inset 88 on both sides: the
      // grid's 3 columns of 357.33 with 16 gaps, and Cancel(240)+16+Search(848),
      // both sum to exactly 1104 = 1280 - 88*2, so 88 (not the nominal 40)
      // is the real horizontal inset actually used here.
      padding: EdgeInsets.fromLTRB(
        88 * scale,
        40 * scale,
        88 * scale,
        48 * scale,
      ),
      decoration: BoxDecoration(
        color: KdsColors.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40 * scale)),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _keyRow(['7', '8', '9']),
          SizedBox(height: 16 * scale),
          _keyRow(['4', '5', '6']),
          SizedBox(height: 16 * scale),
          _keyRow(['1', '2', '3']),
          SizedBox(height: 16 * scale),
          Row(
            children: [
              const Expanded(child: SizedBox.shrink()),
              SizedBox(width: 16 * scale),
              Expanded(
                child: _DigitKey(
                  scale: scale,
                  label: '0',
                  onTap: () => onDigit('0'),
                ),
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: _BackspaceKey(
                  scale: scale,
                  enabled: currentInput.isNotEmpty,
                  onTap: onBackspace,
                ),
              ),
            ],
          ),
          SizedBox(height: 48 * scale),
          Row(
            children: [
              SizedBox(
                width: 240 * scale,
                height: 96 * scale,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0x0DA37B42),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(48 * scale),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: kdsFontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 32 * scale,
                      height: 40 / 32,
                      letterSpacing: -0.32 * scale,
                      color: const Color(0x941A1C1E),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: _SearchButton(
                  scale: scale,
                  enabled: currentInput.isNotEmpty,
                  onTap: onSearch,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _keyRow(List<String> labels) {
    return Row(
      children: [
        for (int i = 0; i < labels.length; i++) ...[
          if (i != 0) SizedBox(width: 16 * scale),
          Expanded(
            child: _DigitKey(
              scale: scale,
              label: labels[i],
              onTap: () => onDigit(labels[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _DigitKey extends StatelessWidget {
  final double scale;
  final String label;
  final VoidCallback onTap;

  const _DigitKey({
    required this.scale,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(57 * scale),
      splashColor: const Color(0xFFF0EAE3),
      highlightColor: const Color(0xFFF0EAE3),
      onTap: onTap,
      child: Container(
        height: 114 * scale,
        padding: EdgeInsets.symmetric(
          horizontal: 8 * scale,
          vertical: 32 * scale,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: kdsFontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 44 * scale,
            color: const Color(0xFF235973),
          ),
        ),
      ),
    );
  }
}

class _BackspaceKey extends StatelessWidget {
  final double scale;
  final bool enabled;
  final VoidCallback onTap;

  const _BackspaceKey({
    required this.scale,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(57 * scale),
      splashColor: const Color(0xFFF0EAE3),
      highlightColor: const Color(0xFFF0EAE3),
      onTap: enabled ? onTap : null,
      child: SizedBox(
        height: 114 * scale,
        child: Center(
          child: Opacity(
            opacity: enabled ? 1 : 0.4,
            child: Image.asset(
              'assets/images/Search_backspace.png',
              width: 40 * scale,
              height: 40 * scale,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  final double scale;
  final bool enabled;
  final VoidCallback onTap;

  const _SearchButton({
    required this.scale,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        borderRadius: BorderRadius.circular(48 * scale),
        onTap: enabled ? onTap : null,
        child: Container(
          height: 96 * scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: KdsColors.navy,
            borderRadius: BorderRadius.circular(48 * scale),
            boxShadow: [
              BoxShadow(
                color: const Color(0x1F000000),
                blurRadius: 4 * scale,
                offset: Offset(0, 4 * scale),
              ),
            ],
          ),
          child: Text(
            'Search',
            style: TextStyle(
              fontFamily: kdsFontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 32 * scale,
              height: 40 / 32,
              letterSpacing: -0.32 * scale,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
