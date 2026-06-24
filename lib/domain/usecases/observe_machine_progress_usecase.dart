import 'package:injectable/injectable.dart';
import 'package:kds/domain/entities/index.dart';
import 'package:kds/domain/repositories/machine_repository.dart';

@injectable
class ObserveMachineProgressUseCase {
  final MachineRepository _machineRepository;

  const ObserveMachineProgressUseCase(this._machineRepository);

  Stream<ExtractionProgress> call() => _machineRepository.progressStream;
}
