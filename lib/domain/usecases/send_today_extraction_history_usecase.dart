import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart';
import 'package:kds/domain/exception/base_exception.dart';
import 'package:kds/domain/repositories/machine_repository.dart';
import 'package:kds/domain/usecases/usecase.dart';

@injectable
class SendTodayExtractionHistoryUseCase extends UseCase<void, String> {
  final MachineRepository _repository;

  SendTodayExtractionHistoryUseCase(this._repository);

  @override
  Future<Either<BaseException, void>> call(String params) async {
    try {
      await _repository.sendTodayExtractionHistory(params);
      return const Right(null);
    } catch (e) {
      return Left(exceptionHandler.handle(e));
    }
  }
}
