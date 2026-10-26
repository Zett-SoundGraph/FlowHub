import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/core/utils/log.dart';
import 'package:flowhub/data/sources/remote/mqtt_data_source.dart';
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/repositories/nudof_repository.dart';

@Singleton(as: NudofRepository)
class NudofRepositoryImpl implements NudofRepository {
  static const _tag = 'NudofRepository';
  final IMqttDataSource _mqttDataSource;

  const NudofRepositoryImpl(this._mqttDataSource);

  @override
  Stream<bool> get onlineStream => _mqttDataSource.nudofOnlineStream;

  @override
  bool get isOnline => _mqttDataSource.isNudofOnline;

  @override
  Stream<NudofPowerReading> get powerStream => _mqttDataSource.nudofSwitchStatusStream
      .map(_parseReading)
      .where((reading) => reading != null)
      .cast<NudofPowerReading>();

  /// Parses a raw Shelly Gen2+ Switch component status payload
  /// (`beta/nudof/status/switch:0`) into a [NudofPowerReading]. Returns null
  /// (filtered out by [powerStream]) on a malformed payload rather than
  /// throwing, since a single bad reading shouldn't take down the stream.
  NudofPowerReading? _parseReading(Map<String, dynamic> json) {
    try {
      return NudofPowerReading(
        output: json['output'] == true,
        apower: (json['apower'] as num?)?.toDouble() ?? 0.0,
        voltage: (json['voltage'] as num?)?.toDouble() ?? 0.0,
        current: (json['current'] as num?)?.toDouble() ?? 0.0,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      Log.e(_tag, 'Failed to parse switch:0 status ($json): $e');
      return null;
    }
  }

  @override
  Future<void> setPower(bool on) => _mqttDataSource.publishNudofSwitchSet(on);
}
