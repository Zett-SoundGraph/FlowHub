import 'package:injectable/injectable.dart' hide Order;
import 'package:kds/domain/repositories/order_repository.dart';

@injectable
class StartCalibrationUseCase {
  final OrderRepository _orderRepository;

  const StartCalibrationUseCase(this._orderRepository);

  void call(double height) => _orderRepository.sendStartCalibration(height);
}
