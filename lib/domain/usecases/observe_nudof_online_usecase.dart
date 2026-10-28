import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/nudof_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class ObserveNudofOnlineUseCase extends StreamUseCase<bool> {
  final NudofRepository _repository;

  const ObserveNudofOnlineUseCase(this._repository);

  @override
  Stream<bool> call() => _repository.onlineStream;
}
