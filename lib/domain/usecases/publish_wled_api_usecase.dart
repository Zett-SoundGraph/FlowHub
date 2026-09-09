import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/repositories/order_repository.dart';

/// TEMPORARY — see IMqttDataSource.publishWledApi's doc comment. Delete
/// alongside WledTestToggle once WLED bench-testing is done.
@injectable
class PublishWledApiUseCase {
  final OrderRepository _orderRepository;
  const PublishWledApiUseCase(this._orderRepository);
  Future<void> call(Map<String, dynamic> body) => _orderRepository.publishWledApi(body);
}
