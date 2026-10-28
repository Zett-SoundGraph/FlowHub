import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/core/constants/flowhub_identity.dart';
import 'package:flowhub/core/constants/local_subnet_resolver.dart';
import 'package:flowhub/core/constants/network.dart';
import 'package:flowhub/core/utils/log.dart';

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
  /// Emits true when a label is physically loaded in the printer (paper
  /// sensor), false when removed — NOT connection status.
  Stream<bool> get statusStream;
  /// Emits true on a successful connect (startup or a later manual
  /// [reconnect]), false once the native side gives up after repeated
  /// failed status-query attempts (e.g. the printer went to sleep or lost
  /// power) — there's no automatic retry after that; [reconnect] is the
  /// only way back to true.
  Stream<bool> get connectionStream;
  Future<void> printLabel(Uint8List pngBytes);
  Future<void> printTest(List<String> menus);
  /// Manually retries connecting — the Device Management screen's "off"
  /// Label Printer row, tapped instead of waiting for whatever external
  /// event (power back on) might let a future auto-retry succeed.
  Future<void> reconnect();
  /// Tells native whether a printed label is currently sitting in the
  /// detach-wait queue. While true, native forwards every status poll tick
  /// (not just changes) so a missed ATTACHED/DETACHED edge still
  /// self-corrects on the very next tick; while false (the common, idle
  /// case) native goes back to only reporting on real change.
  Future<void> setAwaitingDetach(bool awaiting);
  void dispose();
}

@Singleton(as: IPrinterDataSource)
class PrinterDataSource implements IPrinterDataSource {
  static const _tag = 'Printer';
  static const _statusChannel = EventChannel('com.sg.flowhub/printer_status');
  static const _actionChannel = MethodChannel('com.sg.flowhub/printer_action');

  StreamSubscription? _statusSubscription;
  final StreamController<bool> _statusController = StreamController<bool>.broadcast();
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  PrinterDataSource() {
    // The printer is physically wired to the leader only — listening here
    // is what triggers the native side's startMonitoring() (a real TCP
    // connect attempt to the printer), so a follower must never even start
    // listening, regardless of whether anything up the chain (FlowHubCubit)
    // ends up subscribing to the streams this exposes. Gating at the
    // subscription level alone isn't enough: DI constructs this singleton
    // (and thus runs this constructor) the same way on both roles.
    if (FlowHubIdentity.role == FlowHubRole.leader) {
      unawaited(_initAndListen());
    }
  }

  /// Waits for [LocalSubnetResolver] to confirm this site's real subnet (not
  /// just its fallback-until-resolved default) before ever telling native
  /// what address to dial — unlike MQTT/Caye, native's own printer-connect
  /// retry gives up after 3 attempts with no further auto-retry, so a first
  /// attempt made against a stale fallback (e.g. right after a cold boot,
  /// before DHCP hands this device its address) would otherwise need a
  /// manual Device Management tap to recover from instead of just working
  /// once the network catches up.
  Future<void> _initAndListen() async {
    await LocalSubnetResolver.ready;
    try {
      await _actionChannel.invokeMethod('setPrinterIp', NetworkConstants.labelPrinterIp);
    } on PlatformException catch (e) {
      Log.e(_tag, 'setPrinterIp error: ${e.message}');
    }
    _listenToStatusChannel();
  }

  /// Subscribes to the native printer status EventChannel, which carries two
  /// unrelated kinds of events on the same channel:
  /// 1. ATTACHED / DETACHED — the paper-sensor state (is a label loaded)
  /// 2. CONNECTED / DISCONNECTED — the startup TCP connection attempt result
  void _listenToStatusChannel() {
    _statusSubscription = _statusChannel.receiveBroadcastStream().listen(
      (event) {
        switch (event) {
          case 'ATTACHED':
          case 'DETACHED':
            final bool attached = event == 'ATTACHED';
            Log.d(_tag, 'Status: $event');
            _statusController.add(attached);
          case 'CONNECTED':
          case 'DISCONNECTED':
            final bool connected = event == 'CONNECTED';
            Log.d(_tag, 'Connection: $event');
            _connectionController.add(connected);
        }
      },
      onError: (error) {
        Log.e(_tag, 'Channel error: $error');
        _statusController.addError(error);
      },
    );
  }

  @override
  Stream<bool> get statusStream => _statusController.stream;

  @override
  Stream<bool> get connectionStream => _connectionController.stream;

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

  /// Asks the native side to retry [startMonitoring] — a no-op there if
  /// already connected, so this is safe to call regardless of current state.
  @override
  Future<void> reconnect() async {
    try {
      await _actionChannel.invokeMethod('reconnectPrinter');
    } on PlatformException catch (e) {
      Log.e(_tag, 'Reconnect error: ${e.message}');
    }
  }

  @override
  Future<void> setAwaitingDetach(bool awaiting) async {
    try {
      await _actionChannel.invokeMethod('setAwaitingDetach', awaiting);
    } on PlatformException catch (e) {
      Log.e(_tag, 'setAwaitingDetach error: ${e.message}');
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _statusController.close();
    _connectionController.close();
  }
}
