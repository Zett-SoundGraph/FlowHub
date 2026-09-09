import 'package:fpdart/fpdart.dart' show Either, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/menu_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class GetRecipeIngredientLabelsUseCase
    extends UseCaseSync<List<String>, ({String skuNo, String temp})> {
  final MenuRepository _menuRepository;

  GetRecipeIngredientLabelsUseCase(this._menuRepository);

  @override
  Either<BaseException, List<String>> call(({String skuNo, String temp}) params) {
    return Right(_menuRepository.getRecipeIngredientLabels(params.skuNo, params.temp));
  }
}
