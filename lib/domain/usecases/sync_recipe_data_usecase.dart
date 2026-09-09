import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/menu_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class SyncRecipeDataUseCase extends UseCase<void, void> {
  final MenuRepository _menuRepository;

  SyncRecipeDataUseCase(this._menuRepository);

  @override
  Future<Either<BaseException, void>> call(void params) async {
    try {
      await _menuRepository.reloadNow();
      return const Right(null);
    } catch (e) {
      return Left(exceptionHandler.handle(e));
    }
  }
}
