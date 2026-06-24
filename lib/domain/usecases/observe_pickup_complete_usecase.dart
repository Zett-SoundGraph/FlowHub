import 'package:injectable/injectable.dart';
import 'package:kds/domain/repositories/order_repository.dart';

@injectable
class ObservePickupCompleteUseCase {
  final OrderRepository _repository;

  const ObservePickupCompleteUseCase(this._repository);

  Stream<({String orderNo, String menuName})> call() =>
      _repository.pickupCompleteStream;
}
