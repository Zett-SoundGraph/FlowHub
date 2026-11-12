import 'package:flowhub/domain/repositories/device_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';
import 'package:injectable/injectable.dart';

/// Fires when FlowUpdater refreshed the device record (`device.changed`).
@injectable
class ObserveDeviceInfoChangedUseCase extends StreamUseCase<void> {
  const ObserveDeviceInfoChangedUseCase(this._repository);

  final DeviceRepository _repository;

  @override
  Stream<void> call() => _repository.deviceInfoChanges;
}
