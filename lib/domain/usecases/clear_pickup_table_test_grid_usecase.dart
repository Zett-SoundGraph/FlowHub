import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';

@injectable
class ClearPickupTableTestGridUseCase {
  final OrderRepository _repository;

  const ClearPickupTableTestGridUseCase(this._repository);

  Future<void> call() => _repository.clearPickupTableTestGrid();
}
