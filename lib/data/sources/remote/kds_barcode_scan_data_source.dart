import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

abstract interface class IBarcodeScanDataSource {
  Stream<String> get scanStream;
  void dispose();
}

@Singleton(as: IBarcodeScanDataSource)
class KdsBarcodeScanDataSource implements IBarcodeScanDataSource {
  static const MethodChannel _channel = MethodChannel('com.sg.kds/scanner');

  final StreamController<String> _scanController =
      StreamController<String>.broadcast();

  KdsBarcodeScanDataSource() {
    debugPrint('📡 [Scanner] MethodCallHandler 등록 시작');
    _channel.setMethodCallHandler((call) async {
      debugPrint('📡 [Scanner] 네이티브 호출 수신: ${call.method} / args: ${call.arguments}');
      if (call.method == 'onScan') {
        final data = call.arguments.toString();
        debugPrint('📡 [Scanner] 스캔 데이터 스트림에 추가: $data');
        if (!_scanController.isClosed) {
          _scanController.add(data);
        } else {
          debugPrint('⚠️ [Scanner] _scanController가 닫혀 있어 데이터를 추가할 수 없습니다!');
        }
      }
    });
    debugPrint('📡 [Scanner] MethodCallHandler 등록 완료');
  }

  @override
  Stream<String> get scanStream => _scanController.stream;

  @override
  void dispose() => _scanController.close();
}
