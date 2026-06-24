import 'package:injectable/injectable.dart' hide Order;
import 'package:kds/domain/repositories/printer_repository.dart';

@injectable
class ObservePrinterStatusUseCase {
  final PrinterRepository _printerRepository;

  const ObservePrinterStatusUseCase(this._printerRepository);

  Stream<bool> call() => _printerRepository.statusStream;
}
