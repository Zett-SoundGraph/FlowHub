abstract class AppControlRepository {
  /// Kills and relaunches this device's FlowHub process outright — a real
  /// OS-level restart (Runtime.getRuntime().exit(0) on the native side), not
  /// a Flutter/Dart-level state reset.
  Future<void> restartApp();
}
