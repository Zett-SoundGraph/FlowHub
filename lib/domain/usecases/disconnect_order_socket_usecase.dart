import 'package:injectable/injectable.dart';
import 'package:kds/domain/repositories/order_repository.dart';

@injectable
class DisconnectOrderSocketUseCase {
  final OrderRepository _orderRepository;

  const DisconnectOrderSocketUseCase(this._orderRepository);

  void call() => _orderRepository.disconnect();
}
