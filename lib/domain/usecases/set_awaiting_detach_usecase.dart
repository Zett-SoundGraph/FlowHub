import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/printer_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class SetAwaitingDetachUseCase extends UseCase<void, bool> {
  final PrinterRepository _repository;

  SetAwaitingDetachUseCase(this._repository);

  @override
  Future<Either<BaseException, void>> call(bool awaiting) async {
    try {
      await _repository.setAwaitingDetach(awaiting);
      return const Right(null);
    } catch (e) {
      return Left(exceptionHandler.handle(e));
    }
  }
}
