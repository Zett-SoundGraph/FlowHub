import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/entities/order/order.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/live_orders_snapshot_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class SaveLiveOrdersSnapshotUseCase extends UseCase<void, List<Order>> {
  final LiveOrdersSnapshotRepository _repository;

  SaveLiveOrdersSnapshotUseCase(this._repository);

  @override
  Future<Either<BaseException, void>> call(List<Order> params) async {
    try {
      await _repository.save(params);
      return const Right(null);
    } catch (e) {
      return Left(exceptionHandler.handle(e));
    }
  }
}
