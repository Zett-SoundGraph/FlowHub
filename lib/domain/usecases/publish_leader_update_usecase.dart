import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';

@injectable
class PublishLeaderUpdateUseCase {
  final OrderRepository _orderRepository;
  const PublishLeaderUpdateUseCase(this._orderRepository);
  Future<void> call(LeaderUpdateMessage message) =>
      _orderRepository.publishLeaderUpdate(message);
}
