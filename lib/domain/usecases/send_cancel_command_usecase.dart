import 'package:injectable/injectable.dart';
import 'package:kds/domain/repositories/machine_repository.dart';

@injectable
class SendCancelCommandUseCase {
  final MachineRepository _repository;
  const SendCancelCommandUseCase(this._repository);
  Future<void> call(String ip, String productKey, String orderNo) =>
      _repository.sendCancelCommand(ip, productKey, orderNo);
}
