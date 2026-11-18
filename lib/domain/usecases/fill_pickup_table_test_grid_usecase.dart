import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';

@injectable
class FillPickupTableTestGridUseCase {
  final OrderRepository _repository;

  const FillPickupTableTestGridUseCase(this._repository);

  Future<void> call(int count) => _repository.fillPickupTableTestGrid(count);
}
