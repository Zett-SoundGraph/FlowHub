import 'package:fpdart/fpdart.dart' show Either, Right;
import 'package:injectable/injectable.dart';
import 'package:kds/domain/exception/base_exception.dart';
import 'package:kds/domain/repositories/machine_repository.dart';
import 'package:kds/domain/usecases/usecase.dart';

@injectable
class DisposeMachineUseCase extends UseCaseSync<void, void> {
  final MachineRepository _repository;

  DisposeMachineUseCase(this._repository);

  @override
  Either<BaseException, void> call(void params) {
    _repository.dispose();
    return const Right(null);
  }
}
