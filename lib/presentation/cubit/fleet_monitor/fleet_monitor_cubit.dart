import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';
import 'package:flowhub/domain/usecases/get_fleet_snapshot_usecase.dart';
import 'package:flowhub/domain/usecases/observe_fleet_heartbeats_usecase.dart';

import 'fleet_monitor_state.dart';

@injectable
class FleetMonitorCubit extends Cubit<FleetMonitorState> {
  // Bounds the log view's memory use during long debug sessions.
  static const maxLogEntries = 200;

  final GetFleetSnapshotUseCase _getFleetSnapshot;
  final ObserveFleetHeartbeatsUseCase _observeFleetHeartbeats;

  StreamSubscription<FleetHeartbeatEvent>? _heartbeatSubscription;

  FleetMonitorCubit({
    required GetFleetSnapshotUseCase getFleetSnapshot,
    required ObserveFleetHeartbeatsUseCase observeFleetHeartbeats,
  })  : _getFleetSnapshot = getFleetSnapshot,
        _observeFleetHeartbeats = observeFleetHeartbeats,
        super(const FleetMonitorState()) {
    _init();
  }

  /// Seeds state from the current snapshot (populated from retained heartbeat
  /// messages received since app start), then keeps it live via the stream.
  /// 1. Emit the current fleet snapshot immediately
  /// 2. Subscribe to future heartbeat events, updating the summary map and
  ///    prepending each raw event to the (capped) log list
  void _init() {
    emit(state.copyWith(deviceLastSeen: _getFleetSnapshot()));
    _heartbeatSubscription = _observeFleetHeartbeats().listen((event) {
      final updatedSummary = Map<String, DateTime>.from(state.deviceLastSeen)
        ..[event.deviceId] = event.timestamp;
      final updatedLog = [event, ...state.logEntries];
      emit(state.copyWith(
        deviceLastSeen: updatedSummary,
        logEntries: updatedLog.length > maxLogEntries
            ? updatedLog.sublist(0, maxLogEntries)
            : updatedLog,
      ));
    });
  }

  void setViewMode(FleetMonitorViewMode mode) =>
      emit(state.copyWith(viewMode: mode));

  @override
  Future<void> close() async {
    await _heartbeatSubscription?.cancel();
    return super.close();
  }
}
