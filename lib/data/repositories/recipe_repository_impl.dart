import 'package:injectable/injectable.dart' hide Order;
import 'package:kds/data/sources/local/recipe_data_source.dart';
import 'package:kds/domain/entities/menu_recipe/menu_recipe.dart';
import 'package:kds/domain/repositories/recipe_repository.dart';

@Singleton(as: RecipeRepository)
class RecipeRepositoryImpl implements RecipeRepository {
  final IRecipeDataSource _dataSource;

  RecipeRepositoryImpl(this._dataSource);

  @override
  Future<void> load() => _dataSource.load();

  @override
  MenuRecipe? getRecipe(String menuNameEN) => _dataSource.getRecipe(menuNameEN);
}
