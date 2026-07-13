import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kds/domain/repositories/order_repository.dart';
import 'package:kds/presentation/cubit/fleet_monitor/fleet_monitor_cubit.dart';
import 'package:kds/presentation/cubit/fleet_monitor/fleet_monitor_state.dart';

/// Shows every device seen on `beta/system/heartbeat/+`, independent of
/// whatever the Message Hub dashboard itself displays.
///
/// Two view modes (toggle at the top):
/// - Log: every heartbeat event as it arrives, newest first, with topic/
///   payload/QoS/retain detail — for debugging whether messages are really
///   being received.
/// - Summary: one row per device showing only its most recent last-seen time.
class FleetMonitorDialog extends StatefulWidget {
  const FleetMonitorDialog({super.key});

  @override
  State<FleetMonitorDialog> createState() => _FleetMonitorDialogState();
}

class _FleetMonitorDialogState extends State<FleetMonitorDialog> {
  // Ticks once a second purely to refresh the "Xs ago" labels in summary
  // view — the underlying data is already updated live via FleetMonitorCubit.
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

  String _formatAgo(DateTime lastSeen) {
    final seconds = DateTime.now().difference(lastSeen).inSeconds;
    if (seconds < 60) return '${seconds}s ago';
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '${minutes}m ago';
    return '${minutes ~/ 60}h ago';
  }

  String _formatClock(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}:'
      '${time.second.toString().padLeft(2, '0')}.'
      '${time.millisecond.toString().padLeft(3, '0')}';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text('Fleet Status',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 480,
        child: BlocBuilder<FleetMonitorCubit, FleetMonitorState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<FleetMonitorViewMode>(
                  segments: const [
                    ButtonSegment(
                      value: FleetMonitorViewMode.log,
                      label: Text('Log'),
                      icon: Icon(Icons.list_alt),
                    ),
                    ButtonSegment(
                      value: FleetMonitorViewMode.summary,
                      label: Text('Summary'),
                      icon: Icon(Icons.dashboard),
                    ),
                  ],
                  selected: {state.viewMode},
                  onSelectionChanged: (selection) => context
                      .read<FleetMonitorCubit>()
                      .setViewMode(selection.first),
                ),
                const SizedBox(height: 12),
                if (state.viewMode == FleetMonitorViewMode.log)
                  _LogView(entries: state.logEntries, formatClock: _formatClock)
                else
                  _SummaryView(
                    deviceLastSeen: state.deviceLastSeen,
                    formatAgo: _formatAgo,
                  ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _LogView extends StatelessWidget {
  final List<FleetHeartbeatEvent> entries;
  final String Function(DateTime) formatClock;

  const _LogView({required this.entries, required this.formatClock});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text('No heartbeats received yet.',
            style: TextStyle(color: Colors.white54)),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 420),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: entries.length,
        separatorBuilder: (_, __) => const Divider(color: Colors.white12),
        itemBuilder: (context, index) {
          final e = entries[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(formatClock(e.timestamp),
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                    Text(e.deviceId,
                        style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold)),
                    Text(
                      'QoS=${e.qos.replaceFirst('MqttQos.', '')} retain=${e.retain}',
                      style: const TextStyle(
                          color: Colors.orangeAccent, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('topic: ${e.topic}',
                    softWrap: true,
                    style: const TextStyle(color: Colors.white38, fontSize: 11)),
                Text('payload: ${e.payload}',
                    softWrap: true,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryView extends StatelessWidget {
  final Map<String, DateTime> deviceLastSeen;
  final String Function(DateTime) formatAgo;

  const _SummaryView({required this.deviceLastSeen, required this.formatAgo});

  @override
  Widget build(BuildContext context) {
    final entries = deviceLastSeen.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text('No devices seen yet.',
            style: TextStyle(color: Colors.white54)),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: entries.length,
        separatorBuilder: (_, __) => const Divider(color: Colors.white12),
        itemBuilder: (context, index) {
          final entry = entries[index];
          final secondsAgo = DateTime.now().difference(entry.value).inSeconds;
          // Rough visual cue only (>60s since our own heartbeat cadence is
          // 30s) — not an authoritative online/offline judgment.
          final isStale = secondsAgo > 60;
          return ListTile(
            dense: true,
            leading: Icon(Icons.circle,
                size: 12, color: isStale ? Colors.redAccent : Colors.greenAccent),
            title:
                Text(entry.key, style: const TextStyle(color: Colors.white)),
            trailing: Text(
              formatAgo(entry.value),
              style: TextStyle(
                  color: isStale ? Colors.redAccent : Colors.white54),
            ),
          );
        },
      ),
    );
  }
}
