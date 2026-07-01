import 'dart:typed_data';

import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart';
import 'package:kds/domain/exception/base_exception.dart';
import 'package:kds/domain/repositories/printer_repository.dart';
import 'package:kds/domain/usecases/usecase.dart';

@injectable
class PrintLabelUseCase extends UseCase<void, Uint8List> {
  final PrinterRepository _repository;

  PrintLabelUseCase(this._repository);

  @override
  Future<Either<BaseException, void>> call(Uint8List params) async {
    try {
      await _repository.printLabel(params);
      return const Right(null);
    } catch (e) {
      return Left(exceptionHandler.handle(e));
    }
  }
}
