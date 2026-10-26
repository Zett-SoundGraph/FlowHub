import 'package:fpdart/fpdart.dart' show Either, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

typedef StartCalibrationParams = ({
  double height,
  String displayModel,
  double edgeMarginMm,
  double? displayWidthMm,
  double? displayHeightMm,
});

@injectable
class StartCalibrationUseCase
    extends UseCaseSync<void, StartCalibrationParams> {
  final OrderRepository _orderRepository;

  StartCalibrationUseCase(this._orderRepository);

  @override
  Either<BaseException, void> call(StartCalibrationParams params) {
    _orderRepository.sendStartCalibration(
      params.height,
      displayModel: params.displayModel,
      edgeMarginMm: params.edgeMarginMm,
      displayWidthMm: params.displayWidthMm,
      displayHeightMm: params.displayHeightMm,
    );
    return const Right(null);
  }
}
