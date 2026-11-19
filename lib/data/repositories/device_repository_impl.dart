import 'package:flow_updater_sdk/flow_updater_sdk.dart' as sdk;
import 'package:flowhub/data/mappers/device_info_mapper.dart';
import 'package:flowhub/data/platform/flow_updater_service.dart';
import 'package:flowhub/domain/entities/device/device.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/device_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: DeviceRepository)
class DeviceRepositoryImpl implements DeviceRepository {
  const DeviceRepositoryImpl(this._flowUpdater);

  final FlowUpdaterService _flowUpdater;

  @override
  Stream<void> get deviceInfoChanges => _flowUpdater.deviceInfoChanges;

  @override
  Future<Device> getDeviceInfo() async {
    final sdk.IpcResult<sdk.DeviceInfo> result = await _flowUpdater
        .getDeviceInfo();
    final sdk.IpcErrorPayload? error = result.error;
    if (error != null) {
      throw BaseException(message: '${error.code.wire}: ${error.message}');
    }
    return result.value!.toDomain();
  }

  @override
  void setUpdateBusyCheck(UpdateBusyCheck? check) =>
      _flowUpdater.setUpdateBusyChecker(check);
}
