import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/machine_repository.dart';

@injectable
class GetCayeApiKeyUseCase {
  final MachineRepository _repository;
  const GetCayeApiKeyUseCase(this._repository);
  Future<String> call() => _repository.currentApiKey;
}
