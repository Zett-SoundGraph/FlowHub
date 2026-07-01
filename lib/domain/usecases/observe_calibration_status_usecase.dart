import 'package:injectable/injectable.dart';
import 'package:kds/domain/repositories/order_repository.dart';
import 'package:kds/domain/usecases/usecase.dart';

@injectable
class ObserveCalibrationStatusUseCase extends StreamUseCase<String> {
  final OrderRepository _repository;

  const ObserveCalibrationStatusUseCase(this._repository);

  @override
  Stream<String> call() => _repository.calibrationStatusStream;
}
