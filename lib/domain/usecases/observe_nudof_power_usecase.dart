import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/repositories/nudof_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class ObserveNudofPowerUseCase extends StreamUseCase<NudofPowerReading> {
  final NudofRepository _repository;

  const ObserveNudofPowerUseCase(this._repository);

  @override
  Stream<NudofPowerReading> call() => _repository.powerStream;
}
