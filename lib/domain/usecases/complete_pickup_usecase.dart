import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/index.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class CompletePickupUseCase extends UseCase<bool, Order> {
  final OrderRepository orderRepository;

  CompletePickupUseCase(this.orderRepository);

  @override
  Future<Either<BaseException, bool>> call(Order order) async {
    try {
      final result = await orderRepository.completePickup(order);
      return Right(result);
    } catch (e) {
      return Left(exceptionHandler.handle(e));
    }
  }
}
