import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/entities/order/order.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/order_history_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class AppendOrderHistoryUseCase extends UseCase<void, Order> {
  final OrderHistoryRepository _repository;

  AppendOrderHistoryUseCase(this._repository);

  @override
  Future<Either<BaseException, void>> call(Order params) async {
    try {
      await _repository.appendCompletedOrder(params);
      return const Right(null);
    } catch (e) {
      return Left(exceptionHandler.handle(e));
    }
  }
}
