import 'dart:async';

import 'package:flowhub/core/utils/log.dart';
import 'package:flowhub/domain/entities/device/device.dart';
import 'package:flowhub/domain/entities/flow_installation/flow_app_update_progress.dart';
import 'package:flowhub/domain/entities/flow_installation/store_device.dart';
import 'package:flowhub/domain/entities/flow_installation/update_request_result.dart';
import 'package:flowhub/domain/repositories/device_repository.dart';
import 'package:flowhub/domain/repositories/flow_installation_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'update_manager_state.dart';

/// Update Manager screen (Flow Installation, leader only): lists the store's
/// devices with their Flow App versions, sends update requests through
/// FlowManager and shows each device's progress live.
@injectable
class UpdateManagerCubit extends Cubit<UpdateManagerState> {
  UpdateManagerCubit(this._devices, this._installation)
    : super(const UpdateManagerState());

  static const String _tag = 'UpdateManager';

  /// Wait after a final report before re-reading the device list, so
  /// FlowManager has stored the new version.
  static const Duration _refreshAfterFinal = Duration(seconds: 3);

  final DeviceRepository _devices;
  final FlowInstallationRepository _installation;

  StreamSubscription<FlowAppUpdateProgress>? _progressSubscription;
  Timer? _refreshTimer;

  /// 1. Reads the store ID from the FlowUpdater device record; an
  ///    unregistered device shows an error.
  /// 2. Starts watching progress reports for that store (once).
  /// 3. Loads the device list.
  Future<void> load() async {
    emit(state.copyWith(status: UpdateManagerStatus.loading, message: null));
    final Device device;
    try {
      device = await _devices.getDeviceInfo();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          status: UpdateManagerStatus.error,
          message: 'Device info unavailable: $e',
        ));
      }
      return;
    }
    if (isClosed) {
      return;
    }
    final String storeId = device.storeId;
    if (storeId.isEmpty) {
      emit(state.copyWith(
        status: UpdateManagerStatus.error,
        message: 'This device is not registered to a store yet',
      ));
      return;
    }
    if (_progressSubscription == null || state.storeId != storeId) {
      await _progressSubscription?.cancel();
      _progressSubscription =
          _installation.watchProgress(storeId).listen(_onProgress);
    }
    emit(state.copyWith(storeId: storeId));
    await refresh();
  }

  /// Re-reads the device list from FlowManager.
  Future<void> refresh() async {
    if (state.storeId.isEmpty) {
      return;
    }
    try {
      final StoreDevices r = await _installation.getStoreDevices(state.storeId);
      if (isClosed) {
        return;
      }
      emit(state.copyWith(
        status: UpdateManagerStatus.ready,
        devices: r.devices,
        pending: r.pending,
        loadedAt: DateTime.now(),
      ));
    } catch (e) {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(
        status: state.devices.isEmpty
            ? UpdateManagerStatus.error
            : UpdateManagerStatus.ready,
        message: 'Failed to load devices: $e',
      ));
    }
  }

  /// Requests the latest build for one device.
  Future<void> update(String deviceId) => _request(<String>[deviceId]);

  /// Requests the latest build for every device that has an update.
  Future<void> updateAll() => _request(
    state.devices
        .where((StoreDevice d) => d.updateAvailable)
        .map((StoreDevice d) => d.deviceId)
        .toList(),
  );

  /// 1. Marks the devices as requesting, sends the request.
  /// 2. Shows a one-line summary (queued / skipped / rejected), then reloads.
  Future<void> _request(List<String> deviceIds) async {
    if (deviceIds.isEmpty) {
      return;
    }
    emit(state.copyWith(
      requesting: <String>{...state.requesting, ...deviceIds},
      message: null,
    ));
    String message;
    try {
      message = _summary(await _installation.requestUpdates(deviceIds));
    } catch (e) {
      message = 'Update request failed: $e';
    }
    if (isClosed) {
      return;
    }
    final Set<String> requesting = <String>{...state.requesting}
      ..removeAll(deviceIds);
    emit(state.copyWith(requesting: requesting, message: message));
    await refresh();
  }

  String _summary(List<UpdateRequestResult> results) {
    final int queued =
        results.where((UpdateRequestResult r) => r.isQueued).length;
    final List<String> lines = <String>['Update requested for $queued device(s)'];
    for (final UpdateRequestResult r in results) {
      if (r.isQueued) {
        continue;
      }
      final String name = r.deviceName.isEmpty ? r.deviceId : r.deviceName;
      final String reason = r.message.isEmpty ? '' : ' (${r.message})';
      lines.add('$name: ${r.result}$reason');
    }
    return lines.join('\n');
  }

  /// Keeps the highest-seq report per device; a final report (COMPLETED /
  /// FAILED) re-reads the device list shortly after.
  void _onProgress(FlowAppUpdateProgress report) {
    final FlowAppUpdateProgress? current = state.progress[report.deviceId];
    if (current != null &&
        current.requestId == report.requestId &&
        current.seq > report.seq) {
      return;
    }
    final String percent =
        report.progress == null ? '' : ' ${report.progress}%';
    Log.d(_tag, '${report.deviceId} ${report.state}$percent');
    emit(state.copyWith(
      progress: <String, FlowAppUpdateProgress>{
        ...state.progress,
        report.deviceId: report,
      },
    ));
    if (report.isFinal) {
      _refreshTimer?.cancel();
      _refreshTimer = Timer(_refreshAfterFinal, () => unawaited(refresh()));
    }
  }

  @override
  Future<void> close() async {
    _refreshTimer?.cancel();
    await _progressSubscription?.cancel();
    return super.close();
  }
}
