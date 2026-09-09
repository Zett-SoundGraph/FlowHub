import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class ObserveKioskOrderUseCase extends StreamUseCase<Order> {
  final OrderRepository _orderRepository;

  const ObserveKioskOrderUseCase(this._orderRepository);

  @override
  Stream<Order> call() => _orderRepository.kioskOrderStream;
}
