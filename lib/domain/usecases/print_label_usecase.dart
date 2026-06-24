import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import 'package:kds/domain/repositories/printer_repository.dart';

@injectable
class PrintLabelUseCase {
  final PrinterRepository _repository;
  const PrintLabelUseCase(this._repository);
  Future<void> call(Uint8List pngBytes) => _repository.printLabel(pngBytes);
}
