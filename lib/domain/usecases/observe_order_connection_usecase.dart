import 'package:injectable/injectable.dart';
import 'package:kds/domain/repositories/order_repository.dart';

@injectable
class ObserveOrderConnectionUseCase {
  final OrderRepository _orderRepository;

  const ObserveOrderConnectionUseCase(this._orderRepository);

  Stream<bool> call() => _orderRepository.connectionStream;
}
