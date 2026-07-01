import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart';
import 'package:kds/domain/exception/base_exception.dart';
import 'package:kds/domain/repositories/machine_repository.dart';
import 'package:kds/domain/usecases/usecase.dart';

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
