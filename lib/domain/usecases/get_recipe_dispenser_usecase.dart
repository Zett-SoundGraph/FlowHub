import 'package:fpdart/fpdart.dart' show Either, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/entities/selected_option/selected_option.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/menu_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class GetRecipeDispenserUseCase extends UseCaseSync<RecipeDispenser,
    ({String skuNo, String temp, List<SelectedOption> selectedOptions})> {
  final MenuRepository _menuRepository;

  GetRecipeDispenserUseCase(this._menuRepository);

  @override
  Either<BaseException, RecipeDispenser> call(
    ({String skuNo, String temp, List<SelectedOption> selectedOptions}) params,
  ) {
    return Right(
      _menuRepository.getRecipeDispenser(params.skuNo, params.temp, params.selectedOptions),
    );
  }
}
