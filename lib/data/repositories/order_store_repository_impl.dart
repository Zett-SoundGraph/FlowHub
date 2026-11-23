import 'dart:async';
import 'dart:convert';

import 'package:flowhub/core/utils/cloud_format.dart';
import 'package:flowhub/core/utils/log.dart';
import 'package:flowhub/data/mappers/order_sync_mapper.dart';
import 'package:flowhub/data/models/order_store/order_record_raw.dart';
import 'package:flowhub/data/repositories/order_sync_sender.dart';
import 'package:flowhub/data/sources/local/order_local_data_source.dart';
import 'package:flowhub/domain/entities/order/order.dart';
import 'package:flowhub/domain/entities/order_sync/order_sync_rejection.dart';
import 'package:flowhub/domain/repositories/order_store_repository.dart';
import 'package:injectable/injectable.dart' hide Order;

@LazySingleton(as: OrderStoreRepository)
class OrderStoreRepositoryImpl implements OrderStoreRepository {
  OrderStoreRepositoryImpl(this._store, this._sender);

  static const String _tag = 'OrderStore';

  final IOrderLocalDataSource _store;
  final OrderSyncSender _sender;

  /// Serializes the writes: two saves never interleave.
  Future<void> _queue = Future<void>.value();

  Future<void> _serialized(Future<void> Function() action) {
    final Future<void> next = _queue.then((_) => action());
    _queue = next.catchError((Object e) => Log.e(_tag, 'Write failed: $e'));
    return next;
  }

  /// 1. Reads the stored rows of [orders] (an order with an empty orderNo
  ///    can't be stored and is skipped) and finds each order's own row (see
  ///    [_rowOf]): the same number on an earlier day is another order.
  /// 2. Builds each order's sync snapshot with its first `orderedAt`. New
  ///    order → version 1; changed snapshot → version+1 with this snapshot;
  ///    unchanged → same version, snapshot and change time. `progress`
  ///    alone is not a change: it rides along with the next real one.
  /// 3. Writes them all as the live orders in one transaction, then sends
  ///    the changed ones.
  @override
  Future<void> save(List<Order> orders) => _serialized(() async {
    final List<Order> stored = <Order>[
      for (final Order order in orders)
        if (order.orderNo.isNotEmpty) order,
    ];
    if (stored.length != orders.length) {
      Log.w(_tag, '${orders.length - stored.length} order(s) without orderNo');
    }
    final Map<String, List<OrderRecordRaw>> existing = await _store
        .findByOrderNos(stored.map((Order o) => o.orderNo));
    final DateTime now = DateTime.now();
    bool changed = false;
    final Set<int> taken = <int>{};
    final List<OrderRecordRaw> records = <OrderRecordRaw>[];
    for (final Order order in stored) {
      final OrderRecordRaw? row = _rowOf(
        order,
        existing[order.orderNo] ?? const <OrderRecordRaw>[],
        taken,
      );
      if (row?.id != null) taken.add(row!.id!);
      final String orderedAt = row != null && row.orderedAt.isNotEmpty
          ? row.orderedAt
          : CloudFormat.timestamp(order.receivedAt ?? now);
      final Map<String, dynamic> snapshot = order.toSyncOrder(
        orderedAt: orderedAt,
      );
      final bool isChange =
          row == null || _changeKey(row.syncJson) != _keyOf(snapshot);
      changed |= isChange;
      records.add(
        OrderRecordRaw(
          id: row?.id,
          orderNo: order.orderNo,
          orderJson: jsonEncode(order.toJson()),
          syncJson: isChange ? jsonEncode(snapshot) : row.syncJson,
          orderedAt: orderedAt,
          version: isChange ? (row?.version ?? 0) + 1 : row.version,
          syncedVersion: row?.syncedVersion ?? 0,
          rejectedVersion: row?.rejectedVersion ?? 0,
          updatedAt: isChange ? now : row.updatedAt,
          live: true,
        ),
      );
    }
    await _store.saveLive(records);
    if (changed) unawaited(_sender.tick());
  });

  /// The stored row of [order] among [rows] (same orderNo), skipping rows
  /// already [taken] by this save; null for a new order.
  /// 1. The row whose orderedAt is the order's receive time. Kiosk numbers
  ///    restart every day, so a row of the same number with another time is
  ///    an earlier order (Flow Manager also tells them apart by orderedAt).
  /// 2. Otherwise a live row without that match: imported from the old
  ///    JSON store (no orderedAt yet), or an order with no receive time.
  static OrderRecordRaw? _rowOf(
    Order order,
    List<OrderRecordRaw> rows,
    Set<int> taken,
  ) {
    final DateTime? receivedAt = order.receivedAt;
    final String? orderedAt = receivedAt == null
        ? null
        : CloudFormat.timestamp(receivedAt);
    final Iterable<OrderRecordRaw> free = rows.where(
      (OrderRecordRaw r) => !taken.contains(r.id),
    );
    for (final OrderRecordRaw r in free) {
      if (orderedAt != null && r.orderedAt == orderedAt) return r;
    }
    for (final OrderRecordRaw r in free) {
      if (r.live && (r.orderedAt.isEmpty || orderedAt == null)) return r;
    }
    return null;
  }

  /// [snapshot] as JSON text without `progress` (order and items): what
  /// decides whether the order changed.
  static String _keyOf(Map<String, dynamic> snapshot) =>
      jsonEncode(<String, dynamic>{
        for (final MapEntry<String, dynamic> e in snapshot.entries)
          if (e.key != 'progress')
            e.key: e.key == 'items' && e.value is List
                ? <Object?>[
                    for (final Object? item in e.value as List)
                      item is Map<String, dynamic>
                          ? (Map<String, dynamic>.of(item)..remove('progress'))
                          : item,
                  ]
                : e.value,
      });

  /// [_keyOf] of a stored snapshot; empty when there is none or it can't be
  /// read (then the next save is a change).
  static String _changeKey(String syncJson) {
    if (syncJson.isEmpty) return '';
    try {
      return _keyOf(jsonDecode(syncJson) as Map<String, dynamic>);
    } catch (_) {
      // intentional: an unreadable snapshot just counts as changed.
      return '';
    }
  }

  /// Restores the live orders; a row that can't be read is skipped.
  @override
  Future<List<Order>> loadLive() async {
    final List<String> rows = await _store.loadLiveOrderJson();
    final List<Order> orders = <Order>[];
    for (final String json in rows) {
      try {
        orders.add(Order.fromJson(jsonDecode(json) as Map<String, dynamic>));
      } catch (e) {
        Log.e(_tag, 'Unreadable stored order: $e');
      }
    }
    Log.i(_tag, 'Loaded ${orders.length} live order(s)');
    return orders;
  }

  @override
  Future<void> clearLive() => _serialized(_store.clearLive);

  @override
  Stream<OrderSyncRejection> get rejections => _sender.rejections;
}
