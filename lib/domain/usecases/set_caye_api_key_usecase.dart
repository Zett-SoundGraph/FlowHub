import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/machine_repository.dart';

@injectable
class SetCayeApiKeyUseCase {
  final MachineRepository _repository;
  const SetCayeApiKeyUseCase(this._repository);
  Future<void> call(String key) => _repository.setApiKey(key);
}
