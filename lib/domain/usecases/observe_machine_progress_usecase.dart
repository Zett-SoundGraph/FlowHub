import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/repositories/machine_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class ObserveMachineProgressUseCase extends StreamUseCase<ExtractionProgress> {
  final MachineRepository _machineRepository;

  const ObserveMachineProgressUseCase(this._machineRepository);

  @override
  Stream<ExtractionProgress> call() => _machineRepository.progressStream;
}
