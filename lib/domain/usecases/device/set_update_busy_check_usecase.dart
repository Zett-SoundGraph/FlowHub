import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/device_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

/// Registers (or clears, with `null`) the check that answers FlowUpdater's
/// `update.imminent`: `true` = BUSY (defer), `false` = ACK (update now).
@injectable
class SetUpdateBusyCheckUseCase extends UseCaseSync<void, UpdateBusyCheck?> {
  SetUpdateBusyCheckUseCase(this._repository);

  final DeviceRepository _repository;

  @override
  Either<BaseException, void> call(UpdateBusyCheck? params) {
    try {
      _repository.setUpdateBusyCheck(params);
      return const Right<BaseException, void>(null);
    } catch (e) {
      return Left<BaseException, void>(exceptionHandler.handle(e));
    }
  }
}
