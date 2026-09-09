import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class ObserveFollowerSyncRequestUseCase extends StreamUseCase<FollowerSyncRequest> {
  final OrderRepository _orderRepository;

  const ObserveFollowerSyncRequestUseCase(this._orderRepository);

  @override
  Stream<FollowerSyncRequest> call() => _orderRepository.followerSyncRequestStream;
}
