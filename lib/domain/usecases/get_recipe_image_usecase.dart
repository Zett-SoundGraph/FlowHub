import 'package:fpdart/fpdart.dart' show Either, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/menu_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class GetRecipeImageUseCase extends UseCaseSync<String?, ({String skuNo, String temp})> {
  final MenuRepository _menuRepository;

  GetRecipeImageUseCase(this._menuRepository);

  @override
  Either<BaseException, String?> call(({String skuNo, String temp}) params) {
    return Right(_menuRepository.getRecipeImage(params.skuNo, params.temp));
  }
}
