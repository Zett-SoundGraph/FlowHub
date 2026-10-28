import 'package:flowhub/domain/entities/index.dart';

abstract class NudofRepository {
  Stream<NudofPowerReading> get powerStream;

  /// The Shelly plug's own reachability (its Gen2+ online/LWT topic) — the
  /// same signal Device Management's "Nudof Machine(M)" row shows. Not
  /// whether this FlowHub device itself is connected to the broker (that
  /// wouldn't say anything about the plug specifically).
  Stream<bool> get onlineStream;
  bool get isOnline;

  /// Turns the Nudof dispenser's Shelly plug on/off — a hardware-level
  /// power-cycle available regardless of whatever state the vendor's own
  /// closed Android app on the dispenser is in.
  Future<void> setPower(bool on);
}
