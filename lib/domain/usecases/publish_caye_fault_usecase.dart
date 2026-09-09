import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';

@injectable
class PublishCayeFaultUseCase {
  final OrderRepository _orderRepository;
  const PublishCayeFaultUseCase(this._orderRepository);
  Future<void> call(CayeFaultMessage message) =>
      _orderRepository.publishCayeFault(message);
}
