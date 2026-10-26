import 'package:freezed_annotation/freezed_annotation.dart';

part 'nudof_control_state.freezed.dart';

@freezed
abstract class NudofControlState with _$NudofControlState {
  const factory NudofControlState({
    // The Shelly plug's own reachability (its Gen2+ online/LWT topic) — the
    // same signal Device Management's "Nudof Machine(M)" row shows, NOT
    // whether this FlowHub device itself is connected to the broker (that
    // wouldn't tell you anything about the plug specifically).
    @Default(false) bool isOnline,
    // null until the first switch:0 status arrives — distinct from `false`
    // (confirmed off) so the UI can show "—" instead of a wrong guess.
    bool? isOutputOn,
    double? apower,
    DateTime? lastUpdated,
    // TEST/LOG-ONLY signal — see NudofControlCubit's class doc comment.
    @Default(false) bool isDispensing,
  }) = _NudofControlState;
}
