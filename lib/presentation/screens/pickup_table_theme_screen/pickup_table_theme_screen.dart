import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flowhub/core/theme/app_theme.dart';
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/presentation/cubit/pickup_table_theme/pickup_table_theme_cubit.dart';
import 'package:flowhub/presentation/cubit/pickup_table_theme/pickup_table_theme_state.dart';
import 'package:flowhub/presentation/widgets/flowhub_sub_screen_scaffold.dart';

/// [PickupTableThemeScreen]'s independent counterpart for the "Pickup
/// Table Theme 2" feature (dotted guide border, translucent guide/
/// highlight backgrounds, gradient timeout/highlight card — see
/// PickupTableThemeSelection's doc comment for why this is a separate
/// screen rather than a 6th entry on the original one). 2 pickers (named
/// color theme + guide dot size — background/style are no longer
/// user-facing, dark background + fill style is the only confirmed
/// combination) + Apply/Reset, publishing SET_PICKUP_TABLE_THEME. Styled
/// identically to the original screen for consistency.
class PickupTableThemeScreen extends StatelessWidget {
  const PickupTableThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = FlowHubScale.of(context);

    return FlowHubSubScreenScaffold(
      scale: scale,
      title: 'Pickup Table Theme 2',
      headerIconAsset: 'assets/images/pickuptable.png',
      headerIconWidth: 36,
      headerIconHeight: 32,
      headerIconLeft: 52,
      headerTitleGap: 48,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 48 * scale, vertical: 16 * scale),
        child: BlocBuilder<PickupTableThemeCubit, PickupTableThemeState>(
          builder: (context, state) {
            final cubit = context.read<PickupTableThemeCubit>();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusCard(scale: scale, state: state),
                SizedBox(height: 32 * scale),
                // Style (line/fill) and the old light/dark background split
                // are gone from this UI — dark background + fill style was
                // confirmed as the only combination going forward, so
                // PickupTableThemeState.style stays fixed at its default
                // (fill) and only the named color theme is still a choice.
                _PickerRow<PickupTableThemeBackground>(
                  scale: scale,
                  label: 'Color Theme',
                  options: PickupTableThemeBackground.values,
                  selected: state.background,
                  labelOf: (v) => v.displayLabel,
                  onSelect: cubit.selectBackground,
                ),
                SizedBox(height: 32 * scale),
                // Palette editor — 5 rows (Background/Brew/Call/
                // Call-Expired/QR-Highlight), 1 or 2 tappable swatches
                // each. Picking a named theme above resets these to that
                // theme's stock colors; editing a swatch here diverges
                // from it without changing which chip reads as selected.
                _ColorPaletteSection(scale: scale, colors: state.colors, cubit: cubit),
                SizedBox(height: 32 * scale),
                _PickerRow<PickupTableThemeDotStyle>(
                  scale: scale,
                  label: 'Guide Dot Size',
                  options: PickupTableThemeDotStyle.values,
                  selected: state.dotStyle,
                  labelOf: (v) => v.displayLabel,
                  onSelect: cubit.selectDotStyle,
                ),
                SizedBox(height: 32 * scale),
                _PickerRow<PickupTableThemeBackgroundImage>(
                  scale: scale,
                  label: 'Background Image',
                  options: PickupTableThemeBackgroundImage.values,
                  selected: state.backgroundImage,
                  labelOf: (v) => v.displayLabel,
                  onSelect: cubit.selectBackgroundImage,
                ),
                SizedBox(height: 40 * scale),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        scale: scale,
                        label: 'Apply',
                        tinted: true,
                        enabled: !state.isSending,
                        onTap: cubit.apply,
                      ),
                    ),
                    SizedBox(width: 24 * scale),
                    Expanded(
                      child: _ActionButton(
                        scale: scale,
                        label: 'Reset',
                        tinted: false,
                        enabled: !state.isSending,
                        onTap: cubit.reset,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24 * scale),
                Text(
                  'Test Data',
                  style: TextStyle(
                    fontFamily: flowhubFontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 26 * scale,
                    color: const Color(0xFF1A1C1E),
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  'Generates 6 single-cup + one each of 2/3/5-cup test orders on the '
                  'pickup table (one single-cup order is pre-set to the timed-out '
                  'color, another to the receipt-scanned color+blink) — place real '
                  'cups on the rest to test guide → matched transitions without '
                  'waiting for real orders.',
                  style: TextStyle(
                    fontFamily: flowhubFontFamily,
                    fontSize: 20 * scale,
                    color: const Color(0x941A1C1E),
                  ),
                ),
                SizedBox(height: 12 * scale),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        scale: scale,
                        label: 'Create Test Orders',
                        tinted: true,
                        enabled: !state.isSending,
                        onTap: cubit.createTestOrders,
                      ),
                    ),
                    SizedBox(width: 24 * scale),
                    Expanded(
                      child: _ActionButton(
                        scale: scale,
                        label: 'Clear Test Orders',
                        tinted: false,
                        enabled: !state.isSending,
                        onTap: cubit.clearTestOrders,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final double scale;
  final PickupTableThemeState state;

  const _StatusCard({required this.scale, required this.state});

  @override
  Widget build(BuildContext context) {
    final applied = state.appliedSelection;
    final String statusText = applied == null
        ? 'Currently applied: none (original unthemed rendering)'
        : 'Currently applied: '
            '${applied.background.displayLabel} · '
            '${applied.dotStyle.displayLabel} dots';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0x1A1A1C1E)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontFamily: flowhubFontFamily,
          fontSize: 24 * scale,
          color: const Color(0xFF1A1C1E),
        ),
      ),
    );
  }
}

