import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/printer_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class ReconnectPrinterUseCase extends UseCase<void, void> {
  final PrinterRepository _repository;

  ReconnectPrinterUseCase(this._repository);

  @override
  Future<Either<BaseException, void>> call(void params) async {
    try {
      await _repository.reconnect();
      return const Right(null);
    } catch (e) {
      return Left(exceptionHandler.handle(e));
    }
  }
}
