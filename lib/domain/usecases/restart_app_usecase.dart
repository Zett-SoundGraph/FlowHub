import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/app_control_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class RestartAppUseCase extends UseCase<void, void> {
  final AppControlRepository _repository;

  RestartAppUseCase(this._repository);

  @override
  Future<Either<BaseException, void>> call(void params) async {
    try {
      await _repository.restartApp();
      return const Right(null);
    } catch (e) {
      return Left(exceptionHandler.handle(e));
    }
  }
}
