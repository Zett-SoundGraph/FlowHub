import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/enums/index.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

/// See OrderRepository.wledOnlineStream's doc comment.
@injectable
class ObserveWledOnlineUseCase
    extends StreamUseCase<({WledDevice device, bool online})> {
  final OrderRepository _repository;

  const ObserveWledOnlineUseCase(this._repository);

  @override
  Stream<({WledDevice device, bool online})> call() =>
      _repository.wledOnlineStream;
}
