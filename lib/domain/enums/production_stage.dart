/// Bottom-bar-message-worthy production events for one sub-item, sent to
/// display boards (Pickup Board) over `beta/flowhub/board/update` so they
/// can show a localized message per event (Language List sheet rows
/// PB.BB.0002-0007) without needing to guess anything from `progress`
/// alone (which can't distinguish e.g. "canceled" from "failed" at all).
/// `none` covers both "hasn't reached a stage-worthy event yet" and
/// "already picked up" — boards drop `done` orders from the broadcast
/// entirely, so there's no separate value needed for that.
///
/// `cayeCanceled` is a scaffold for a future manufacturing-cancel feature —
/// nothing in this codebase sets it yet (see cancelBrewing in flowhub_cubit.dart,
/// which only sends the cancel command to the machine today).
enum ProductionStage {
  none,
  nudofDispensing,
  cayeCommandSent,
  cayeExtracting,
  cayeComplete,
  cayeCanceled,
  cayeFailed,
}
