import 'package:injectable/injectable.dart' hide Order;
import 'package:kds/domain/entities/menu_recipe/menu_recipe.dart';
import 'package:kds/domain/repositories/recipe_repository.dart';

@injectable
class GetRecipeUseCase {
  final RecipeRepository _recipeRepository;

  const GetRecipeUseCase(this._recipeRepository);

  MenuRecipe? call(String menuNameEN) => _recipeRepository.getRecipe(menuNameEN);
}
