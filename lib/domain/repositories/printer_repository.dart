import 'dart:typed_data';

abstract class PrinterRepository {
  /// Emits true when a label is attached to the printer, false when removed.
  Stream<bool> get statusStream;
  /// Emits true once the printer connects at startup, false if all retries
  /// fail — separate from [statusStream], which is the paper/label sensor.
  Stream<bool> get connectionStream;
  Future<void> printLabel(Uint8List pngBytes);
  Future<void> printTest(List<String> menus);
  /// Manually retries connecting — for the Device Management screen's "off"
  /// Label Printer row.
  Future<void> reconnect();
  /// Tells native whether a label is currently awaiting its DETACHED signal
  /// — see [IPrinterDataSource.setAwaitingDetach].
  Future<void> setAwaitingDetach(bool awaiting);
  void dispose();
}
