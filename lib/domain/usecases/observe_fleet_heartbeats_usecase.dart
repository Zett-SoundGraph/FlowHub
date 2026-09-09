import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class ObserveFleetHeartbeatsUseCase extends StreamUseCase<FleetHeartbeatEvent> {
  final OrderRepository _repository;

  const ObserveFleetHeartbeatsUseCase(this._repository);

  @override
  Stream<FleetHeartbeatEvent> call() => _repository.fleetHeartbeatStream;
}
