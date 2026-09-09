import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/repositories/order_repository.dart';

/// TEMPORARY — see IMqttDataSource.publishWledPower's doc comment. Delete
/// alongside WledTestToggle once WLED bench-testing is done.
@injectable
class PublishWledPowerUseCase {
  final OrderRepository _orderRepository;
  const PublishWledPowerUseCase(this._orderRepository);
  Future<void> call(bool on) => _orderRepository.publishWledPower(on);
}
