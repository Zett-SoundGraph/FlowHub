import 'package:injectable/injectable.dart';
import 'package:kds/domain/repositories/machine_repository.dart';

@injectable
class SendCleaningCommandUseCase {
  final MachineRepository _repository;
  const SendCleaningCommandUseCase(this._repository);
  Future<void> call(String ip, {int mode = 0}) =>
      _repository.sendCleaningCommand(ip, mode: mode);
}
