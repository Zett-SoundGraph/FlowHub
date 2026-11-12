import 'package:flowhub/domain/entities/device/device.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/device_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

/// Reads the device record from FlowUpdater (`device.getInfo`).
@injectable
class GetDeviceInfoUseCase extends UseCase<Device, void> {
  GetDeviceInfoUseCase(this._repository);

  final DeviceRepository _repository;

  @override
  Future<Either<BaseException, Device>> call(void params) async {
    try {
      return Right<BaseException, Device>(await _repository.getDeviceInfo());
    } catch (e) {
      return Left<BaseException, Device>(exceptionHandler.handle(e));
    }
  }
}
