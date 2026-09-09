import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class ObserveLeaderUpdateUseCase extends StreamUseCase<LeaderUpdateMessage> {
  final OrderRepository _orderRepository;

  const ObserveLeaderUpdateUseCase(this._orderRepository);

  @override
  Stream<LeaderUpdateMessage> call() => _orderRepository.leaderUpdateStream;
}
