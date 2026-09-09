import 'package:fpdart/fpdart.dart' show Either, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/entities/menu_info/menu_info.dart';
import 'package:flowhub/domain/entities/selected_option/selected_option.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/menu_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class GetRecipePopupIngredientsUseCase extends UseCaseSync<
    List<MenuIngredient>,
    ({String skuNo, String menuNameEN, String temp, List<SelectedOption> selectedOptions})> {
  final MenuRepository _menuRepository;

  GetRecipePopupIngredientsUseCase(this._menuRepository);

  @override
  Either<BaseException, List<MenuIngredient>> call(
    ({String skuNo, String menuNameEN, String temp, List<SelectedOption> selectedOptions}) params,
  ) {
    return Right(_menuRepository.getRecipePopupIngredients(
      params.skuNo,
      params.menuNameEN,
      params.temp,
      params.selectedOptions,
    ));
  }
}
