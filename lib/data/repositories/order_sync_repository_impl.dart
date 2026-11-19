import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flowhub/core/utils/cloud_format.dart';
import 'package:flowhub/core/utils/log.dart';
import 'package:flowhub/data/mappers/order_sync_mapper.dart';
import 'package:flowhub/data/models/order_sync/order_sync_entry_raw.dart';
import 'package:flowhub/data/sources/local/order_sync_outbox_data_source.dart';
import 'package:flowhub/data/sources/remote/cloud_mqtt_data_source.dart';
import 'package:flowhub/domain/entities/cloud/cloud_identity.dart';
import 'package:flowhub/domain/entities/order/order.dart';
import 'package:flowhub/domain/repositories/order_sync_repository.dart';
import 'package:injectable/injectable.dart' hide Order;

@LazySingleton(as: OrderSyncRepository)
class OrderSyncRepositoryImpl implements OrderSyncRepository {
  /// Lives as long as the app (lazy singleton), so the listeners and the
  /// retry timer below are never cancelled.
  /// 1. Subscribes `order-ack` for the current and every later identity.
  /// 2. Handles acks; publishes everything pending on each (re)connect.
  /// 3. Retries pending versions every [_retryTick].
  OrderSyncRepositoryImpl(this._mqtt, this._outbox) {
    _mqtt.identityStream.listen(_subscribeAck);
    final CloudIdentity? identity = _mqtt.identity;
    if (identity != null) {
      _subscribeAck(identity);
    }
    _mqtt.messages.listen(_handleMessage);
    _mqtt.connectionStream.listen((bool connected) {
      if (connected) {
        _flush(force: true);
      }
    });
    Timer.periodic(_retryTick, (_) => _flush());
  }

  static const String _tag = 'OrderSync';
  static const int _schemaVersion = 4;
  static const Duration _retryTick = Duration(seconds: 5);
  static const Duration _firstBackoff = Duration(seconds: 5);
  static const Duration _maxBackoff = Duration(seconds: 60);

  /// Acked entries older than this are dropped from the outbox.
  static const Duration _keepSynced = Duration(days: 3);

  final ICloudMqttDataSource _mqtt;
  final IOrderSyncOutboxDataSource _outbox;
  final Map<String, ({int attempts, DateTime nextAt})> _backoff =
      <String, ({int attempts, DateTime nextAt})>{};

  Future<Map<String, OrderSyncEntryRaw>>? _entriesFuture;

  /// Serializes outbox changes: a [record] and an ack never interleave.
  Future<void> _queue = Future<void>.value();

  Future<Map<String, OrderSyncEntryRaw>> get _entries =>
      _entriesFuture ??= _loadEntries();

  Future<Map<String, OrderSyncEntryRaw>> _loadEntries() async {
    final Map<String, OrderSyncEntryRaw> entries = await _outbox.load();
    final DateTime cutoff = DateTime.now().subtract(_keepSynced);
    entries.removeWhere(
      (_, OrderSyncEntryRaw e) => !e.isPending && e.updatedAt.isBefore(cutoff),
    );
    final int pending = entries.values.where((e) => e.isPending).length;
    Log.i(_tag, 'Outbox loaded: ${entries.length} order(s), $pending pending');
    return entries;
  }

  Future<void> _serialized(Future<void> Function() action) {
    final Future<void> next = _queue.then((_) => action());
    _queue = next.catchError((Object e) => Log.e(_tag, 'Outbox error: $e'));
    return next;
  }

  /// 1. Builds each order's sync snapshot; an order with an empty orderNo is
  ///    skipped.
  /// 2. New order → version 1 with orderedAt fixed from its receivedAt.
  ///    Changed snapshot → version+1. Unchanged → nothing.
  /// 3. Saves the outbox when anything changed, then publishes the changed
  ///    orders right away.
  @override
  Future<void> record(List<Order> orders) => _serialized(() async {
    final Map<String, OrderSyncEntryRaw> entries = await _entries;
    final List<String> changed = <String>[];
    final DateTime now = DateTime.now();
    for (final Order order in orders) {
      if (order.orderNo.isEmpty) continue;
      final OrderSyncEntryRaw? entry = entries[order.orderNo];
      final String orderedAt =
          entry?.orderedAt ?? CloudFormat.timestamp(order.receivedAt ?? now);
      final Map<String, dynamic> snapshot = order.toSyncOrder(
        orderedAt: orderedAt,
      );
      final String digest = jsonEncode(snapshot);
      if (entry == null) {
        entries[order.orderNo] = OrderSyncEntryRaw(
          orderNo: order.orderNo,
          orderedAt: orderedAt,
          version: 1,
          syncedVersion: 0,
          digest: digest,
          order: snapshot,
          updatedAt: now,
        );
      } else if (entry.digest != digest) {
        entry
          ..version += 1
          ..digest = digest
          ..order = snapshot
          ..updatedAt = now;
      } else {
        continue;
      }
      changed.add(order.orderNo);
    }
    if (changed.isEmpty) return;
    await _outbox.save(entries);
    for (final String orderNo in changed) {
      _backoff.remove(orderNo);
    }
    _flush();
  });

