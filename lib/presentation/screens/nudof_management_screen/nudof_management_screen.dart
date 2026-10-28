import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowhub/core/constants/network.dart';
import 'package:flowhub/core/theme/app_theme.dart';
import 'package:flowhub/presentation/cubit/nudof/nudof_control_cubit.dart';
import 'package:flowhub/presentation/cubit/nudof/nudof_control_state.dart';
import 'package:flowhub/presentation/widgets/flowhub_sub_screen_scaffold.dart';

/// New drawer tab, alongside Caye Machine Control: on/off control for the
/// Shelly Plug M Gen3 monitoring the Nudof dispenser's power draw, plus
/// visibility into the MQTT connection it rides on (broker address,
/// connect/disconnect) and a live readout of the TEST/LOG-ONLY dispensing
/// detector (see NudofControlCubit's class doc comment). No Figma reference
/// exists for this screen (net-new, not in the original design), so it's
/// styled to match Caye Machine Control rather than against a spec.
class NudofManagementScreen extends StatelessWidget {
  const NudofManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = FlowHubScale.of(context);

    return FlowHubSubScreenScaffold(
      scale: scale,
      title: 'Nudof Machine Control',
      headerIconAsset: 'assets/images/dispenser.png',
      headerIconWidth: 40,
      headerIconHeight: 40,
      headerIconLeft: 56,
      headerTitleGap: 48,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 48 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MqttStatusCard(scale: scale),
            SizedBox(height: 32 * scale),
            _PowerStatusCard(scale: scale),
            SizedBox(height: 32 * scale),
            _PowerControlButtons(scale: scale),
          ],
        ),
      ),
    );
  }
}

/// Broker address + the plug's own Online/Offline state (its Gen2+
/// online/LWT topic — the same signal Device Management's "Nudof
/// Machine(M)" row shows), so an operator seeing stale power readings can
/// tell at a glance whether that's because nothing is happening or because
/// the plug itself has dropped off the network.
class _MqttStatusCard extends StatelessWidget {
  final double scale;