class _PickerRow<T> extends StatelessWidget {
  final double scale;
  final String label;
  final List<T> options;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelect;

  const _PickerRow({
    required this.scale,
    required this.label,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: flowhubFontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 26 * scale,
            color: const Color(0xFF1A1C1E),
          ),
        ),
        SizedBox(height: 12 * scale),
        Wrap(
          spacing: 16 * scale,
          runSpacing: 16 * scale,
          children: [
            for (final option in options)
              _Chip(
                scale: scale,
                label: labelOf(option),
                selected: option == selected,
                onTap: () => onSelect(option),
              ),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final double scale;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.scale,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFE1ECF3) : const Color(0xFFEFF1F3);
    final border = selected ? const Color(0xFF5FA0C0) : const Color(0x941A1C1E);

    return InkWell(
      borderRadius: BorderRadius.circular(12 * scale),
      onTap: onTap,
      child: Container(
        height: 68 * scale,
        padding: EdgeInsets.symmetric(horizontal: 28 * scale),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(color: border, width: 1 * scale),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: flowhubFontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 24 * scale,
            color: const Color(0xFF1A1C1E),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final double scale;
  final String label;
  final bool tinted;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.scale,
    required this.label,
    required this.tinted,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = tinted ? const Color(0xFFE1ECF3) : const Color(0xFFEFF1F3);
    final border = tinted ? const Color(0xFF5FA0C0) : const Color(0x941A1C1E);

    return InkWell(
      borderRadius: BorderRadius.circular(16 * scale),
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          height: 98 * scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(color: border, width: 1 * scale),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: flowhubFontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 28 * scale,
              color: const Color(0xFF1A1C1E),
            ),
          ),
        ),
      ),
    );
  }
}

/// The 5-row color-palette editor — [pickupTableThemeColorRows] grouped
/// under their shared row label (Background/Brew/Call/Call-Expired/
/// QR-Highlight), 1 or 2 tappable swatches per row.
class _ColorPaletteSection extends StatelessWidget {
  final double scale;
  final PickupTableThemeColorOverrides colors;
  final PickupTableThemeCubit cubit;

  const _ColorPaletteSection({
    required this.scale,
    required this.colors,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < pickupTableThemeColorRows.length; i++) ...[
          if (i != 0) SizedBox(height: 20 * scale),
          Text(
            pickupTableThemeColorRows[i].first.rowLabel,
            style: TextStyle(
              fontFamily: flowhubFontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 26 * scale,
              color: const Color(0xFF1A1C1E),
            ),
          ),
          SizedBox(height: 12 * scale),
          Row(
            children: [
              for (int j = 0; j < pickupTableThemeColorRows[i].length; j++) ...[
                if (j != 0) SizedBox(width: 16 * scale),
                Expanded(
                  child: _ColorSwatch(
                    scale: scale,
                    slot: pickupTableThemeColorRows[i][j],
                    color: pickupTableThemeColorRows[i][j].valueOf(colors),
                    onChanged: (value) =>
                        cubit.updateColorSlot(pickupTableThemeColorRows[i][j], value),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// One swatch: a filled box showing [slot]'s label + current hex, tap to
/// open an HSV color-wheel picker that updates [onChanged] live as the
/// operator drags (each change is immediately previewed on the real
/// table — see PickupTableThemeCubit.updateColorSlot).
class _ColorSwatch extends StatelessWidget {
  final double scale;
  final PickupTableThemeColorSlot slot;
  final Color color;
  final ValueChanged<Color> onChanged;

  const _ColorSwatch({
    required this.scale,
    required this.slot,
    required this.color,
    required this.onChanged,
  });

  String get _hexLabel =>
      '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  // White text reads poorly on light swatches — flip based on the
  // swatch's own perceived brightness (ignoring alpha, since translucent
  // swatches like Brew's Fill are always shown over the white card
  // background here, not over the real dark table background).
  Color get _labelColor => color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12 * scale),
      onTap: () => _openPicker(context),
      child: Container(
        height: 76 * scale,
        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(color: const Color(0x1A1A1C1E)),
        ),
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              slot.swatchLabel,
              style: TextStyle(
                fontFamily: flowhubFontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 20 * scale,
                color: _labelColor,
              ),
            ),
            Text(
              _hexLabel,
              style: TextStyle(
                fontFamily: flowhubFontFamily,
                fontSize: 18 * scale,
                color: _labelColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPicker(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${slot.rowLabel} · ${slot.swatchLabel}'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: color,
            enableAlpha: true,
            onColorChanged: onChanged,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
