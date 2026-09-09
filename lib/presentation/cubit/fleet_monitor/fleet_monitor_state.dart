import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';

part 'fleet_monitor_state.freezed.dart';

enum FleetMonitorViewMode { log, summary }

@freezed
abstract class FleetMonitorState with _$FleetMonitorState {
  const factory FleetMonitorState({
    @Default({}) Map<String, DateTime> deviceLastSeen,
    // Newest first. Capped at [FleetMonitorCubit.maxLogEntries] to bound memory.
    @Default([]) List<FleetHeartbeatEvent> logEntries,
    @Default(FleetMonitorViewMode.log) FleetMonitorViewMode viewMode,
  }) = _FleetMonitorState;
}
