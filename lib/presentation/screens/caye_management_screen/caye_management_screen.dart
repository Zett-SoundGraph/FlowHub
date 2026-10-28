import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowhub/core/constants/network.dart';
import 'package:flowhub/core/theme/app_theme.dart';
import 'package:flowhub/presentation/cubit/caye/caye_management_cubit.dart';
import 'package:flowhub/presentation/cubit/caye/caye_management_state.dart';
import 'package:flowhub/presentation/cubit/flowhub/flowhub_cubit.dart';
import 'package:flowhub/presentation/cubit/flowhub/flowhub_state.dart';
import 'package:flowhub/presentation/widgets/flowhub_sub_screen_scaffold.dart';

/// figmaImage/11_Caye Machine Control.png + its -1/-2/-3/-4 confirm-dialog
/// variants. Rinsing/Cleaning/Sync dispatch the same real MQTT commands the
/// former debug dashboard used ([CayeManagementCubit]'s existing use cases)
/// — only the visuals changed. Reboot has no backing use case anywhere in
/// the app yet (grepped for "reboot" — zero hits), so its button is
/// UI-only for now: the confirm dialog shows, but tapping "Reboot" doesn't
/// send anything real.
///
/// Note: the former dashboard also exposed Status query, Today's Data, and
/// Emergency Stop — none of those appear in this Figma design, so they're
/// dropped here rather than shoehorned in; flag if you still need them
/// reachable from somewhere.
class CayeManagementScreen extends StatelessWidget {
  final String? activeProductKey;
  final String? activeOrderNo;

  const CayeManagementScreen({
    super.key,
    this.activeProductKey,
    this.activeOrderNo,
  });

