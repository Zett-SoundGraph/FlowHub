import 'dart:convert';
import 'dart:io';

import 'package:flowhub/core/utils/log.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

/// Cancel tombstones (orderNo → cancelledAt) for POS orders whose CANCEL
/// arrived before the NEW.
abstract interface class IPosOrderTombstoneDataSource {
  /// Every stored tombstone; empty when there is none or it can't be read.
  Future<Map<String, DateTime>> load();

  /// Replaces the stored tombstones with [tombstones].
  Future<void> save(Map<String, DateTime> tombstones);
}

/// A single JSON file, written to a temporary file and renamed so a crash
/// mid-write never leaves half a file.
@Singleton(as: IPosOrderTombstoneDataSource)
class PosOrderTombstoneDataSource implements IPosOrderTombstoneDataSource {
  static const String _tag = 'PosOrderTombstone';
  static const String _fileName = 'pos_order_tombstones.json';

  File? _file;

  Future<File> _resolveFile() async {
    final File? cached = _file;
    if (cached != null) {
      return cached;
    }
    final Directory dir = await getApplicationSupportDirectory();
    return _file = File('${dir.path}${Platform.pathSeparator}$_fileName');
  }

  @override
  Future<Map<String, DateTime>> load() async {
    try {
      final File file = await _resolveFile();
      if (!await file.exists()) {
        return <String, DateTime>{};
      }
      final Object? decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) {
        return <String, DateTime>{};
      }
      return <String, DateTime>{
        for (final MapEntry<String, dynamic> e in decoded.entries)
          if (DateTime.tryParse(e.value.toString()) != null)
            e.key: DateTime.parse(e.value.toString()),
      };
    } catch (e) {
      Log.e(_tag, 'Load failed: $e');
      return <String, DateTime>{};
    }
  }

  @override
  Future<void> save(Map<String, DateTime> tombstones) async {
    try {
      final File file = await _resolveFile();
      final File temp = File('${file.path}.tmp');
      await temp.writeAsString(
        jsonEncode(<String, String>{
          for (final MapEntry<String, DateTime> e in tombstones.entries)
            e.key: e.value.toIso8601String(),
        }),
        flush: true,
      );
      await temp.rename(file.path);
    } catch (e) {
      Log.e(_tag, 'Save failed: $e');
    }
  }
}
