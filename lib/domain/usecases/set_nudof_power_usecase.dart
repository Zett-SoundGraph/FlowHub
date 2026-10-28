import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/nudof_repository.dart';

@injectable
class SetNudofPowerUseCase {
  final NudofRepository _repository;

  const SetNudofPowerUseCase(this._repository);

  Future<void> call(bool on) => _repository.setPower(on);
}
