import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:injectable/injectable.dart' hide Order;

// Top-level isolate function: PNG bytes → ESC/POS raster bytes
List<int> encodeImageToEscPos(Uint8List pngBytes) {
  final img.Image? src = img.decodeImage(pngBytes);
  if (src == null) return [];

  final int w = src.width;
  final int h = src.height;
  final int bytesPerRow = (w + 7) ~/ 8;
  final num threshold = src.maxChannelValue * 0.5;

  final List<int> bytes = [];

  // ESC @ — Initialize printer
  bytes.addAll([0x1B, 0x40]);
  // ESC 3 0 — Set line spacing to 0 for tight image rows
  bytes.addAll([0x1B, 0x33, 0x00]);
  // GS v 0 — Print raster bit image
  bytes.addAll([
    0x1D, 0x76, 0x30, 0x00,
    bytesPerRow & 0xFF, (bytesPerRow >> 8) & 0xFF,
    h & 0xFF, (h >> 8) & 0xFF,
  ]);

  for (int y = 0; y < h; y++) {
    for (int xByte = 0; xByte < bytesPerRow; xByte++) {
      int dotByte = 0;
      for (int bit = 0; bit < 8; bit++) {
        final int x = xByte * 8 + bit;
        if (x < w) {
          final pixel = src.getPixel(x, y);
          final num lum = 0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b;
          if (lum < threshold) {
            dotByte |= (1 << (7 - bit));
          }
        }
      }
      bytes.add(dotByte);
    }
  }

  // ESC 2 — Restore default line spacing
  bytes.addAll([0x1B, 0x32]);
  // Feed 2 lines
  bytes.addAll([0x1B, 0x64, 0x02]);

  return bytes;
}

abstract interface class IPrinterDataSource {
  Stream<bool> get statusStream; // true = ATTACHED, false = DETACHED
  Future<void> printLabel(Uint8List pngBytes);
  Future<void> printTest(List<String> menus);
  void dispose();
}

@Singleton(as: IPrinterDataSource)
class PrinterDataSource implements IPrinterDataSource {
  static const _statusChannel = EventChannel('com.sg.kds/printer_status');
  static const _actionChannel = MethodChannel('com.sg.kds/printer_action');

  StreamSubscription? _statusSubscription;
  final StreamController<bool> _statusController = StreamController<bool>.broadcast();

  PrinterDataSource() {
    _listenToStatusChannel();
  }

  void _listenToStatusChannel() {
    _statusSubscription = _statusChannel.receiveBroadcastStream().listen(
      (event) {
        final bool attached = event == 'ATTACHED';
        debugPrint('[Printer] 상태: $event');
        _statusController.add(attached);
      },
      onError: (error) {
        debugPrint('[Printer] ❌ 채널 오류: $error');
        _statusController.addError(error);
      },
    );
  }

  @override
  Stream<bool> get statusStream => _statusController.stream;

  @override
  Future<void> printLabel(Uint8List pngBytes) async {
    final totalWatch = Stopwatch()..start();

    final step23 = Stopwatch()..start();
    final List<int> bytes = await compute(encodeImageToEscPos, pngBytes);
    debugPrint('[Printer] ⏱️ 래스터 변환: ${step23.elapsedMilliseconds}ms');

    final step4 = Stopwatch()..start();
    await _actionChannel.invokeMethod('printImageLabel', Uint8List.fromList(bytes));
    debugPrint('[Printer] ⏱️ 네이티브 전송: ${step4.elapsedMilliseconds}ms');
    log('[Printer] 🏁 총 소요: ${totalWatch.elapsedMilliseconds}ms');
  }

  @override
  Future<void> printTest(List<String> menus) async {
    try {
      await _actionChannel.invokeMethod('printTestLabel', menus);
    } on PlatformException catch (e) {
      debugPrint('[Printer] ❌ 텍스트 인쇄 에러: ${e.message}');
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _statusController.close();
  }
}
