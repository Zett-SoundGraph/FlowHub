import 'package:fpdart/fpdart.dart' show Either, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:kds/domain/entities/menu_recipe/menu_recipe.dart';
import 'package:kds/domain/exception/base_exception.dart';
import 'package:kds/domain/repositories/recipe_repository.dart';
import 'package:kds/domain/usecases/usecase.dart';

@injectable
class GetRecipeUseCase extends UseCaseSync<MenuRecipe?, String> {
  final RecipeRepository _recipeRepository;

  GetRecipeUseCase(this._recipeRepository);

  @override
  Either<BaseException, MenuRecipe?> call(String params) {
    return Right(_recipeRepository.getRecipe(params));
  }
}
