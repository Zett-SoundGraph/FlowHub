import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart';
import 'package:kds/domain/exception/base_exception.dart';
import 'package:kds/domain/repositories/machine_repository.dart';
import 'package:kds/domain/usecases/usecase.dart';

typedef SendMakeCommandParams = ({String ip, String productKey, String orderNo});

@injectable
class SendMakeCommandUseCase extends UseCase<void, SendMakeCommandParams> {
  final MachineRepository _repository;

  SendMakeCommandUseCase(this._repository);

  @override
  Future<Either<BaseException, void>> call(SendMakeCommandParams params) async {
    try {
      await _repository.sendMakeCommand(
          params.ip, params.productKey, params.orderNo);
      return const Right(null);
    } catch (e) {
      return Left(exceptionHandler.handle(e));
    }
  }
}
