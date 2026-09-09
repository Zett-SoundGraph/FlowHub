import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';

@injectable
class PublishKioskUpdateUseCase {
  final OrderRepository _orderRepository;
  const PublishKioskUpdateUseCase(this._orderRepository);
  Future<void> call(KioskUpdateMessage message) =>
      _orderRepository.publishKioskUpdate(message);
}
