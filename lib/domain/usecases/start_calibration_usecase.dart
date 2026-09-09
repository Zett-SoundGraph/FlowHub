import 'package:fpdart/fpdart.dart' show Either, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class StartCalibrationUseCase extends UseCaseSync<void, double> {
  final OrderRepository _orderRepository;

  StartCalibrationUseCase(this._orderRepository);

  @override
  Either<BaseException, void> call(double params) {
    _orderRepository.sendStartCalibration(params);
    return const Right(null);
  }
}
