import 'package:fpdart/fpdart.dart' show Either, Right;
import 'package:injectable/injectable.dart';
import 'package:kds/domain/exception/base_exception.dart';
import 'package:kds/domain/repositories/printer_repository.dart';
import 'package:kds/domain/usecases/usecase.dart';

@injectable
class DisposePrinterUseCase extends UseCaseSync<void, void> {
  final PrinterRepository _repository;

  DisposePrinterUseCase(this._repository);

  @override
  Either<BaseException, void> call(void params) {
    _repository.dispose();
    return const Right(null);
  }
}
