import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/enums/index.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';

/// See IMqttDataSource.publishWledApi's doc comment.
@injectable
class PublishWledApiUseCase {
  final OrderRepository _orderRepository;
  const PublishWledApiUseCase(this._orderRepository);
  Future<void> call(WledDevice device, Map<String, dynamic> body) =>
      _orderRepository.publishWledApi(device, body);
}
