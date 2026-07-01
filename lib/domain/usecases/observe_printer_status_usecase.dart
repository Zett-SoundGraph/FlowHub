import 'package:injectable/injectable.dart' hide Order;
import 'package:kds/domain/repositories/printer_repository.dart';
import 'package:kds/domain/usecases/usecase.dart';

@injectable
class ObservePrinterStatusUseCase extends StreamUseCase<bool> {
  final PrinterRepository _printerRepository;

  const ObservePrinterStatusUseCase(this._printerRepository);

  @override
  Stream<bool> call() => _printerRepository.statusStream;
}
