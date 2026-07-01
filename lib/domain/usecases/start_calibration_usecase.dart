import 'package:fpdart/fpdart.dart' show Either, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:kds/domain/exception/base_exception.dart';
import 'package:kds/domain/repositories/order_repository.dart';
import 'package:kds/domain/usecases/usecase.dart';

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
