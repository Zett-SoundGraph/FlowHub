import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/machine_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

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
