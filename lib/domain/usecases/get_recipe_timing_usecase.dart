import 'package:fpdart/fpdart.dart' show Either, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/menu_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class GetRecipeTimingUseCase
    extends UseCaseSync<RecipeTiming, ({String skuNo, String temp})> {
  final MenuRepository _menuRepository;

  GetRecipeTimingUseCase(this._menuRepository);

  @override
  Either<BaseException, RecipeTiming> call(({String skuNo, String temp}) params) {
    return Right(_menuRepository.getRecipeTiming(params.skuNo, params.temp));
  }
}
