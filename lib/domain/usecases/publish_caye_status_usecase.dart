import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';

@injectable
class PublishCayeStatusUseCase {
  final OrderRepository _orderRepository;
  const PublishCayeStatusUseCase(this._orderRepository);
  Future<void> call(CayeStatusMessage message) =>
      _orderRepository.publishCayeStatus(message);
}
