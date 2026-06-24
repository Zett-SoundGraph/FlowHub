import 'package:injectable/injectable.dart';
import 'package:kds/domain/repositories/machine_repository.dart';

@injectable
class DisposeMachineUseCase {
  final MachineRepository _repository;
  const DisposeMachineUseCase(this._repository);
  void call() => _repository.dispose();
}
