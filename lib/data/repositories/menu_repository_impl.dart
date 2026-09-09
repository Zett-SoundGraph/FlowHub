import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/data/sources/remote/menu_sheet_data_source.dart';
import 'package:flowhub/domain/entities/menu_info/menu_info.dart';
import 'package:flowhub/domain/entities/selected_option/selected_option.dart';
import 'package:flowhub/domain/repositories/menu_repository.dart';

@Singleton(as: MenuRepository)
class MenuRepositoryImpl implements MenuRepository {
  final IMenuSheetDataSource _dataSource;

  MenuRepositoryImpl(this._dataSource);

  @override
  Future<void> load() => _dataSource.load();

  @override
  Future<void> reloadNow() => _dataSource.reloadNow();

  @override
  MenuInfo? getMenuInfo(String menuNameEN) => _dataSource.getMenuInfo(menuNameEN);

  @override
  MenuInfo? getMenuInfoBySku(String skuNo) => _dataSource.getMenuInfoBySku(skuNo);

  @override
  List<MenuIngredient> getResolvedIngredients(String menuNameEN) =>
      _dataSource.getResolvedIngredients(menuNameEN);

  @override
  List<MenuIngredient> resolveOptions(String menuNameEN, List<SelectedOption> options) =>
      _dataSource.resolveOptions(menuNameEN, options);

  @override
  RecipeTiming getRecipeTiming(String skuNo, String temp) =>
      _dataSource.getRecipeTiming(skuNo, temp);

  @override
  RecipeDispenser getRecipeDispenser(String skuNo, String temp, List<SelectedOption> selectedOptions) =>
      _dataSource.getRecipeDispenser(skuNo, temp, selectedOptions);

  @override
  String? getRecipeImage(String skuNo, String temp) =>
      _dataSource.getRecipeImage(skuNo, temp);

  @override
  String? getRecipeVersion(String skuNo, String temp) =>
      _dataSource.getRecipeVersion(skuNo, temp);

  @override
  List<String> getRecipeIngredientLabels(String skuNo, String temp) =>
      _dataSource.getRecipeIngredientLabels(skuNo, temp);

  @override
  List<MenuIngredient> getRecipePopupIngredients(
    String skuNo,
    String menuNameEN,
    String temp,
    List<SelectedOption> selectedOptions,
  ) =>
      _dataSource.getRecipePopupIngredients(skuNo, menuNameEN, temp, selectedOptions);

  @override
  List<MenuIngredient> getLabelOptions(String menuNameEN, List<SelectedOption> selectedOptions) =>
      _dataSource.getLabelOptions(menuNameEN, selectedOptions);
}
