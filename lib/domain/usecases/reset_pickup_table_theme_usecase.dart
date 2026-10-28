import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';

@injectable
class ResetPickupTableThemeUseCase {
  final OrderRepository _repository;

  const ResetPickupTableThemeUseCase(this._repository);

  Future<void> call() => _repository.resetPickupTableTheme();
}
