import 'package:fpdart/fpdart.dart' show Either, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/entities/menu_info/menu_info.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/menu_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class GetMenuInfoBySkuUseCase extends UseCaseSync<MenuInfo?, String> {
  final MenuRepository _menuRepository;

  GetMenuInfoBySkuUseCase(this._menuRepository);

  @override
  Either<BaseException, MenuInfo?> call(String params) {
    return Right(_menuRepository.getMenuInfoBySku(params));
  }
}
