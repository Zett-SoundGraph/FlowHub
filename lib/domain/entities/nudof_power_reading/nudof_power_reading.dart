import 'package:freezed_annotation/freezed_annotation.dart';

part 'nudof_power_reading.freezed.dart';

/// A single `beta/nudof/status/switch:0` reading from the Shelly Plug M
/// Gen3 monitoring the Nudof dispenser's power draw — parsed from Shelly's
/// Gen2+ Switch component status JSON (output/apower/voltage/current; see
/// IMqttDataSource.nudofSwitchStatusStream for the raw topic).
@freezed
abstract class NudofPowerReading with _$NudofPowerReading {
  const factory NudofPowerReading({
    required bool output,
    required double apower,
    required double voltage,
    required double current,
    required DateTime timestamp,
  }) = _NudofPowerReading;
}
