import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart';
import 'package:kds/domain/exception/base_exception.dart';
import 'package:kds/domain/repositories/machine_repository.dart';
import 'package:kds/domain/usecases/usecase.dart';

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
