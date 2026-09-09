import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/machine_repository.dart';

@injectable
class GetMachineConnectionSnapshotUseCase {
  final MachineRepository _repository;

  const GetMachineConnectionSnapshotUseCase(this._repository);

  bool call() => _repository.isConnected;
}
