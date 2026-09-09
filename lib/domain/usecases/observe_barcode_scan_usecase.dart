import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class ObserveBarcodeScanUseCase extends StreamUseCase<String> {
  final OrderRepository _repository;

  const ObserveBarcodeScanUseCase(this._repository);

  @override
  Stream<String> call() => _repository.barcodeScanStream;
}
