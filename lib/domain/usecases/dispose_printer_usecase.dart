import 'package:injectable/injectable.dart';
import 'package:kds/domain/repositories/printer_repository.dart';

@injectable
class DisposePrinterUseCase {
  final PrinterRepository _repository;
  const DisposePrinterUseCase(this._repository);
  void call() => _repository.dispose();
}
