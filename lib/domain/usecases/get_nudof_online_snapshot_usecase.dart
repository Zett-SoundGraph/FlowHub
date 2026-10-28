import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/nudof_repository.dart';

@injectable
class GetNudofOnlineSnapshotUseCase {
  final NudofRepository _repository;

  const GetNudofOnlineSnapshotUseCase(this._repository);

  bool call() => _repository.isOnline;
}
