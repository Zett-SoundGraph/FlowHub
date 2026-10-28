import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/enums/index.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';

/// See OrderRepository.wledOnlineByDevice's doc comment.
@injectable
class GetWledOnlineSnapshotUseCase {
  final OrderRepository _repository;

  const GetWledOnlineSnapshotUseCase(this._repository);

  Map<WledDevice, bool> call() => _repository.wledOnlineByDevice;
}
