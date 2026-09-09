import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/machine_repository.dart';

@injectable
class SendQueryStatusUseCase {
  final MachineRepository _repository;
  const SendQueryStatusUseCase(this._repository);
  Future<void> call(String ip) => _repository.sendQueryStatus(ip);
}
