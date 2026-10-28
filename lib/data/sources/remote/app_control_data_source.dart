import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/core/utils/log.dart';

abstract interface class IAppControlDataSource {
  /// Kills and relaunches this device's FlowHub process outright (see
  /// MainActivity.kt's "restartApp" — a standard Android kill+relaunch, not
  /// a Flutter/Dart-level reset). Never actually returns on a real device:
  /// native calls Runtime.getRuntime().exit(0) right after scheduling the
  /// relaunch, so the process is gone before this call could resolve.
  Future<void> restartApp();
}

@Singleton(as: IAppControlDataSource)
class AppControlDataSource implements IAppControlDataSource {
  static const String _tag = 'AppControl';
  static const MethodChannel _actionChannel = MethodChannel(
    'com.sg.flowhub/printer_action',
  );

  @override
  Future<void> restartApp() async {
    try {
      await _actionChannel.invokeMethod('restartApp');
    } on PlatformException catch (e) {
      Log.e(_tag, 'restartApp error: ${e.message}');
    }
  }
}
