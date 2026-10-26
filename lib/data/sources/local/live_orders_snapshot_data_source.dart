import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/core/utils/log.dart';
import 'package:flowhub/domain/entities/order/order.dart';
import 'package:path_provider/path_provider.dart';

abstract interface class ILiveOrdersSnapshotDataSource {
  /// Overwrites the snapshot with [orders] — called right before a manual
  /// Reboot kills the process, so [load] can restore them once the fresh
  /// process starts back up. Never called by the daily auto-reboot, which
  /// wants every order gone instead — see [clear].
  Future<void> save(List<Order> orders);

  /// Reads back whatever [save] last wrote, or an empty list if there is no
  /// snapshot (normal cold boot, or after [clear]) or it fails to parse.
  Future<List<Order>> load();

  /// Deletes the snapshot file, if any. Called once a [load] has already
  /// consumed it, so a later *unrelated* restart (e.g. after a crash) doesn't
  /// replay stale orders, and by the daily auto-reboot, which wants a
  /// completely empty board on the other side regardless of what was saved.
  Future<void> clear();
}

/// One-shot local snapshot of the leader's live [Order] list, used only to
/// carry orders across the Reboot feature's real process kill+relaunch (see
/// RestartAppUseCase / MainActivity.kt's "restartApp") — FlowHubState.orders
/// otherwise lives only in memory and would be lost by that restart
/// (FlowHubState.initial() always starts with an empty list). A single
/// overwritten JSON file (like caye_key_data_source.dart), not the
/// append-only JSONL style of order_history_data_source.dart, since only the
/// latest snapshot ever matters.
@Singleton(as: ILiveOrdersSnapshotDataSource)
class LiveOrdersSnapshotDataSource implements ILiveOrdersSnapshotDataSource {
  static const String _tag = 'LiveOrdersSnapshot';
  static const String _fileName = 'live_orders_snapshot.json';

  File? _file;

  Future<File> _resolveFile() async {
    final File? cached = _file;
    if (cached != null) return cached;
    final Directory dir = await getApplicationSupportDirectory();
    final File file = File('${dir.path}${Platform.pathSeparator}$_fileName');
    _file = file;
    return file;
  }

  @override
  Future<void> save(List<Order> orders) async {
    try {
      final File file = await _resolveFile();
      final String json = jsonEncode(
        orders.map((Order o) => o.toJson()).toList(),
      );
      await file.writeAsString(json, flush: true);
      Log.d(_tag, 'Saved ${orders.length} order(s) (${file.path})');
    } catch (e) {
      Log.e(_tag, 'Failed to save orders snapshot: $e');
    }
  }

  @override
  Future<List<Order>> load() async {
    try {
      final File file = await _resolveFile();
      if (!await file.exists()) return const <Order>[];
      final String content = await file.readAsString();
      if (content.trim().isEmpty) return const <Order>[];
      final List<dynamic> decoded = jsonDecode(content) as List<dynamic>;
      return decoded
          .map((dynamic e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Log.e(_tag, 'Failed to load orders snapshot: $e');
      return const <Order>[];
    }
  }

  @override
  Future<void> clear() async {
    try {
      final File file = await _resolveFile();
      if (await file.exists()) await file.delete();
    } catch (e) {
      Log.e(_tag, 'Failed to clear orders snapshot: $e');
    }
  }
}
