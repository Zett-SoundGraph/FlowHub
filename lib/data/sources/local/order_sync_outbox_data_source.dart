import 'dart:convert';
import 'dart:io';

import 'package:flowhub/core/utils/log.dart';
import 'package:flowhub/data/models/order_sync/order_sync_entry_raw.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

/// Order sync state per order, on disk so versions never go back and pending
/// versions are resent after a restart.
abstract interface class IOrderSyncOutboxDataSource {
  /// Reads every entry, keyed by orderNo; empty when there is no file yet or
  /// it can't be read.
  Future<Map<String, OrderSyncEntryRaw>> load();

  /// Replaces the stored entries with [entries].
  Future<void> save(Map<String, OrderSyncEntryRaw> entries);
}

/// A single JSON file in the app support directory, written to a temporary
/// file first and then renamed, so a crash mid-write never leaves half a file.
@Singleton(as: IOrderSyncOutboxDataSource)
class OrderSyncOutboxDataSource implements IOrderSyncOutboxDataSource {
  static const String _tag = 'OrderSyncOutbox';
  static const String _fileName = 'order_sync_outbox.json';

  File? _file;

  Future<File> _resolveFile() async {
    final File? cached = _file;
    if (cached != null) return cached;
    final Directory dir = await getApplicationSupportDirectory();
    return _file = File('${dir.path}${Platform.pathSeparator}$_fileName');
  }

  @override
  Future<Map<String, OrderSyncEntryRaw>> load() async {
    try {
      final File file = await _resolveFile();
      if (!await file.exists()) return <String, OrderSyncEntryRaw>{};
      final Object? decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) return <String, OrderSyncEntryRaw>{};
      final Map<String, OrderSyncEntryRaw> entries =
          <String, OrderSyncEntryRaw>{};
      for (final Object? item in decoded) {
        if (item is! Map<String, dynamic>) continue;
        final OrderSyncEntryRaw entry = OrderSyncEntryRaw.fromJson(item);
        if (entry.orderNo.isNotEmpty) entries[entry.orderNo] = entry;
      }
      return entries;
    } catch (e) {
      Log.e(_tag, 'Load failed: $e');
      return <String, OrderSyncEntryRaw>{};
    }
  }

  @override
  Future<void> save(Map<String, OrderSyncEntryRaw> entries) async {
    try {
      final File file = await _resolveFile();
      final File temp = File('${file.path}.tmp');
      await temp.writeAsString(
        jsonEncode(entries.values.map((e) => e.toJson()).toList()),
        flush: true,
      );
      await temp.rename(file.path);
    } catch (e) {
      Log.e(_tag, 'Save failed: $e');
    }
  }
}
