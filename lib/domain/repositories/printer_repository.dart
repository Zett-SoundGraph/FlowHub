import 'dart:typed_data';

abstract class PrinterRepository {
  Stream<bool> get statusStream; // true = 라벨 부착됨, false = 제거됨
  Future<void> printLabel(Uint8List pngBytes);
  Future<void> printTest(List<String> menus);
  void dispose();
}
