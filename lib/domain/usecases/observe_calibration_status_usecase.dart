import 'package:injectable/injectable.dart';
import 'package:kds/domain/repositories/order_repository.dart';

@injectable
class ObserveCalibrationStatusUseCase {
  final OrderRepository _repository;
  const ObserveCalibrationStatusUseCase(this._repository);
  Stream<String> call() => _repository.calibrationStatusStream;
}
