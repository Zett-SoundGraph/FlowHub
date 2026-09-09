import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/index.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

typedef CompleteCookingParams = ({Order order, SubItem subItem});

@injectable
class CompleteCookingUseCase extends UseCase<bool, CompleteCookingParams> {
  final OrderRepository orderRepository;

  CompleteCookingUseCase(this.orderRepository);

  @override
  Future<Either<BaseException, bool>> call(CompleteCookingParams params) async {
    try {
      final result = await orderRepository.completeCooking(
          params.order, params.subItem);
      return Right(result);
    } catch (e) {
      return Left(exceptionHandler.handle(e));
    }
  }
}
