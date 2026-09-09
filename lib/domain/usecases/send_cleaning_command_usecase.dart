import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/machine_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

typedef SendCleaningCommandParams = ({String ip, int mode});

@injectable
class SendCleaningCommandUseCase
    extends UseCase<void, SendCleaningCommandParams> {
  final MachineRepository _repository;

  SendCleaningCommandUseCase(this._repository);

  @override
  Future<Either<BaseException, void>> call(
      SendCleaningCommandParams params) async {
    try {
      await _repository.sendCleaningCommand(params.ip, mode: params.mode);
      return const Right(null);
    } catch (e) {
      return Left(exceptionHandler.handle(e));
    }
  }
}