  const _MqttStatusCard({required this.scale});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NudofControlCubit, NudofControlState>(
      builder: (context, state) {
        return _Card(
          scale: scale,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MQTT Broker',
                      style: TextStyle(
                        fontFamily: flowhubFontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 28 * scale,
                        color: const Color(0xFF1A1C1E),
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      '${NetworkConstants.mqttBrokerHost}:${NetworkConstants.mqttBrokerPort}',
                      style: TextStyle(
                        fontFamily: flowhubFontFamily,
                        fontSize: 24 * scale,
                        color: const Color(0x941A1C1E),
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(
                scale: scale,
                on: state.isOnline,
                onLabel: 'Online',
                offLabel: 'Offline',
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Live apower/output readout + the TEST/LOG-ONLY dispensing indicator.
class _PowerStatusCard extends StatelessWidget {
  final double scale;

  const _PowerStatusCard({required this.scale});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NudofControlCubit, NudofControlState>(
      builder: (context, state) {
        final apowerText =
            state.apower == null ? '—' : '${state.apower!.toStringAsFixed(1)} W';
        return _Card(
          scale: scale,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Power Draw',
                          style: TextStyle(
                            fontFamily: flowhubFontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 28 * scale,
                            color: const Color(0xFF1A1C1E),
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        Text(
                          apowerText,
                          style: TextStyle(
                            fontFamily: flowhubFontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 32 * scale,
                            color: FlowHubColors.navy,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusPill(
                    scale: scale,
                    on: state.isOutputOn ?? false,
                    onLabel: 'Plug ON',
                    offLabel: state.isOutputOn == null ? 'Unknown' : 'Plug OFF',
                  ),
                ],
              ),
              SizedBox(height: 20 * scale),
              // TEST/LOG feature — see NudofControlCubit's class doc comment.
              // Shown here too (not just via Log.i) so it can be judged
              // on-screen in real time against what's actually happening at
              // the dispenser, without needing a logcat/console open.
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 16 * scale),
                decoration: BoxDecoration(
                  color: state.isDispensing
                      ? const Color(0xFFE1ECF3)
                      : const Color(0xFFEFF1F3),
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                child: Row(
                  children: [
                    Icon(
                      state.isDispensing ? Icons.water_drop : Icons.water_drop_outlined,
                      size: 28 * scale,
                      color: state.isDispensing ? FlowHubColors.navy : const Color(0x941A1C1E),
                    ),
                    SizedBox(width: 12 * scale),
                    Expanded(
                      child: Text(
                        state.isDispensing
                            ? 'Dispensing detected (test signal — apower threshold, not yet a confirmed production event)'
                            : 'Idle (no dispensing detected)',
                        style: TextStyle(
                          fontFamily: flowhubFontFamily,
                          fontSize: 22 * scale,
                          color: const Color(0xFF1A1C1E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Turn the Nudof plug on/off — a hardware-level power-cycle available
/// regardless of the vendor's closed Android app's own internal state, for
/// an employee to use when they visually notice a problem at the dispenser.
class _PowerControlButtons extends StatelessWidget {
  final double scale;

  const _PowerControlButtons({required this.scale});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NudofControlCubit>();
    return Row(
      children: [
        Expanded(
          child: _PowerButton(
            scale: scale,
            label: 'Turn On',
            icon: Icons.power_settings_new,
            tinted: true,
            onTap: () => _NudofConfirmDialog.show(
              context: context,
              scale: scale,
              title: 'Turn On Nudof Machine?',
              subtitle: 'Power will be restored to the dispenser.',
              actionLabel: 'Turn On',
              onConfirm: () => cubit.setPower(true),
            ),
          ),
        ),
        SizedBox(width: 24 * scale),
        Expanded(
          child: _PowerButton(
            scale: scale,
            label: 'Turn Off',
            icon: Icons.power_off,
            tinted: false,
            onTap: () => _NudofConfirmDialog.show(
              context: context,
              scale: scale,
              title: 'Turn Off Nudof Machine?',
              subtitle: 'The dispenser will lose power immediately.',
              actionLabel: 'Turn Off',
              onConfirm: () => cubit.setPower(false),
            ),
          ),
        ),
      ],
    );
  }
}

class _PowerButton extends StatelessWidget {
  final double scale;
  final String label;
  final IconData icon;
  final bool tinted;
  final VoidCallback onTap;

  const _PowerButton({
    required this.scale,
    required this.label,
    required this.icon,
    required this.tinted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = tinted ? const Color(0xFFE1ECF3) : const Color(0xFFEFF1F3);
    final border = tinted ? const Color(0xFF5FA0C0) : const Color(0x941A1C1E);

    return InkWell(
      borderRadius: BorderRadius.circular(16 * scale),
      onTap: onTap,
      child: Container(
        height: 98 * scale,
        padding: EdgeInsets.symmetric(horizontal: 24 * scale),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(color: border, width: 1 * scale),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32 * scale, color: const Color(0xFF1A1C1E)),
            SizedBox(width: 16 * scale),
            Text(
              label,
              style: TextStyle(
                fontFamily: flowhubFontFamily,
                fontWeight: FontWeight.w400,
                fontSize: 28 * scale,
                color: const Color(0xFF1A1C1E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final double scale;
  final bool on;
  final String onLabel;
  final String offLabel;

  const _StatusPill({
    required this.scale,
    required this.on,
    required this.onLabel,
    required this.offLabel,
  });

  @override
  Widget build(BuildContext context) {
    final color = on ? const Color(0xFF3895C4) : const Color(0x941A1C1E);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 10 * scale),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color, width: 1 * scale),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10 * scale,
            height: 10 * scale,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 10 * scale),
          Text(
            on ? onLabel : offLabel,
            style: TextStyle(
              fontFamily: flowhubFontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 24 * scale,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final double scale;
  final Widget child;

  const _Card({required this.scale, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0x1A1A1C1E)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xCCB6AA9B),
            blurRadius: 9 * scale,
            offset: Offset(0, 3 * scale),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Same visual family as Caye Machine Control's confirm dialog — kept as a
/// separate private copy here rather than sharing that file's private
/// widget across files.
class _NudofConfirmDialog extends StatelessWidget {
  final double scale;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onConfirm;

  const _NudofConfirmDialog({
    required this.scale,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required double scale,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierColor: const Color(0x571A1C1E),
      builder: (dialogContext) => _NudofConfirmDialog(
        scale: scale,
        title: title,
        subtitle: subtitle,
        actionLabel: actionLabel,
        onConfirm: onConfirm,
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
        width: 820 * scale,
        padding: EdgeInsets.fromLTRB(40 * scale, 32 * scale, 40 * scale, 40 * scale),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(8 * scale, 24 * scale, 8 * scale, 0),
              child: Text(
                title,
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
                subtitle,
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
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: _DialogButton(
                    scale: scale,
                    label: actionLabel,
                    bg: FlowHubColors.navy,
                    fg: Colors.white,
                    shadow: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                  ),
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
        height: 96 * scale,
        alignment: Alignment.center,
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
