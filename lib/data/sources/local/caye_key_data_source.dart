import 'dart:io';

import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/core/utils/log.dart';
import 'package:path_provider/path_provider.dart';

abstract interface class ICayeKeyDataSource {
  /// The last-saved Caye AES key, or null if [saveKey] has never been called
  /// on this device.
  Future<String?> readKey();
  /// Persists [key], overwriting whatever was saved before — survives an
  /// app restart.
  Future<void> saveKey(String key);
}

/// Durable storage for the Caye machine's AES encryption key — each
/// physical unit uses its own key (see CayeMachineDataSource), so this is
/// what the Caye Machine Control screen's Save button writes to whenever an
/// operator swaps to a different machine. A single small text file (not
/// SharedPreferences — this app has no other key-value storage need yet, so
/// reusing the same file-in-app-support-dir pattern as
/// order_history_data_source.dart avoids adding a dependency for one value).
@Singleton(as: ICayeKeyDataSource)
class CayeKeyDataSource implements ICayeKeyDataSource {
  static const _tag = 'CayeKey';
  static const _fileName = 'caye_api_key.txt';

  File? _file;

  Future<File> _resolveFile() async {
    final cached = _file;
    if (cached != null) return cached;
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$_fileName');
    _file = file;
    return file;
  }

  @override
  Future<String?> readKey() async {
    try {
      final file = await _resolveFile();
      if (!await file.exists()) return null;
      final content = (await file.readAsString()).trim();
      return content.isEmpty ? null : content;
    } catch (e) {
      Log.e(_tag, 'Failed to read saved Caye key: $e');
      return null;
    }
  }

  @override
  Future<void> saveKey(String key) async {
    try {
      final file = await _resolveFile();
      await file.writeAsString(key.trim(), flush: true);
      Log.d(_tag, 'Saved Caye API key (${file.path})');
    } catch (e) {
      Log.e(_tag, 'Failed to save Caye key: $e');
    }
  }
}
