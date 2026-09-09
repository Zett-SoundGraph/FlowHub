import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class ObservePickupCompleteUseCase
    extends StreamUseCase<({String orderNo, String menuName})> {
  final OrderRepository _repository;

  const ObservePickupCompleteUseCase(this._repository);

  @override
  Stream<({String orderNo, String menuName})> call() =>
      _repository.pickupCompleteStream;
}
