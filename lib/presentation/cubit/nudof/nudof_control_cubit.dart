import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flowhub/core/utils/log.dart';
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/usecases/get_nudof_online_snapshot_usecase.dart';
import 'package:flowhub/domain/usecases/observe_nudof_online_usecase.dart';
import 'package:flowhub/domain/usecases/observe_nudof_power_usecase.dart';
import 'package:flowhub/domain/usecases/set_nudof_power_usecase.dart';

import 'nudof_control_state.dart';

/// Drives the "Nudof Machine Control" drawer tab: on/off control for the
/// Shelly Plug M Gen3 monitoring the Nudof dispenser's power draw, plus a
/// power-change → dispensing-start/end detector.
///
/// That detector is deliberately TEST/LOG-ONLY for now, per direct request —
/// not wired to any real production event yet. [_dispensingOnWatts] /
/// [_dispensingOffWatts] / [_requiredStreak] are unconfirmed placeholder
/// values; every raw reading and every detected transition is logged
/// verbosely (search this tag) specifically so real on-site behavior can be
/// observed and these tuned before this becomes a real signal — watching
/// for both failure modes that motivated keeping this log-only: (1) a false
/// positive, where apower spikes with nothing actually dispensing, and (2) a
/// false negative, where a real pour never crosses the threshold or drops
/// back before the streak requirement is met.
@injectable
class NudofControlCubit extends Cubit<NudofControlState> {
  static const _tag = 'NudofControlCubit';

  final ObserveNudofOnlineUseCase _observeOnline;
  final GetNudofOnlineSnapshotUseCase _getOnlineSnapshot;
  final ObserveNudofPowerUseCase _observePower;
  final SetNudofPowerUseCase _setPower;

  StreamSubscription<bool>? _onlineSubscription;
  StreamSubscription<NudofPowerReading>? _powerSubscription;

  // Separate on/off thresholds (hysteresis) plus a minimum consecutive-
  // reading streak — both exist so a single noisy spike can't flip the
  // detected state on its own. UNCONFIRMED — tune once real dispensing
  // apower is observed in the log.
  static const double _dispensingOnWatts = 20.0;
  static const double _dispensingOffWatts = 8.0;
  static const int _requiredStreak = 2;

  int _aboveStreak = 0;
  int _belowStreak = 0;

  NudofControlCubit({
    required ObserveNudofOnlineUseCase observeOnline,
    required GetNudofOnlineSnapshotUseCase getOnlineSnapshot,
    required ObserveNudofPowerUseCase observePower,
    required SetNudofPowerUseCase setPower,
  })  : _observeOnline = observeOnline,
        _getOnlineSnapshot = getOnlineSnapshot,
        _observePower = observePower,
        _setPower = setPower,
        super(const NudofControlState()) {
    // Seed from the CURRENT online state first — onlineStream is a plain
    // broadcast stream that only replays FUTURE transitions, so a cubit
    // created after the plug already reported online (e.g. reopening this
    // screen) would otherwise show offline forever. Same pattern as
    // CayeManagementCubit's own connection seeding.
    emit(state.copyWith(isOnline: _getOnlineSnapshot()));
    _onlineSubscription = _observeOnline().listen((online) {
      emit(state.copyWith(isOnline: online));
    });
    _powerSubscription = _observePower().listen(_handlePowerReading);
  }

  void _handlePowerReading(NudofPowerReading reading) {
    Log.d(
      _tag,
      'power reading: output=${reading.output} apower=${reading.apower}W '
      'voltage=${reading.voltage}V current=${reading.current}A',
    );

    if (reading.apower >= _dispensingOnWatts) {
      _aboveStreak++;
      _belowStreak = 0;
    } else if (reading.apower <= _dispensingOffWatts) {
      _belowStreak++;
      _aboveStreak = 0;
    }
    // A mid-band reading (between the two thresholds) extends neither
    // streak, but doesn't reset one already in progress either.

    final wasDispensing = state.isDispensing;
    var isDispensing = wasDispensing;
    if (!wasDispensing && _aboveStreak >= _requiredStreak) {
      isDispensing = true;
      Log.i(
        _tag,
        'DISPENSING START detected — apower=${reading.apower}W '
        '(>= ${_dispensingOnWatts}W for $_aboveStreak consecutive readings)',
      );
    } else if (wasDispensing && _belowStreak >= _requiredStreak) {
      isDispensing = false;
      Log.i(
        _tag,
        'DISPENSING END detected — apower=${reading.apower}W '
        '(<= ${_dispensingOffWatts}W for $_belowStreak consecutive readings)',
      );
    }

    emit(state.copyWith(
      isOutputOn: reading.output,
      apower: reading.apower,
      lastUpdated: reading.timestamp,
      isDispensing: isDispensing,
    ));
  }

  Future<void> setPower(bool on) => _setPower(on);

  @override
  Future<void> close() async {
    await _onlineSubscription?.cancel();
    await _powerSubscription?.cancel();
    return super.close();
  }
}
