import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/core/utils/log.dart';
import 'package:flowhub/domain/entities/order/order.dart';
import 'package:path_provider/path_provider.dart';

abstract interface class IOrderHistoryDataSource {
  /// Appends one JSON line recording [order] as completed right now — never
  /// overwrites or rewrites the file, so this is safe to call every time an
  /// order newly enters DONE, even more than once for the same order (a
  /// manual redo shows up as two lines sharing the same `receivedAt` but
  /// different `completedAt`).
  Future<void> appendCompletedOrder(Order order);
}

/// Durable, append-only order-completion log for the exhibition period —
/// survives a FlowHub Leader restart, unlike [Order] state itself which
/// lives only in memory (see KdsState.initial()). One JSON object per line
/// (JSONL) rather than a database: exhibition-scale volume (a few hundred
/// orders/day) never needs the query power a real DB would add, and a plain
/// append is simpler and can't corrupt earlier entries if the app is killed
/// mid-write.
@Singleton(as: IOrderHistoryDataSource)
class OrderHistoryDataSource implements IOrderHistoryDataSource {
  static const _tag = 'OrderHistory';
  static const _fileName = 'order_history.jsonl';

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
  Future<void> appendCompletedOrder(Order order) async {
    try {
      final file = await _resolveFile();
      final record = {
        'completedAt': DateTime.now().toIso8601String(),
        'order': order.toJson(),
      };
      await file.writeAsString(
        '${jsonEncode(record)}\n',
        mode: FileMode.append,
        flush: true,
      );
      Log.d(_tag, 'Appended order history — ${order.orderNo} (${file.path})');
    } catch (e) {
      Log.e(_tag, 'Failed to append order history for ${order.orderNo}: $e');
    }
  }
}
