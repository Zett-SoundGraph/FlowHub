import 'package:fpdart/fpdart.dart' show Either, Right;
import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/machine_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

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
