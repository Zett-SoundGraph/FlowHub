import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/entities/order/order.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/live_orders_snapshot_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class LoadLiveOrdersSnapshotUseCase extends UseCase<List<Order>, void> {
  final LiveOrdersSnapshotRepository _repository;

  LoadLiveOrdersSnapshotUseCase(this._repository);

  @override
  Future<Either<BaseException, List<Order>>> call(void params) async {
    try {
      final List<Order> orders = await _repository.load();
      return Right(orders);
    } catch (e) {
      return Left(exceptionHandler.handle(e));
    }
  }
}
