import 'package:flowhub/core/theme/app_theme.dart';
import 'package:flowhub/domain/entities/flow_installation/flow_app_update_progress.dart';
import 'package:flowhub/domain/entities/flow_installation/store_device.dart';
import 'package:flowhub/presentation/cubit/update_manager/update_manager_cubit.dart';
import 'package:flowhub/presentation/cubit/update_manager/update_manager_state.dart';
import 'package:flowhub/presentation/widgets/flowhub_sub_screen_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Flow Installation: the store's devices, their Flow App versions, update
/// buttons and live update progress. Basic layout until the design is final.
class UpdateManagerScreen extends StatelessWidget {
  const UpdateManagerScreen({super.key});

  static const Color _text = Color(0xFF1A1C1E);
  static const Color _subText = Color(0x941A1C1E);
  static const Color _accent = Color(0xFF3895C4);

  @override
  Widget build(BuildContext context) {
    final double scale = FlowHubScale.of(context);
    return FlowHubSubScreenScaffold(
      scale: scale,
      title: 'Update Manager',
      headerIconAsset: 'assets/images/sync.png',
      headerIconWidth: 40,
      headerIconHeight: 40,
      headerIconLeft: 56,
      headerTitleGap: 48,
      body: BlocBuilder<UpdateManagerCubit, UpdateManagerState>(
        builder: (BuildContext context, UpdateManagerState state) {
          final UpdateManagerCubit cubit = context.read<UpdateManagerCubit>();
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 48 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _Toolbar(scale: scale, state: state, cubit: cubit),
                if (state.message != null) ...<Widget>[
                  SizedBox(height: 16 * scale),
                  _MessageBox(scale: scale, message: state.message!),
                ],
                SizedBox(height: 24 * scale),
                Expanded(child: _body(scale, state, cubit)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _body(double scale, UpdateManagerState state, UpdateManagerCubit cubit) {
    if (state.status == UpdateManagerStatus.loading && state.devices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.devices.isEmpty) {
      return Center(
        child: Text(
          state.status == UpdateManagerStatus.error
              ? 'Could not load the store devices.'
              : 'No devices in this store.',
          style: _style(scale, 26, _subText),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 48 * scale),
      itemCount: state.devices.length,
      separatorBuilder: (_, __) => SizedBox(height: 16 * scale),
      itemBuilder: (BuildContext context, int index) {
        final StoreDevice device = state.devices[index];
        return _DeviceCard(
          scale: scale,
          device: device,
          progress: state.progress[device.deviceId],
          requesting: state.requesting.contains(device.deviceId),
          onUpdate: () => cubit.update(device.deviceId),
        );
      },
    );
  }

  static TextStyle _style(
    double scale,
    double size,
    Color color, {
    FontWeight weight = FontWeight.w400,
  }) => TextStyle(
    fontFamily: flowhubFontFamily,
    fontSize: size * scale,
    fontWeight: weight,
    color: color,
  );
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.scale, required this.state, required this.cubit});

  final double scale;
  final UpdateManagerState state;
  final UpdateManagerCubit cubit;

  @override
  Widget build(BuildContext context) {
    final int updatable =
        state.devices.where((StoreDevice d) => d.updateAvailable).length;
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            '$updatable update(s) available'
            '${state.pending > 0 ? ' · ${state.pending} in progress' : ''}',
            style: UpdateManagerScreen._style(
              scale,
              28,
              UpdateManagerScreen._text,
              weight: FontWeight.w700,
            ),
          ),
        ),
        OutlinedButton(
          onPressed: state.status == UpdateManagerStatus.loading
              ? null
              : cubit.load,
          child: Text('Refresh', style: UpdateManagerScreen._style(scale, 24, UpdateManagerScreen._accent)),
        ),
        SizedBox(width: 16 * scale),
        FilledButton(
          onPressed: updatable == 0 || state.requesting.isNotEmpty
              ? null
              : cubit.updateAll,
          child: Text('Update all', style: UpdateManagerScreen._style(scale, 24, Colors.white)),
        ),
      ],
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({required this.scale, required this.message});

  final double scale;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(20 * scale),
    decoration: BoxDecoration(
      color: UpdateManagerScreen._accent.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12 * scale),
    ),
    child: Text(
      message,
      style: UpdateManagerScreen._style(scale, 22, UpdateManagerScreen._text),
    ),
  );
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.scale,
    required this.device,
    required this.progress,
    required this.requesting,
    required this.onUpdate,
  });

  final double scale;
  final StoreDevice device;
  final FlowAppUpdateProgress? progress;
  final bool requesting;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final FlowAppUpdateProgress? live = progress;
    final bool running = live != null && !live.isFinal;
    return Container(
      padding: EdgeInsets.all(28 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0x1A1A1C1E)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  device.deviceName.isEmpty ? device.deviceId : device.deviceName,
                  style: UpdateManagerScreen._style(
                    scale,
                    28,
                    UpdateManagerScreen._text,
                    weight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  '${device.appType} · ${device.deviceStatus}',
                  style: UpdateManagerScreen._style(scale, 22, UpdateManagerScreen._subText),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  _versionText(),
                  style: UpdateManagerScreen._style(scale, 24, UpdateManagerScreen._text),
                ),
                if (live != null) ...<Widget>[
                  SizedBox(height: 12 * scale),
                  _ProgressLine(scale: scale, report: live),
                ],
              ],
            ),
          ),
          SizedBox(width: 24 * scale),
          FilledButton(
            onPressed: device.updateAvailable && !requesting && !running
                ? onUpdate
                : null,
            child: requesting
                ? SizedBox(
                    width: 24 * scale,
                    height: 24 * scale,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Update', style: UpdateManagerScreen._style(scale, 24, Colors.white)),
          ),
        ],
      ),
    );
  }

  String _versionText() {
    final String current =
        device.currentVersion.isEmpty ? '—' : device.currentVersion;
    if (!device.updateAvailable) {
      return 'Version $current (latest)';
    }
    return 'Version $current → ${device.latestVersion}';
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.scale, required this.report});

  final double scale;
  final FlowAppUpdateProgress report;

  @override
  Widget build(BuildContext context) {
    final bool failed = report.state == 'FAILED';
    final Color color = failed ? const Color(0xFFD32F2F) : UpdateManagerScreen._accent;
    final int? percent = report.progress;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          _label(),
          style: UpdateManagerScreen._style(scale, 22, color, weight: FontWeight.w700),
        ),
        if (report.state == 'DOWNLOADING' && percent != null) ...<Widget>[
          SizedBox(height: 8 * scale),
          LinearProgressIndicator(value: percent / 100, color: color),
        ],
      ],
    );
  }

  /// e.g. "DOWNLOADING 40% (attempt 1/3)", "WAITING — SERVING_ORDER".
  String _label() {
    final StringBuffer text = StringBuffer(report.state);
    if (report.state == 'DOWNLOADING' && report.progress != null) {
      text.write(' ${report.progress}%');
    }
    if (report.attempt != null && report.maxAttempts != null) {
      text.write(' (attempt ${report.attempt}/${report.maxAttempts})');
    }
    final String? why = report.waitReason ?? report.reason;
    if (why != null && why.isNotEmpty) {
      text.write(' — $why');
    }
    if (report.rolledBack == true) {
      text.write(' — rolled back');
    }
    return text.toString();
  }
}
