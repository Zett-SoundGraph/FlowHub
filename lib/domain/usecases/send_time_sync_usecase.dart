import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/machine_repository.dart';

@injectable
class SendTimeSyncUseCase {
  final MachineRepository _repository;
  const SendTimeSyncUseCase(this._repository);
  Future<void> call(String ip) => _repository.sendTimeSyncCommand(ip);
}
