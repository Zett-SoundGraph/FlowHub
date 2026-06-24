import 'package:injectable/injectable.dart';
import 'package:kds/domain/repositories/order_repository.dart';

@injectable
class ObserveBarcodeScanUseCase {
  final OrderRepository _repository;

  const ObserveBarcodeScanUseCase(this._repository);

  Stream<String> call() => _repository.barcodeScanStream;
}
