import 'package:fpdart/fpdart.dart' show Either, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/entities/menu_info/menu_info.dart';
import 'package:flowhub/domain/entities/selected_option/selected_option.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/menu_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class GetLabelOptionsUseCase
    extends UseCaseSync<List<MenuIngredient>, ({String menuNameEN, List<SelectedOption> selectedOptions})> {
  final MenuRepository _menuRepository;

  GetLabelOptionsUseCase(this._menuRepository);

  @override
  Either<BaseException, List<MenuIngredient>> call(
    ({String menuNameEN, List<SelectedOption> selectedOptions}) params,
  ) {
    return Right(_menuRepository.getLabelOptions(params.menuNameEN, params.selectedOptions));
  }
}
