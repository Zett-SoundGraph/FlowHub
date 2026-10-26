import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';

@injectable
class ClearPickupTableTestOrdersUseCase {
  final OrderRepository _repository;

  const ClearPickupTableTestOrdersUseCase(this._repository);

  Future<void> call() => _repository.clearPickupTableTestOrders();
}
