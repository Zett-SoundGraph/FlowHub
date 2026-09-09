import 'dart:async';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:flowhub/core/utils/log.dart';

abstract interface class IBarcodeScanDataSource {
  Stream<String> get scanStream;
  void dispose();
}

@Singleton(as: IBarcodeScanDataSource)
class KdsBarcodeScanDataSource implements IBarcodeScanDataSource {
  static const _tag = 'Scanner';
  static const MethodChannel _channel = MethodChannel('com.sg.flowhub/scanner');

  final StreamController<String> _scanController =
      StreamController<String>.broadcast();

  /// Registers the native MethodCallHandler for barcode scan events.
  /// 1. Set handler on [_channel] for 'onScan' method calls
  /// 2. Forward received scan data to [_scanController] if not closed
  KdsBarcodeScanDataSource() {
    Log.d(_tag, 'Registering MethodCallHandler');
    _channel.setMethodCallHandler((call) async {
      Log.d(_tag, 'Native call received: ${call.method} / args: ${call.arguments}');
      if (call.method == 'onScan') {
        final data = call.arguments.toString();
        Log.d(_tag, 'Scan data added to stream: $data');
        if (!_scanController.isClosed) {
          _scanController.add(data);
        } else {
          Log.w(_tag, 'Controller is closed — cannot add scan data');
        }
      }
    });
    Log.d(_tag, 'MethodCallHandler registered');
  }

  @override
  Stream<String> get scanStream => _scanController.stream;

  @override
  void dispose() => _scanController.close();
}
