import 'package:fpdart/fpdart.dart' show Either, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/menu_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class GetRecipeVersionUseCase extends UseCaseSync<String?, ({String skuNo, String temp})> {
  final MenuRepository _menuRepository;

  GetRecipeVersionUseCase(this._menuRepository);

  @override
  Either<BaseException, String?> call(({String skuNo, String temp}) params) {
    return Right(_menuRepository.getRecipeVersion(params.skuNo, params.temp));
  }
}
