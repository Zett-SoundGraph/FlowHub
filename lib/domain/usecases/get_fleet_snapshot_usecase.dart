import 'package:injectable/injectable.dart';
import 'package:kds/domain/repositories/order_repository.dart';

@injectable
class GetFleetSnapshotUseCase {
  final OrderRepository _orderRepository;

  const GetFleetSnapshotUseCase(this._orderRepository);

  Map<String, DateTime> call() => _orderRepository.fleetLastSeen;
}
