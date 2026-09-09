import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';

@injectable
class PublishFollowerSyncUseCase {
  final OrderRepository _orderRepository;
  const PublishFollowerSyncUseCase(this._orderRepository);
  Future<void> call(FollowerSyncRequest request) =>
      _orderRepository.publishFollowerSync(request);
}
