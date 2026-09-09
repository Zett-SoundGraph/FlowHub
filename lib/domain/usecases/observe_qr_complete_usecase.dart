import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class ObserveQrCompleteUseCase extends StreamUseCase<String> {
  final OrderRepository _repository;

  const ObserveQrCompleteUseCase(this._repository);

  @override
  Stream<String> call() => _repository.qrCompleteStream;
}
