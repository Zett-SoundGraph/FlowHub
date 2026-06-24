import 'package:injectable/injectable.dart';
import 'package:kds/domain/repositories/machine_repository.dart';

@injectable
class SendMakeCommandUseCase {
  final MachineRepository _repository;
  const SendMakeCommandUseCase(this._repository);
  Future<void> call(String ip, String productKey, String orderNo) =>
      _repository.sendMakeCommand(ip, productKey, orderNo);
}
