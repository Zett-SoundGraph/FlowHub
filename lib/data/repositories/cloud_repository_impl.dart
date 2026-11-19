import 'package:flowhub/core/utils/log.dart';
import 'package:flowhub/data/sources/remote/cloud_mqtt_data_source.dart';
import 'package:flowhub/domain/entities/cloud/cloud_identity.dart';
import 'package:flowhub/domain/entities/device/device.dart';
import 'package:flowhub/domain/repositories/cloud_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CloudRepository)
class CloudRepositoryImpl implements CloudRepository {
  CloudRepositoryImpl(this._mqtt);

  static const String _tag = 'CloudRepository';

  final ICloudMqttDataSource _mqtt;

  @override
  CloudIdentity? get identity => _mqtt.identity;

  @override
  Stream<bool> get connectionStream => _mqtt.connectionStream;

  @override
  bool get isConnected => _mqtt.isConnected;

  /// Connects with the hub ID as the MQTT client ID — one persistent session
  /// per Hub, so queued cloud messages reach the same Hub.
  @override
  Future<CloudIdentity?> start(Device device) async {
    final CloudIdentity? identity = CloudIdentity.fromDevice(device);
    if (identity == null) {
      return null;
    }
    if (_mqtt.identity != identity) {
      Log.i(_tag, 'Cloud session as $identity');
    }
    await _mqtt.connect(identity);
    return identity;
  }
}
