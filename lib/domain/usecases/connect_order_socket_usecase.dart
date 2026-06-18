import 'package:injectable/injectable.dart';
import 'package:kds/domain/repositories/order_repository.dart';

@injectable
class ConnectOrderSocketUseCase {
  final OrderRepository _orderRepository;

  const ConnectOrderSocketUseCase(this._orderRepository);

  Future<void> call() => _orderRepository.connect();
}
