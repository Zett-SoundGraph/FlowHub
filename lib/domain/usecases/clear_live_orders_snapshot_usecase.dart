import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/live_orders_snapshot_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class ClearLiveOrdersSnapshotUseCase extends UseCase<void, void> {
  final LiveOrdersSnapshotRepository _repository;

  ClearLiveOrdersSnapshotUseCase(this._repository);

  @override
  Future<Either<BaseException, void>> call(void params) async {
    try {
      await _repository.clear();
      return const Right(null);
    } catch (e) {
      return Left(exceptionHandler.handle(e));
    }
  }
}
