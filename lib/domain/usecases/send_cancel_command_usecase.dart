import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/machine_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

typedef SendCancelCommandParams = ({
  String ip,
  String productKey,
  String orderNo
});

@injectable
class SendCancelCommandUseCase extends UseCase<void, SendCancelCommandParams> {
  final MachineRepository _repository;

  SendCancelCommandUseCase(this._repository);

  @override
  Future<Either<BaseException, void>> call(
      SendCancelCommandParams params) async {
    try {
      await _repository.sendCancelCommand(
          params.ip, params.productKey, params.orderNo);
      return const Right(null);
    } catch (e) {
      return Left(exceptionHandler.handle(e));
    }
  }
}
