import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart';
import 'package:kds/domain/exception/base_exception.dart';
import 'package:kds/domain/repositories/machine_repository.dart';
import 'package:kds/domain/usecases/usecase.dart';

typedef CheckMachineAvailabilityParams = ({String ip, String productKey});

@injectable
class CheckMachineAvailabilityUseCase
    extends UseCase<void, CheckMachineAvailabilityParams> {
  final MachineRepository _repository;
  CheckMachineAvailabilityUseCase(this._repository);

  @override
  Future<Either<BaseException, void>> call(
      CheckMachineAvailabilityParams params) async {
    try {
      await _repository.sendCheckAvailability(params.ip, params.productKey);
      return const Right(null);
    } catch (e) {
      return Left(exceptionHandler.handle(e));
    }
  }
}
