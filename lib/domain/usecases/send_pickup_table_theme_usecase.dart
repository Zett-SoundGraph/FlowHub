import 'package:injectable/injectable.dart';
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';

@injectable
class SendPickupTableThemeUseCase {
  final OrderRepository _repository;

  const SendPickupTableThemeUseCase(this._repository);

  Future<void> call(PickupTableThemeSelection selection) =>
      _repository.sendPickupTableTheme(selection);
}
