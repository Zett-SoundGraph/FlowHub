import 'package:injectable/injectable.dart';
import 'package:kds/domain/repositories/machine_repository.dart';

@injectable
class ObserveMachineConnectionUseCase {
  final MachineRepository _repository;
  const ObserveMachineConnectionUseCase(this._repository);
  Stream<bool> call() => _repository.connectionStream;
}
