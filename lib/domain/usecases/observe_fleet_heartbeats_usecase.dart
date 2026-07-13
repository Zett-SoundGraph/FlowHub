import 'package:injectable/injectable.dart';
import 'package:kds/domain/repositories/order_repository.dart';
import 'package:kds/domain/usecases/usecase.dart';

@injectable
class ObserveFleetHeartbeatsUseCase extends StreamUseCase<FleetHeartbeatEvent> {
  final OrderRepository _repository;

  const ObserveFleetHeartbeatsUseCase(this._repository);

  @override
  Stream<FleetHeartbeatEvent> call() => _repository.fleetHeartbeatStream;
}