  /// Publishes every pending version whose backoff has run out ([force]
  /// ignores the backoff, e.g. right after reconnecting).
  /// 1. Nothing to do without a cloud identity or connection.
  /// 2. Each publish pushes that order's next attempt out: 5 s, doubling,
  ///    capped at 60 s, until the ack arrives.
  void _flush({bool force = false}) {
    final CloudIdentity? identity = _mqtt.identity;
    if (identity == null || !_mqtt.isConnected) return;
    unawaited(_entries.then((Map<String, OrderSyncEntryRaw> entries) {
      final DateTime now = DateTime.now();
      for (final OrderSyncEntryRaw entry in entries.values) {
        if (!entry.isPending) continue;
        final ({int attempts, DateTime nextAt})? backoff =
            _backoff[entry.orderNo];
        if (!force && backoff != null && now.isBefore(backoff.nextAt)) {
          continue;
        }
        if (!_mqtt.publish(_ordersTopic(identity), _message(identity, entry))) {
          return;
        }
        final int attempts = (backoff?.attempts ?? 0) + 1;
        final int seconds = min(
          _firstBackoff.inSeconds * pow(2, attempts - 1).toInt(),
          _maxBackoff.inSeconds,
        );
        _backoff[entry.orderNo] = (
          attempts: attempts,
          nextAt: now.add(Duration(seconds: seconds)),
        );
        Log.d(
          _tag,
          'Published ${entry.orderNo} v${entry.version} (attempt $attempts)',
        );
      }
    }));
  }

  Map<String, dynamic> _message(
    CloudIdentity identity,
    OrderSyncEntryRaw entry,
  ) => <String, dynamic>{
    'schemaVersion': _schemaVersion,
    'eventId': CloudFormat.uuidV4(),
    'eventType': _eventType(entry),
    'storeId': identity.storeId,
    'hubId': identity.hubId,
    'version': entry.version,
    'occurredAt': CloudFormat.timestamp(entry.updatedAt),
    'order': entry.order,
  };

  String _eventType(OrderSyncEntryRaw entry) {
    final Object? tab = entry.order['tab'];
    if (tab == 'CANCELLED') return 'ORDER_CANCELLED';
    if (tab == 'DONE') return 'ORDER_COMPLETED';
    return entry.version == 1 ? 'ORDER_CREATED' : 'ORDER_UPDATED';
  }

  String _ordersTopic(CloudIdentity identity) =>
      '${identity.hubTopicPrefix}/orders';

  String _ackTopic(CloudIdentity identity) =>
      '${identity.hubTopicPrefix}/order-ack';

  void _subscribeAck(CloudIdentity identity) =>
      _mqtt.subscribe(_ackTopic(identity));

  /// Handles `order-ack`, matched by orderNo + version (never eventId).
  /// 1. UPDATED / ALREADY_CURRENT → syncedVersion = max(syncedVersion, version).
  /// 2. REJECTED → stop resending that version and log the error locally.
  /// 3. No ack → the version stays pending and is resent.
  void _handleMessage(CloudMqttMessage message) {
    final CloudIdentity? identity = _mqtt.identity;
    if (identity == null || message.topic != _ackTopic(identity)) return;
    final Map<String, dynamic> json = message.json;
    final String orderNo = json['orderNo']?.toString() ?? '';
    final int version = (json['version'] as num?)?.toInt() ?? 0;
    final String status = json['status']?.toString() ?? '';
    if (orderNo.isEmpty || version < 1) {
      Log.w(_tag, 'order-ack without orderNo/version: $json');
      return;
    }
    unawaited(_serialized(() async {
      final Map<String, OrderSyncEntryRaw> entries = await _entries;
      final OrderSyncEntryRaw? entry = entries[orderNo];
      if (entry == null) return;
      switch (status) {
        case 'UPDATED':
        case 'ALREADY_CURRENT':
          Log.d(_tag, 'Ack $orderNo v$version $status');
        case 'REJECTED':
          Log.e(
            _tag,
            'Order $orderNo v$version REJECTED (${json['error']}) — '
            'not resending this version',
          );
        default:
          Log.w(_tag, 'Unknown order-ack status "$status" for $orderNo');
          return;
      }
      if (version > entry.syncedVersion) {
        entry.syncedVersion = version;
        if (!entry.isPending) _backoff.remove(orderNo);
        await _outbox.save(entries);
      }
    }));
  }

}
