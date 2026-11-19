import 'dart:async';

import 'package:flowhub/core/utils/log.dart';
import 'package:flowhub/domain/entities/device/device.dart';
import 'package:flowhub/domain/entities/flow_installation/store_device.dart';
import 'package:flowhub/domain/repositories/device_repository.dart';
import 'package:flowhub/domain/repositories/flow_installation_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// A reminder to show: [sequence] goes up by one for each new reminder.
typedef UpdateReminder = ({int sequence, int updatableCount});

/// Decides when the leader shows the "Flow App update available" snackbar.
///
/// Knowing about an update and showing it are separate:
/// - FlowManager announces versions on the cloud broker
///   ([FlowInstallationRepository.versionNotices]); each notice re-reads the
///   store's devices and keeps how many can be updated.
/// - The snackbar is shown only at quiet moments, when that count is above 0:
///   start of day ([sodHour]) or end of day ([eodHour]), once per day each
///   within [slotWindow]; or idle (the screen reports only DONE orders).
///
/// Never shown again within [minInterval]. The times are provisional.
@injectable
class UpdateReminderCubit extends Cubit<UpdateReminder> {
  UpdateReminderCubit(this._devices, this._installation)
    : super((sequence: 0, updatableCount: 0)) {
    _noticeSubscription = _installation.versionNotices.listen(
      (_) => unawaited(_refresh()),
    );
    unawaited(_refresh());
  }

  static const String _tag = 'UpdateReminder';

  /// Start of day (06:00) and end of day (18:00), local time. Provisional.
  static const int sodHour = 6;
  static const int eodHour = 18;

  /// How long after SOD / EOD the reminder can still fire.
  static const Duration slotWindow = Duration(hours: 1);

  /// No new reminder within this long of the last one.
  static const Duration minInterval = Duration(hours: 1);

  /// While idle, a reminder is considered at most this often.
  static const Duration idleCheckInterval = Duration(minutes: 10);

  final DeviceRepository _devices;
  final FlowInstallationRepository _installation;
  StreamSubscription<void>? _noticeSubscription;

  /// Devices with an update, from the last read of the device list.
  int _updatable = 0;
  DateTime? _lastShownAt;
  DateTime? _lastIdleCheckAt;
  final Set<String> _firedSlots = <String>{};
  bool _checking = false;

  /// Called every minute and when the orders change.
  /// 1. Skips while a check runs, within [minInterval] of the last reminder,
  ///    or when no update is known.
  /// 2. Needs a due SOD / EOD slot, or [idle] (throttled to
  ///    [idleCheckInterval]).
  /// 3. Re-reads the device list to confirm (an update may have finished
  ///    since), then emits a reminder when any device can still be updated.
  Future<void> check({required bool idle}) async {
    final DateTime now = DateTime.now();
    final DateTime? lastShown = _lastShownAt;
    if (_checking ||
        _updatable == 0 ||
        (lastShown != null && now.difference(lastShown) < minInterval)) {
      return;
    }
    final String? slot = _dueSlot(now);
    final DateTime? lastIdle = _lastIdleCheckAt;
    final bool idleDue = idle &&
        (lastIdle == null || now.difference(lastIdle) >= idleCheckInterval);
    if (slot == null && !idleDue) {
      return;
    }
    _checking = true;
    try {
      if (slot != null) {
        _firedSlots.add(slot);
      }
      if (idleDue) {
        _lastIdleCheckAt = now;
      }
      await _refresh();
      if (isClosed || _updatable == 0) {
        return;
      }
      _lastShownAt = DateTime.now();
      Log.i(_tag, 'Reminder (${slot ?? 'idle'}): $_updatable device(s)');
      emit((sequence: state.sequence + 1, updatableCount: _updatable));
    } finally {
      _checking = false;
    }
  }

  /// `yyyy-mm-dd-SOD` / `-EOD` when [now] is within [slotWindow] after that
  /// slot's time and it has not fired today; otherwise `null`.
  String? _dueSlot(DateTime now) {
    final String day = '${now.year}-${now.month}-${now.day}';
    for (final ({int hour, String name}) slot in <({int hour, String name})>[
      (hour: sodHour, name: 'SOD'),
      (hour: eodHour, name: 'EOD'),
    ]) {
      final DateTime start = DateTime(now.year, now.month, now.day, slot.hour);
      final String key = '$day-${slot.name}';
      if (!now.isBefore(start) &&
          now.isBefore(start.add(slotWindow)) &&
          !_firedSlots.contains(key)) {
        return key;
      }
    }
    return null;
  }

  /// Re-reads how many of the store's devices have an update. Keeps the last
  /// count on any error (FlowUpdater or FlowManager not reachable).
  Future<void> _refresh() async {
    try {
      final Device device = await _devices.getDeviceInfo();
      if (device.storeId.isEmpty) {
        return;
      }
      final StoreDevices devices =
          await _installation.getStoreDevices(device.storeId);
      if (_updatable != devices.updatable.length) {
        Log.i(_tag, 'Updatable devices: ${devices.updatable.length}');
      }
      _updatable = devices.updatable.length;
    } catch (e) {
      Log.w(_tag, 'Device state failed: $e');
    }
  }

  @override
  Future<void> close() async {
    await _noticeSubscription?.cancel();
    return super.close();
  }
}
