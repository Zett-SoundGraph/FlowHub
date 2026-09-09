import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';

@injectable
class PublishBoardUpdateUseCase {
  final OrderRepository _orderRepository;
  const PublishBoardUpdateUseCase(this._orderRepository);
  Future<void> call(BoardUpdateMessage message) =>
      _orderRepository.publishBoardUpdate(message);
}
