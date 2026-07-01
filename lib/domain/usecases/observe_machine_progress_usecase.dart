import 'package:injectable/injectable.dart';
import 'package:kds/domain/entities/index.dart';
import 'package:kds/domain/repositories/machine_repository.dart';
import 'package:kds/domain/usecases/usecase.dart';

@injectable
class ObserveMachineProgressUseCase extends StreamUseCase<ExtractionProgress> {
  final MachineRepository _machineRepository;

  const ObserveMachineProgressUseCase(this._machineRepository);

  @override
  Stream<ExtractionProgress> call() => _machineRepository.progressStream;
}
