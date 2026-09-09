import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/repositories/printer_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class ObservePrinterConnectionUseCase extends StreamUseCase<bool> {
  final PrinterRepository _printerRepository;

  const ObservePrinterConnectionUseCase(this._printerRepository);

  @override
  Stream<bool> call() => _printerRepository.connectionStream;
}
