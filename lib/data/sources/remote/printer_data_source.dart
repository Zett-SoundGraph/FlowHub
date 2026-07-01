import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:injectable/injectable.dart' hide Order;
import 'package:kds/core/utils/log.dart';

/// Converts raw PNG bytes into ESC/POS raster byte sequence.
/// 1. Decode PNG into an image object
/// 2. Build ESC/POS header (initialize, line-spacing, raster header)
/// 3. Walk each pixel row and pack bits into bytes
/// 4. Append footer (restore line spacing, feed)
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
  /// Emits true when a label printer is attached, false when detached.
  Stream<bool> get statusStream;
  Future<void> printLabel(Uint8List pngBytes);
  Future<void> printTest(List<String> menus);
  void dispose();
}

@Singleton(as: IPrinterDataSource)
class PrinterDataSource implements IPrinterDataSource {
  static const _tag = 'Printer';
  static const _statusChannel = EventChannel('com.sg.kds/printer_status');
  static const _actionChannel = MethodChannel('com.sg.kds/printer_action');

  StreamSubscription? _statusSubscription;
  final StreamController<bool> _statusController = StreamController<bool>.broadcast();

  PrinterDataSource() {
    _listenToStatusChannel();
  }

  /// Subscribes to the native printer status EventChannel.
  /// 1. Listen for ATTACHED / DETACHED string events
  /// 2. Forward boolean value to [_statusController]
  /// 3. Propagate channel errors downstream
  void _listenToStatusChannel() {
    _statusSubscription = _statusChannel.receiveBroadcastStream().listen(
      (event) {
        final bool attached = event == 'ATTACHED';
        Log.d(_tag, 'Status: $event');
        _statusController.add(attached);
      },
      onError: (error) {
        Log.e(_tag, 'Channel error: $error');
        _statusController.addError(error);
      },
    );
  }

  @override
  Stream<bool> get statusStream => _statusController.stream;

  /// Encodes [pngBytes] to ESC/POS raster format and sends to native printer.
  /// 1. Run [encodeImageToEscPos] on a background isolate via [compute]
  /// 2. Invoke native 'printImageLabel' method with the encoded bytes
  @override
  Future<void> printLabel(Uint8List pngBytes) async {
    final totalWatch = Stopwatch()..start();

    final step23 = Stopwatch()..start();
    final List<int> bytes = await compute(encodeImageToEscPos, pngBytes);
    Log.d(_tag, 'Raster encoding: ${step23.elapsedMilliseconds}ms');

    final step4 = Stopwatch()..start();
    await _actionChannel.invokeMethod('printImageLabel', Uint8List.fromList(bytes));
    Log.d(_tag, 'Native transfer: ${step4.elapsedMilliseconds}ms');
    Log.i(_tag, 'Total elapsed: ${totalWatch.elapsedMilliseconds}ms');
  }

  /// Sends a test label with the given [menus] to the native printer channel.
  @override
  Future<void> printTest(List<String> menus) async {
    try {
      await _actionChannel.invokeMethod('printTestLabel', menus);
    } on PlatformException catch (e) {
      Log.e(_tag, 'Text print error: ${e.message}');
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _statusController.close();
  }
}
