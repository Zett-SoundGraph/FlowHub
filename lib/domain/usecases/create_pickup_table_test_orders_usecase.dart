import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';

@injectable
class CreatePickupTableTestOrdersUseCase {
  final OrderRepository _repository;

  const CreatePickupTableTestOrdersUseCase(this._repository);

  Future<void> call() => _repository.createPickupTableTestOrders();
}
