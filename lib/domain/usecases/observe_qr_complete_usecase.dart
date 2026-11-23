import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
// class ObserveQrCompleteUseCase extends StreamUseCase<String> {
class ObserveQrCompleteUseCase extends StreamUseCase<({String raw, String source})> {
  final OrderRepository _repository;

  const ObserveQrCompleteUseCase(this._repository);

  @override
  // Stream<String> call() => _repository.qrCompleteStream;
  Stream<({String raw, String source})> call() => _repository.qrCompleteStream;
}
