import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:flowhub/core/theme/app_theme.dart';

/// Camera QR scanner for the Caye machine's AES key: the machine carries a
/// QR holding its key, which is long to type by hand.
///
/// Returns the first QR value read (trimmed), or null when closed without
/// one. The caller only fills the key field with it; saving stays the
/// operator's Save tap, so a wrong scan is never stored.
class CayeKeyScannerDialog extends StatefulWidget {
  const CayeKeyScannerDialog({super.key, required this.scale});

  final double scale;

  /// Opens the scanner; resolves to the scanned value or null.
  static Future<String?> show(BuildContext context, {required double scale}) =>
      showDialog<String>(
        context: context,
        builder: (_) => CayeKeyScannerDialog(scale: scale),
      );

  @override
  State<CayeKeyScannerDialog> createState() => _CayeKeyScannerDialogState();
}

class _CayeKeyScannerDialogState extends State<CayeKeyScannerDialog> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const <BarcodeFormat>[BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Closes with the first non-empty QR value.
  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final Barcode barcode in capture.barcodes) {
      final String value = barcode.rawValue?.trim() ?? '';
      if (value.isEmpty) continue;
      _done = true;
      Navigator.of(context).pop(value);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double scale = widget.scale;
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24 * scale),
      ),
      child: Padding(
        padding: EdgeInsets.all(32 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Scan the Caye machine key QR',
              style: TextStyle(
                fontFamily: flowhubFontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 30 * scale,
                color: const Color(0xFF1A1C1E),
              ),
            ),
            SizedBox(height: 24 * scale),
            ClipRRect(
              borderRadius: BorderRadius.circular(16 * scale),
              child: SizedBox(
                width: 640 * scale,
                height: 480 * scale,
                child: MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                  errorBuilder:
                      (BuildContext context, MobileScannerException e) =>
                          Center(
                            child: Text(
                              'Camera unavailable: ${e.errorCode.name}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: flowhubFontFamily,
                                fontSize: 24 * scale,
                                color: Colors.white,
                              ),
                            ),
                          ),
                ),
              ),
            ),
            SizedBox(height: 24 * scale),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: flowhubFontFamily,
                  fontSize: 26 * scale,
                  color: FlowHubColors.navy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
