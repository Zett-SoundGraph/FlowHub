import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';

@injectable
class PublishCayeRinsingUseCase {
  final OrderRepository _orderRepository;
  const PublishCayeRinsingUseCase(this._orderRepository);
  Future<void> call(CayeEventMessage message) =>
      _orderRepository.publishCayeRinsing(message);
}
