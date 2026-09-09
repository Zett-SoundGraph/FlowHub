import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/machine_repository.dart';

@injectable
class SendRinsingCommandUseCase {
  final MachineRepository _repository;
  const SendRinsingCommandUseCase(this._repository);
  Future<void> call(String ip) => _repository.sendRinsingCommand(ip);
}
