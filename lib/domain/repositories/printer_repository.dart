import 'dart:typed_data';

abstract class PrinterRepository {
  /// Emits true when a label is attached to the printer, false when removed.
  Stream<bool> get statusStream;
  Future<void> printLabel(Uint8List pngBytes);
  Future<void> printTest(List<String> menus);
  void dispose();
}
