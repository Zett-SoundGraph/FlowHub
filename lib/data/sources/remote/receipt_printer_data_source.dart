import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/core/utils/log.dart';

abstract interface class IReceiptPrinterDataSource {
  /// Connects to the SRP-350plus over the network, prints [orderNo] and
  /// [menus] as a simple receipt, then disconnects. No persistent
  /// connection/status tracking yet (unlike [IPrinterDataSource]'s label
  /// printer) — this is a first pass to prove out network printing.
  Future<void> printReceipt({required String orderNo, required List<String> menus});
}

@Singleton(as: IReceiptPrinterDataSource)
class ReceiptPrinterDataSource implements IReceiptPrinterDataSource {
  static const _tag = 'ReceiptPrinter';
  // Native (MainActivity.kt) registers the "printReceipt" case inside the
  // SAME MethodChannel the label printer uses ("com.sg.flowhub/printer_action"),
  // not a separate channel — must match exactly, or invokeMethod throws
  // MissingPluginException (which isn't a PlatformException, so it used to
  // slip past this class's catch clause silently).
  static const _actionChannel = MethodChannel('com.sg.flowhub/printer_action');

  @override
  Future<void> printReceipt({required String orderNo, required List<String> menus}) async {
    try {
      await _actionChannel.invokeMethod('printReceipt', {
        'orderNo': orderNo,
        'menus': menus,
      });
      Log.d(_tag, 'Receipt print sent for order $orderNo');
    } catch (e) {
      Log.e(_tag, 'Receipt print error: $e');
    }
  }
}