  @override
  Widget build(BuildContext context) {
    final scale = FlowHubScale.of(context);
    final cubit = context.read<CayeManagementCubit>();
    final flowhubCubit = context.read<FlowHubCubit>();
    final machineIp = NetworkConstants.cayeMachineIp;

    return FlowHubSubScreenScaffold(
      scale: scale,
      title: 'Caye Machine Control',
      headerIconAsset: 'assets/images/Caye.png',
      headerIconWidth: 32,
      headerIconHeight: 40,
      headerIconLeft: 56,
      headerTitleGap: 48,
      body: Padding(
        padding: EdgeInsets.only(left: 48 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ActionButton(
              scale: scale,
              iconAsset: 'assets/images/rinsing.png',
              iconFallback: Icons.water_drop_outlined,
              iconWidth: 32,
              iconHeight: 39.17,
              label: 'Rinsing',
              tinted: true,
              onTap: () => _CayeConfirmDialog.show(
                context: context,
                scale: scale,
                title: 'Start Rinsing the Machine?',
                subtitle: 'Hot water will be dispensed to clean the nozzles.',
                actionLabel: 'Start',
                onConfirm: () => cubit.sendRinsingCommand(machineIp),
              ),
            ),
            SizedBox(height: 32 * scale),
            _ActionButton(
              scale: scale,
              iconAsset: 'assets/images/clean.png',
              iconFallback: Icons.cleaning_services_outlined,
              iconWidth: 41.82,
              iconHeight: 44,
              label: 'Cleaning',
              tinted: true,
              onTap: () => _CayeConfirmDialog.show(
                context: context,
                scale: scale,
                title: 'Start the Cleaning Cycle?',
                subtitle:
                    'Please ensure the cleaning tablets are placed before starting.',
                actionLabel: 'Start',
                onConfirm: () => cubit.sendCleaningCommand(machineIp, mode: 0),
              ),
            ),
            SizedBox(height: 32 * scale),
            _ActionButton(
              scale: scale,
              iconAsset: 'assets/images/sync.png',
              iconFallback: Icons.sync,
              iconWidth: 39.57,
              iconHeight: 40,
              label: 'Time Synchronization',
              tinted: false,
              onTap: () => _CayeConfirmDialog.show(
                context: context,
                scale: scale,
                title: 'Sync Machine Time with FlowHub?',
                subtitle:
                    "This will synchronize the coffee machine's clock with the system time.",
                actionLabel: 'Sync',
                onConfirm: () => cubit.sendTimeSync(machineIp),
              ),
            ),
            SizedBox(height: 32 * scale),
            _ActionButton(
              scale: scale,
              iconAsset: 'assets/images/boot.png',
              iconFallback: Icons.power_settings_new,
              iconWidth: 40,
              iconHeight: 40,
              label: 'Rebooting',
              tinted: false,
              onTap: () => _CayeConfirmDialog.show(
                context: context,
                scale: scale,
                title: 'Reboot Caye Coffee Machine?',
                subtitle:
                    'The machine will be temporarily unavailable during the reboot.',
                actionLabel: 'Reboot',
                // No SendRestartCommandUseCase exists yet — nothing real to
                // call here until a confirmed protocol value is found.
                // Still routes through the cubit so a follower's tap at
                // least reaches the leader (which also currently no-ops on
                // it), keeping the 4 buttons' plumbing symmetric for when
                // one is added.
                onConfirm: () => cubit.requestReboot(),
              ),
            ),
            SizedBox(height: 32 * scale),
            _ActionButton(
              scale: scale,
              iconAsset: 'assets/images/shot_test.png',
              iconFallback: Icons.science_outlined,
              iconWidth: 40,
              iconHeight: 40,
              label: 'Shot Test (10x)',
              tinted: false,
              onTap: () => _CayeConfirmDialog.show(
                context: context,
                scale: scale,
                title: 'Run 10x Consecutive Shot Test?',
                subtitle:
                    'Brews 10 espresso shots back-to-back with no delay between them, to stress-test the machine.',
                actionLabel: 'Start',
                onConfirm: () => flowhubCubit.startConsecutiveShotTest(),
              ),
            ),
            _ShotTestStatus(scale: scale),
            SizedBox(height: 32 * scale),
            _ActionButton(
              scale: scale,
              iconAsset: 'assets/images/history.png',
              iconFallback: Icons.query_stats,
              iconWidth: 40,
              iconHeight: 40,
              label: 'Extraction History',
              tinted: false,
              onTap: () => _runExtractionHistoryQuery(
                context: context,
                scale: scale,
                cubit: cubit,
                machineIp: machineIp,
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.only(right: 48 * scale, bottom: 48 * scale),
              child: _ApiKeySection(scale: scale),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final double scale;
  final String iconAsset;
  final IconData iconFallback;
  final double iconWidth;
  final double iconHeight;
  final String label;
  final bool tinted;
  final VoidCallback onTap;

  const _ActionButton({
    required this.scale,
    required this.iconAsset,
    required this.iconFallback,
    required this.iconWidth,
    required this.iconHeight,
    required this.label,
    required this.tinted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Spec gives these as translucent fills (#5FA0C026 / #1A1C1E0A), but a
    // BoxShadow paints its full box-shaped blur *behind* the decoration, not
    // just as a thin outer glow — over a background that's 85%+ transparent,
    // the shadow's own 80%-opacity color shows through practically the whole
    // button instead of just softly at the edges, muddying it into a flat
    // brownish-gray. Using the algebraically-equivalent OPAQUE color instead
    // (the translucent color pre-blended over this screen's own solid page
    // background, #F8FAFC) renders identically to the spec's intent while
    // actually occluding the shadow correctly — verified by pixel-sampling
    // figmaImage/11_Caye Machine Control.png directly: (225,236,243) and
    // (239,241,243), which is exactly what these two hex values are.
    final bg = tinted ? const Color(0xFFE1ECF3) : const Color(0xFFEFF1F3);
    final border = tinted ? const Color(0xFF5FA0C0) : const Color(0x941A1C1E);

    return InkWell(
      borderRadius: BorderRadius.circular(16 * scale),
      onTap: onTap,
      child: Container(
        width: 568 * scale,
        height: 98 * scale,
        padding: EdgeInsets.symmetric(vertical: 24 * scale, horizontal: 32 * scale),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(color: border, width: 1 * scale),
          boxShadow: [
            BoxShadow(
              color: const Color(0xCCB6AA9B),
              blurRadius: 9 * scale,
              offset: Offset(0, 3 * scale),
            ),
          ],
        ),
        // The 4 icon assets (rinsing/clean/sync/boot.png) aren't in
        // assets/images/ yet — falls back to a Material icon of matching
        // shape/size until the real files are added.
        child: Row(
          children: [
            _FlowHubAssetOrFallback(
              asset: iconAsset,
              fallback: iconFallback,
              width: iconWidth * scale,
              height: iconHeight * scale,
              color: const Color(0xFF1A1C1E),
            ),
            SizedBox(width: 24 * scale),
            Text(
              label,
              style: TextStyle(
                fontFamily: flowhubFontFamily,
                fontWeight: FontWeight.w400,
                fontSize: 32 * scale,
                height: 50 / 32,
                letterSpacing: -0.32 * scale,
                color: const Color(0xFF1A1C1E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowHubAssetOrFallback extends StatelessWidget {
  final String asset;
  final IconData fallback;
  final double width;
  final double height;
  final Color color;

  const _FlowHubAssetOrFallback({
    required this.asset,
    required this.fallback,
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: width,
      height: height,
      color: color,
      errorBuilder: (context, error, stackTrace) =>
          Icon(fallback, size: height, color: color),
    );
  }
}

/// Bottom-of-screen setting for the Caye machine's AES encryption key — each
/// physical unit uses its own key (see CayeMachineDataSource), so swapping
/// to a different Caye machine means entering its key here. Saved to disk
/// (CayeKeyDataSource) so it survives an app restart, not just this session
/// — no Figma reference exists for this (net-new, not in the original
/// design), so it's styled to match the rest of this screen rather than
/// against a spec.
class _ApiKeySection extends StatefulWidget {
  final double scale;

  const _ApiKeySection({required this.scale});

  @override
  State<_ApiKeySection> createState() => _ApiKeySectionState();
}

class _ApiKeySectionState extends State<_ApiKeySection> {
  final _controller = TextEditingController();
  // Guards against re-overwriting the operator's in-progress typing every
  // time the cubit rebuilds — the saved key loads asynchronously (see
  // CayeManagementCubit's constructor), so the field's initial text can only
  // be set once that arrives, not synchronously at widget creation.
  bool _seeded = false;
  bool _justSaved = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    return BlocListener<CayeManagementCubit, CayeManagementState>(
      listenWhen: (previous, current) => !_seeded && current.apiKey.isNotEmpty,
      listener: (context, state) {
        _seeded = true;
        _controller.text = state.apiKey;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Caye Machine API Key',
            style: TextStyle(
              fontFamily: flowhubFontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 28 * scale,
              color: const Color(0xFF1A1C1E),
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            'Each physical machine uses a different key — update this when swapping to a different unit.',
            style: TextStyle(
              fontFamily: flowhubFontFamily,
              fontSize: 22 * scale,
              color: const Color(0x941A1C1E),
            ),
          ),
          SizedBox(height: 16 * scale),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: (_) {
                    if (_justSaved) setState(() => _justSaved = false);
                  },
                  style: TextStyle(
                    fontFamily: flowhubFontFamily,
                    fontSize: 28 * scale,
                    color: const Color(0xFF1A1C1E),
                  ),
                  decoration: InputDecoration(
                    hintText: 'AES key (hex)',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 24 * scale,
                      vertical: 20 * scale,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16 * scale),
                      borderSide: const BorderSide(color: Color(0x421A1C1E)),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16 * scale),
              InkWell(
                borderRadius: BorderRadius.circular(16 * scale),
                onTap: () {
                  final key = _controller.text.trim();
                  if (key.isEmpty) return;
                  context.read<CayeManagementCubit>().saveApiKey(key);
                  setState(() => _justSaved = true);
                },
                child: Container(
                  height: 68 * scale,
                  padding: EdgeInsets.symmetric(horizontal: 32 * scale),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: FlowHubColors.navy,
                    borderRadius: BorderRadius.circular(16 * scale),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontFamily: flowhubFontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 28 * scale,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_justSaved) ...[
            SizedBox(height: 8 * scale),
            Text(
              'Saved',
              style: TextStyle(
                fontFamily: flowhubFontFamily,
                fontSize: 22 * scale,
                color: const Color(0xFF3895C4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Confirmation popup shared by all 4 action buttons (figmaImage/
/// 11_Caye Machine Control-1/-2/-3/-4.png) — same visual family as
/// [FlowHubReprintLabelDialog], widened to 820. Height is intentionally NOT
/// fixed to the spec's own 358 (that number came from measuring the
/// Rinsing instance specifically, whose subtitle is one line) — the other
/// three subtitles wrap to two lines, which this exact padding/gap math
/// grows to 394 for automatically; a hardcoded 358 would overflow those.
class _CayeConfirmDialog extends StatelessWidget {
  final double scale;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onConfirm;

  const _CayeConfirmDialog({
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
      builder: (dialogContext) => _CayeConfirmDialog(
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
              // Inset symmetrically (not just on the left) — pixel-measuring
              // the reference dialogs shows the subtitle wraps at a width
              // narrower than "container padding + left-only 8", matching a
              // mirrored right inset instead.
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

/// Live elapsed-time + shot-count readout under the Shot Test button —
/// ticks every second while a test is in progress (FlowHubState.shotTestTotal >
/// 0 and not yet finished), then freezes at the final elapsed time once
/// FlowHubState.shotTestFinishedAt is stamped. Hidden entirely before the first
/// test this session (shotTestTotal == 0). See
/// FlowHubCubit.startConsecutiveShotTest/_recordShotTestCompletion for where
/// these FlowHubState fields are set.
class _ShotTestStatus extends StatefulWidget {
  final double scale;

  const _ShotTestStatus({required this.scale});

  @override
  State<_ShotTestStatus> createState() => _ShotTestStatusState();
}

class _ShotTestStatusState extends State<_ShotTestStatus> {
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  String _formatElapsed(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    return BlocBuilder<FlowHubCubit, FlowHubState>(
      builder: (context, state) {
        if (state.shotTestTotal == 0) return const SizedBox.shrink();

        final startedAt = state.shotTestStartedAt;
        final finishedAt = state.shotTestFinishedAt;
        final isDone = finishedAt != null;
        final elapsed = startedAt == null
            ? Duration.zero
            : (finishedAt ?? DateTime.now()).difference(startedAt);
        final currentShot =
            isDone ? state.shotTestTotal : (state.shotTestCompleted + 1).clamp(1, state.shotTestTotal);

        return Padding(
          padding: EdgeInsets.only(top: 16 * scale, left: 8 * scale),
          child: Row(
            children: [
              Icon(
                isDone ? Icons.check_circle_outline : Icons.timer_outlined,
                size: 24 * scale,
                color: isDone ? Colors.green : FlowHubColors.navy,
              ),
              SizedBox(width: 8 * scale),
              Text(
                isDone
                    ? 'Done — ${state.shotTestTotal}/${state.shotTestTotal} shots in ${_formatElapsed(elapsed)}'
                    : 'Shot $currentShot/${state.shotTestTotal} — ${_formatElapsed(elapsed)}',
                style: TextStyle(
                  fontFamily: flowhubFontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 24 * scale,
                  color: const Color(0xFF1A1C1E),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Orchestrates the Extraction History test button: pick a time range, send
/// the 0x35 query, wait for the response, then show the parsed result.
Future<void> _runExtractionHistoryQuery({
  required BuildContext context,
  required double scale,
  required CayeManagementCubit cubit,
  required String machineIp,
}) async {
  final range = await _ExtractionHistoryRangeDialog.show(context: context, scale: scale);
  if (range == null || !context.mounted) return;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  final result = await cubit.queryExtractionHistory(
    machineIp,
    startTs: range.startTs,
    endTs: range.endTs,
  );

  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pop(); // dismiss the loading spinner

  if (!context.mounted) return;
  await _ExtractionHistoryResultDialog.show(
    context: context,
    scale: scale,
    records: result.records,
    timedOut: result.timedOut,
  );
}

/// Start/end time picker for the Extraction History query — 0x35 requires a
/// non-empty startTs/endTs range (see
/// CayeMachineDataSource.sendExtractionHistory), so unlike the other 4
/// action buttons above this can't be a plain confirm dialog. No Figma
/// reference exists for this (net-new debug tool, not in the original
/// design), so it's styled to match the rest of this screen rather than
/// against a spec (same reasoning as [_ApiKeySection]). Defaults to "the
/// last 15 minutes" since this is typically used right after running a test
/// batch (e.g. the Shot Test button above).
class _ExtractionHistoryRangeDialog extends StatefulWidget {
  final double scale;

  const _ExtractionHistoryRangeDialog({required this.scale});

  static Future<({int startTs, int endTs})?> show({
    required BuildContext context,
    required double scale,
  }) {
    return showDialog<({int startTs, int endTs})>(
      context: context,
      barrierColor: const Color(0x571A1C1E),
      builder: (_) => _ExtractionHistoryRangeDialog(scale: scale),
    );
  }

  @override
  State<_ExtractionHistoryRangeDialog> createState() =>
      _ExtractionHistoryRangeDialogState();
}

class _ExtractionHistoryRangeDialogState extends State<_ExtractionHistoryRangeDialog> {
  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();
    _end = DateTime.now();
    _start = _end.subtract(const Duration(minutes: 15));
  }

  Future<void> _pick(bool isStart) async {
    final current = isStart ? _start : _end;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null || !mounted) return;
    final picked =
        DateTime(date.year, date.month, date.day, time.hour, time.minute, current.second);
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  String _format(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final isValidRange = _start.isBefore(_end);

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
                'Query Extraction History',
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
                'Select the time range to fetch brew records for (make time, powder weight, grind time, extract time, target extract time).',
                style: TextStyle(
                  fontFamily: flowhubFontFamily,
                  fontSize: 24 * scale,
                  height: 32 / 24,
                  letterSpacing: -0.24 * scale,
                  color: const Color(0x941A1C1E),
                ),
              ),
            ),
            SizedBox(height: 32 * scale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8 * scale),
              child: Column(
                children: [
                  _RangeRow(
                    scale: scale,
                    label: 'Start',
                    value: _format(_start),
                    onTap: () => _pick(true),
                  ),
                  SizedBox(height: 16 * scale),
                  _RangeRow(
                    scale: scale,
                    label: 'End',
                    value: _format(_end),
                    onTap: () => _pick(false),
                  ),
                  if (!isValidRange) ...[
                    SizedBox(height: 12 * scale),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Start must be before End.',
                        style: TextStyle(
                          fontFamily: flowhubFontFamily,
                          fontSize: 20 * scale,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 48 * scale),
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
                    label: 'Query',
                    bg: isValidRange ? FlowHubColors.navy : const Color(0x421A1C1E),
                    fg: Colors.white,
                    shadow: isValidRange,
                    onTap: isValidRange
                        ? () => Navigator.of(context).pop((
                              startTs: _start.millisecondsSinceEpoch,
                              endTs: _end.millisecondsSinceEpoch,
                            ))
                        : () {},
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

class _RangeRow extends StatelessWidget {
  final double scale;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _RangeRow({
    required this.scale,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16 * scale),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 20 * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(color: const Color(0x421A1C1E)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 100 * scale,
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
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: flowhubFontFamily,
                  fontSize: 24 * scale,
                  color: const Color(0xFF1A1C1E),
                ),
              ),
            ),
            Icon(Icons.edit_calendar_outlined, size: 24 * scale, color: const Color(0x941A1C1E)),
          ],
        ),
      ),
    );
  }
}

/// Shows the parsed 0x35 response — one row per beverageList[] entry, in the
/// order the machine returned them. See [CayeExtractionRecord] for which 5
/// fields are shown and why.
class _ExtractionHistoryResultDialog extends StatelessWidget {
  final double scale;
  final List<CayeExtractionRecord> records;
  final bool timedOut;

  const _ExtractionHistoryResultDialog({
    required this.scale,
    required this.records,
    required this.timedOut,
  });

  static Future<void> show({
    required BuildContext context,
    required double scale,
    required List<CayeExtractionRecord> records,
    required bool timedOut,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0x571A1C1E),
      builder: (_) =>
          _ExtractionHistoryResultDialog(scale: scale, records: records, timedOut: timedOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      elevation: 0,
      child: Container(
        width: 900 * scale,
        constraints: BoxConstraints(maxHeight: 900 * scale),
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
            Text(
              timedOut
                  ? 'No Response (Timed Out)'
                  : records.isEmpty
                      ? 'No Records Found'
                      : 'Extraction History (${records.length})',
              style: TextStyle(
                fontFamily: flowhubFontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 36 * scale,
                height: 50 / 36,
                letterSpacing: -0.36 * scale,
                color: FlowHubColors.textPrimary87,
              ),
            ),
            SizedBox(height: 24 * scale),
            if (timedOut)
              Text(
                'The machine never responded within 10s — it may be busy, disconnected, or slow. '
                'Check the [Caye] log for "[Sent] 0x35" / "[Received] 0x35" to confirm.',
                style: TextStyle(
                  fontFamily: flowhubFontFamily,
                  fontSize: 24 * scale,
                  color: const Color(0x941A1C1E),
                ),
              )
            else if (records.isEmpty)
              Text(
                'The machine responded, but no records exist in the selected time range — '
                'try widening it, or confirm a brew actually happened within it.',
                style: TextStyle(
                  fontFamily: flowhubFontFamily,
                  fontSize: 24 * scale,
                  color: const Color(0x941A1C1E),
                ),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < records.length; i++) ...[
                        if (i > 0) Divider(height: 32 * scale, color: const Color(0x1F1A1C1E)),
                        _RecordRow(scale: scale, index: i + 1, record: records[i]),
                      ],
                    ],
                  ),
                ),
              ),
            SizedBox(height: 32 * scale),
            _DialogButton(
              scale: scale,
              label: 'Close',
              bg: FlowHubColors.navy,
              fg: Colors.white,
              shadow: true,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final double scale;
  final int index;
  final CayeExtractionRecord record;

  const _RecordRow({required this.scale, required this.index, required this.record});

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontFamily: flowhubFontFamily,
      fontSize: 20 * scale,
      color: const Color(0x941A1C1E),
    );
    final valueStyle = TextStyle(
      fontFamily: flowhubFontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 24 * scale,
      color: const Color(0xFF1A1C1E),
    );

    Widget field(String label, String value) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: labelStyle),
              SizedBox(height: 4 * scale),
              Text(value, style: valueStyle),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shot $index',
          style: TextStyle(
            fontFamily: flowhubFontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 24 * scale,
            color: FlowHubColors.navy,
          ),
        ),
        SizedBox(height: 12 * scale),
        Row(
          children: [
            field('Make Time (s)', record.makeTime.toStringAsFixed(1)),
            field('Powder Weight (g)', record.powderWeight.toStringAsFixed(1)),
          ],
        ),
        SizedBox(height: 12 * scale),
        Row(
          children: [
            field('Grind Time (s)', record.grindTime.toStringAsFixed(1)),
            field('Extract Time (s)', record.extractTime.toStringAsFixed(1)),
            field('Target Extract (s)', record.targetExtractTime.toStringAsFixed(1)),
          ],
        ),
      ],
    );
  }
}
