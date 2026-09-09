import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/machine_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

typedef SendExtractionHistoryParams = ({String ip, int startTs, int endTs});

@injectable
class SendExtractionHistoryUseCase
    extends UseCase<void, SendExtractionHistoryParams> {
  final MachineRepository _repository;

  SendExtractionHistoryUseCase(this._repository);

  @override
  Future<Either<BaseException, void>> call(SendExtractionHistoryParams params) async {
    try {
      await _repository.sendExtractionHistory(
        params.ip,
        startTs: params.startTs,
        endTs: params.endTs,
      );
      return const Right(null);
    } catch (e) {
      return Left(exceptionHandler.handle(e));
    }
  }
}
