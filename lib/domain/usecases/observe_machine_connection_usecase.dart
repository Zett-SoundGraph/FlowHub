import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/machine_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class ObserveMachineConnectionUseCase extends StreamUseCase<bool> {
  final MachineRepository _repository;

  const ObserveMachineConnectionUseCase(this._repository);

  @override
  Stream<bool> call() => _repository.connectionStream;
}
