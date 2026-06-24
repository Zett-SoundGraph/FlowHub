import 'package:kds/domain/entities/menu_recipe/menu_recipe.dart';

abstract class RecipeRepository {
  Future<void> load();
  MenuRecipe? getRecipe(String menuNameEN);
}
