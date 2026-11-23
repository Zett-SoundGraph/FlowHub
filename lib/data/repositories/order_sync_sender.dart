import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flowhub/core/constants/cloud_constants.dart';
import 'package:flowhub/core/utils/cloud_format.dart';
import 'package:flowhub/core/utils/log.dart';
import 'package:flowhub/data/models/order_store/order_record_raw.dart';
import 'package:flowhub/data/sources/local/order_local_data_source.dart';
import 'package:flowhub/data/sources/remote/cloud_mqtt_data_source.dart';
import 'package:flowhub/data/sources/remote/flow_manager_api_data_source.dart';
import 'package:flowhub/domain/entities/cloud/cloud_identity.dart';
import 'package:flowhub/domain/entities/order_sync/order_sync_rejection.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// MQTT send state of one pending order version.
class _Attempt {
  _Attempt(this.version, {required this.sends, required this.nextAt});

  final int version;

  /// MQTT sends of this version so far (the first send + resends).
  int sends;

  /// When the next resend, or the move to REST, is due.
  DateTime nextAt;

  /// No REST send of this version before this time.
  DateTime? restAfter;
}

/// Sends the pending orders of the local order table to Flow Manager
/// (Flow Order sync).
///
/// - MQTT is the normal path: `flow/hub/{storeId}/{hubId}/orders`, acked on
///   `order-ack`. A version is resent after [resendDelays] without an ack.
/// - REST (`/api/v2/rest/order/sync`) is the safety net: after the third
///   resend (R3), while MQTT has been down for [mqttDownLimit] (R4), and
///   for the oldest orders past [backlogLimit] (R5).
/// - The hourly sweep resends over REST every order changed since the last
///   sweep (10 min overlap), even acked ones, back to [sweepMaxAge].
///
/// Whichever confirmation arrives first marks the version synced. A new
/// version always starts on MQTT again.
@lazySingleton
class OrderSyncSender {
  /// Lives as long as the app (lazy singleton): the listeners and timers
  /// below are never cancelled.
  OrderSyncSender(this._mqtt, this._store, this._api)
    : _now = DateTime.now,
      _random = Random(),
      _wait = Future<void>.delayed,
      _apiConfigured = CloudConstants.isApiConfigured {
    _start();
  }

  /// No listeners or timers: a test calls [tick], [sweep] and
  /// [handleMessage] itself, with its own clock.
  @visibleForTesting
  OrderSyncSender.manual(
    this._mqtt,
    this._store,
    this._api, {
    required DateTime Function() now,
    Random? random,
    Future<void> Function(Duration)? wait,
    bool apiConfigured = true,
  }) : _now = now,
       _random = random ?? Random(0),
       _wait = wait ?? ((Duration _) async {}),
       _apiConfigured = apiConfigured;

  static const String _tag = 'OrderSync';
  static const int schemaVersion = 4;

  /// Wait after each MQTT send without an ack: the 1st send, then the
  /// resends after 10 s, 20 s and 40 s (the 3rd resend is R3).
  static const List<Duration> resendDelays = <Duration>[
    Duration(seconds: 10),
    Duration(seconds: 20),
    Duration(seconds: 40),
    Duration(seconds: 40),
  ];
  static const Duration mqttDownLimit = Duration(seconds: 60);
  static const int backlogLimit = 100;
  static const int restBatchSize = 100;
  static const Duration restBackoffMin = Duration(seconds: 30);
  static const Duration restBackoffMax = Duration(minutes: 5);
  static const Duration sweepOverlap = Duration(minutes: 10);
  static const Duration sweepMaxAge = Duration(days: 7);

  /// Orders synced and off the board are deleted after this long (past the
  /// sweep's reach).
  static const Duration keepDone = Duration(days: 8);

  static const Duration _tickInterval = Duration(seconds: 2);
  static const int _pendingReadLimit = 1000;
  static const String _keyLastSweptAt = 'last_swept_at';
  static const String _keySweepMinute = 'sweep_minute';

  final ICloudMqttDataSource _mqtt;
  final IOrderLocalDataSource _store;
  final IFlowManagerApiDataSource _api;
  final DateTime Function() _now;
  final Random _random;
  final Future<void> Function(Duration) _wait;

  /// Whether the REST API URL and key are set (no REST without them).
  final bool _apiConfigured;

  /// MQTT send state per pending row (row ID).
  final Map<int, _Attempt> _attempts = <int, _Attempt>{};
  final StreamController<OrderSyncRejection> _rejections =
      StreamController<OrderSyncRejection>.broadcast();
  DateTime? _disconnectedSince;
  bool _ticking = false;
  bool _restBusy = false;
  int _restFailures = 0;
  DateTime? _restRetryAt;

  /// Order versions Flow Manager rejected for good.
  Stream<OrderSyncRejection> get rejections => _rejections.stream;

  /// 1. Subscribes `order-ack` for the current and every later identity.
  /// 2. Tracks the connection: since when it is down (R4); on reconnect
  ///    every pending order is sent again right away.
  /// 3. Ticks every [_tickInterval]; schedules the hourly sweep; deletes
  ///    old done orders.
  void _start() {
    _mqtt.identityStream.listen(_subscribeAck);
    final CloudIdentity? identity = _mqtt.identity;
    if (identity != null) _subscribeAck(identity);
    _mqtt.messages.listen(handleMessage);
    if (!_mqtt.isConnected) _disconnectedSince = _now();
    _mqtt.connectionStream.listen(handleConnection);
    Timer.periodic(_tickInterval, (_) => unawaited(tick()));
    unawaited(_scheduleSweep());
    unawaited(_prune());
  }

  /// Connected: every pending order is sent again right away. Lost: notes
  /// since when, for R4.
  @visibleForTesting
  void handleConnection(bool connected) {
    if (connected) {
      _disconnectedSince = null;
      _attempts.clear();
      unawaited(tick());
    } else {
      _disconnectedSince ??= _now();
    }
  }

  /// Sends what is due now (called after a save and every tick).
  /// 1. Nothing to do without a cloud identity.
  /// 2. R5: past [backlogLimit] pending, the oldest go to REST (BACKLOG).
  /// 3. R4: MQTT down for [mqttDownLimit] → REST (FALLBACK).
  /// 4. Otherwise MQTT: a new version is sent now, then resent after
  ///    [resendDelays]; after the 3rd resend it goes to REST (R3).
  Future<void> tick() async {
    if (_ticking) return;
    _ticking = true;
    try {
      final CloudIdentity? identity = _mqtt.identity;
      if (identity == null) return;
      final DateTime now = _now();
      final List<OrderRecordRaw> pending = await _store.pending(
        limit: _pendingReadLimit,
      );
      final Set<int?> pendingIds = pending.map((r) => r.id).toSet();
      _attempts.removeWhere((int id, _) => !pendingIds.contains(id));
      if (pending.isEmpty) return;

      final List<OrderRecordRaw> backlog = <OrderRecordRaw>[];
      final List<OrderRecordRaw> fallback = <OrderRecordRaw>[];
      List<OrderRecordRaw> live = pending;
      if (pending.length > backlogLimit) {
        backlog.addAll(pending.sublist(0, pending.length - backlogLimit));
        live = pending.sublist(pending.length - backlogLimit);
      }
      final bool connected = _mqtt.isConnected;
      final DateTime? downSince = _disconnectedSince;
      final bool mqttDown =
          !connected &&
          downSince != null &&
          now.difference(downSince) >= mqttDownLimit;

      for (final OrderRecordRaw record in live) {
        _Attempt? attempt = _attempts[record.id];
        if (attempt != null && attempt.version != record.version) {
          attempt = null;
          _attempts.remove(record.id);
        }
        if (mqttDown) {
          fallback.add(record);
          continue;
        }
        if (!connected) continue;
        if (attempt == null) {
          _publish(identity, record, now, sends: 0);
        } else if (!now.isBefore(attempt.nextAt)) {
          if (attempt.sends < resendDelays.length) {
            _publish(identity, record, now, sends: attempt.sends);
          } else {
            fallback.add(record);
          }
        }
      }
      final List<({OrderRecordRaw record, String reason})> rest =
          <({OrderRecordRaw record, String reason})>[
            for (final OrderRecordRaw r in backlog)
              if (_restAllowed(r, now)) (record: r, reason: 'BACKLOG'),
            for (final OrderRecordRaw r in fallback)
              if (_restAllowed(r, now)) (record: r, reason: 'FALLBACK'),
          ];
      final DateTime? retryAt = _restRetryAt;
      if (rest.isNotEmpty &&
          _apiConfigured &&
          !_restBusy &&
          (retryAt == null || !now.isBefore(retryAt))) {
        await _sendFallback(identity, rest);
      }
    } catch (e) {
      Log.e(_tag, 'Tick failed: $e');
    } finally {
      _ticking = false;
    }
  }

  bool _restAllowed(OrderRecordRaw record, DateTime now) {
    final DateTime? after = _attempts[record.id]?.restAfter;
    return after == null || !now.isBefore(after);
  }

  /// One MQTT send; the next one is due after `resendDelays[sends]`.
  void _publish(
    CloudIdentity identity,
    OrderRecordRaw record,
    DateTime now, {
    required int sends,
  }) {
    if (!_mqtt.publish(_ordersTopic(identity), _message(identity, record))) {
      return;
    }
    final int count = sends + 1;
    final _Attempt attempt = _attempts.putIfAbsent(
      record.id!,
      () => _Attempt(record.version, sends: 0, nextAt: now),
    );
    attempt
      ..sends = count
      ..nextAt = now.add(resendDelays[count - 1]);
    Log.d(_tag, 'Published ${record.orderNo} v${record.version} (send $count)');
  }

  /// Sends [items] over REST, by reason, [restBatchSize] at a time.
  /// 1. A failed request stops the rest: no response, 5xx and 429 retry
  ///    after a growing backoff ([restBackoffMin]..[restBackoffMax]); any
  ///    other 4xx pauses REST for [restBackoffMax].
  /// 2. Every sent order gets `restAfter`, so the same version is not sent
  ///    on REST again within [restBackoffMin]; its MQTT cycle starts over.
  Future<void> _sendFallback(
    CloudIdentity identity,
    List<({OrderRecordRaw record, String reason})> items,
  ) async {
    _restBusy = true;
    try {
      for (final String reason in <String>['FALLBACK', 'BACKLOG']) {
        final List<OrderRecordRaw> records = <OrderRecordRaw>[
          for (final item in items)
            if (item.reason == reason) item.record,
        ];
        for (int i = 0; i < records.length; i += restBatchSize) {
          final List<OrderRecordRaw> batch = records.sublist(
            i,
            min(i + restBatchSize, records.length),
          );
          final DateTime now = _now();
          for (final OrderRecordRaw record in batch) {
            _attempts[record.id!] = _Attempt(
              record.version,
              sends: 0,
              nextAt: now.add(resendDelays.first),
            )..restAfter = now.add(restBackoffMin);
          }
          final _RestOutcome outcome = await _post(identity, batch, reason);
          if (outcome == _RestOutcome.ok) {
            _restFailures = 0;
            _restRetryAt = null;
            continue;
          }
          if (outcome == _RestOutcome.retry) {
            _restFailures++;
            _restRetryAt = _now().add(_backoff(_restFailures));
          } else {
            _restRetryAt = _now().add(restBackoffMax);
          }
          return;
        }
      }
    } finally {
      _restBusy = false;
    }
  }

  /// One REST request; applies the results when it succeeds.
  Future<_RestOutcome> _post(
    CloudIdentity identity,
    List<OrderRecordRaw> batch,
    String reason,
  ) async {
    try {
      final List<Map<String, dynamic>> results = await _api.syncOrders(
        storeId: identity.storeId,
        hubId: identity.hubId,
        reason: reason,
        orders: <Map<String, dynamic>>[
          for (final OrderRecordRaw record in batch) _message(identity, record),
        ],
      );
      Log.i(_tag, 'REST $reason: ${batch.length} order(s) sent');
      for (int i = 0; i < batch.length; i++) {
        final Map<String, dynamic> result = i < results.length
            ? results[i]
            : const <String, dynamic>{};
        // Results come in request order, so each is this batch row's own.
        await _apply(
          orderNo: batch[i].orderNo,
          version: (result['version'] as num?)?.toInt() ?? batch[i].version,
          status: result['status']?.toString() ?? '',
          error: result['error']?.toString() ?? '',
          route: 'REST',
          id: batch[i].id,
        );
      }
      return _RestOutcome.ok;
    } catch (e) {
      final int status = e is ServerException ? e.statusCode : 0;
      final bool retry = status == -1 || status == 429 || status >= 500;
      Log.w(
        _tag,
        'REST $reason failed (${batch.length} order(s), HTTP $status): $e'
        '${retry ? '' : ' — not retried'}',
      );
      return retry ? _RestOutcome.retry : _RestOutcome.stop;
    }
  }

  /// [restBackoffMin] doubling per failure up to [restBackoffMax], ±20 %.
  Duration _backoff(int failures) {
    final int base = min(
      restBackoffMin.inMilliseconds * pow(2, failures - 1).toInt(),
      restBackoffMax.inMilliseconds,
    );
    final double jitter = 0.8 + _random.nextDouble() * 0.4;
    return Duration(milliseconds: (base * jitter).round());
  }

  /// Handles an `order-ack` (matched by orderNo + version).
  @visibleForTesting
  void handleMessage(CloudMqttMessage message) {
    final CloudIdentity? identity = _mqtt.identity;
    if (identity == null || message.topic != _ackTopic(identity)) return;
    final Map<String, dynamic> json = message.json;
    final String orderNo = json['orderNo']?.toString() ?? '';
    final int version = (json['version'] as num?)?.toInt() ?? 0;
    if (orderNo.isEmpty || version < 1) {
      Log.w(_tag, 'order-ack without orderNo/version: $json');
      return;
    }
    unawaited(
      _apply(
        orderNo: orderNo,
        version: version,
        status: json['status']?.toString() ?? '',
        error: json['error']?.toString() ?? '',
        route: 'MQTT',
      ).catchError((Object e) => Log.e(_tag, 'Ack failed: $e')),
    );
  }

  /// Applies one result, from an MQTT ack or a REST response. A REST result
  /// carries its row [id]; an MQTT ack (orderNo + version) goes to the
  /// oldest row of that orderNo still waiting for the version.
  /// 1. UPDATED / ALREADY_CURRENT → synced_version = max(…, version).
  /// 2. REJECTED → that version is not sent again; logged and announced on
  ///    [rejections].
  /// 3. HELD (REST only) or no status → stays pending and is sent again.
  Future<void> _apply({
    required String orderNo,
    required int version,
    required String status,
    required String error,
    required String route,
    int? id,
  }) async {
    switch (status) {
      case 'UPDATED':
      case 'ALREADY_CURRENT':
        await _store.markSynced(orderNo, version, id: id);
        Log.d(_tag, 'Synced $orderNo v$version ($status, $route)');
      case 'REJECTED':
        await _store.markRejected(orderNo, version, id: id);
        Log.e(
          _tag,
          'Order $orderNo v$version REJECTED by Flow Manager via $route '
          '(${error.isEmpty ? 'no reason' : error}) — not sending this '
          'version again',
        );
        _rejections.add(
          OrderSyncRejection(orderNo: orderNo, version: version, error: error),
        );
      case 'HELD':
        Log.w(_tag, 'Order $orderNo v$version HELD ($error) — kept for resend');
      default:
        Log.w(_tag, 'Unknown result "$status" for $orderNo v$version ($route)');
    }
  }

  /// Runs [sweep] every hour at this hub's own minute.
  Future<void> _scheduleSweep() async {
    try {
      final int minute = await _sweepMinute();
      final DateTime now = _now();
      DateTime next = DateTime(now.year, now.month, now.day, now.hour, minute);
      if (!next.isAfter(now)) next = next.add(const Duration(hours: 1));
      Timer(next.difference(now), () async {
        await sweep();
        unawaited(_scheduleSweep());
      });
    } catch (e) {
      Log.e(_tag, 'Sweep schedule failed: $e');
    }
  }

  /// This hub's sweep minute: picked at random once, then kept.
  Future<int> _sweepMinute() async {
    final int? stored = int.tryParse(
      await _store.readState(_keySweepMinute) ?? '',
    );
    if (stored != null && stored >= 0 && stored < 60) return stored;
    final int minute = _random.nextInt(60);
    await _store.writeState(_keySweepMinute, '$minute');
    return minute;
  }

  /// The hourly sweep.
  /// 1. Skipped without a cloud identity or the REST API settings.
  /// 2. Sends every order changed since `last_swept_at` − [sweepOverlap]
  ///    (at most [sweepMaxAge] back), acked ones included, oldest first,
  ///    [restBatchSize] at a time (reason HOURLY_SWEEP).
  /// 3. A batch that fails with no response, 5xx or 429 is retried after a
  ///    growing backoff; any other 4xx ends the sweep.
  /// 4. `last_swept_at` is saved only when every batch got HTTP 200.
  /// 5. Deletes old done orders.
  Future<void> sweep() async {
    final CloudIdentity? identity = _mqtt.identity;
    if (identity == null || !_apiConfigured) {
      Log.d(_tag, 'Sweep skipped: no cloud identity or REST API settings');
      return;
    }
    try {
      final DateTime startedAt = _now();
      final DateTime floor = startedAt.subtract(sweepMaxAge);
      final DateTime? last = DateTime.tryParse(
        await _store.readState(_keyLastSweptAt) ?? '',
      );
      DateTime since = last?.subtract(sweepOverlap) ?? floor;
      if (since.isBefore(floor)) since = floor;
      OrderCursor? cursor;
      int sent = 0;
      while (true) {
        final List<OrderRecordRaw> batch = await _store.changedSince(
          since,
          after: cursor,
          limit: restBatchSize,
        );
        if (batch.isEmpty) break;
        int failures = 0;
        while (true) {
          final _RestOutcome outcome = await _post(
            identity,
            batch,
            'HOURLY_SWEEP',
          );
          if (outcome == _RestOutcome.ok) break;
          if (outcome == _RestOutcome.stop) {
            Log.w(_tag, 'Sweep stopped after $sent order(s)');
            return;
          }
          failures++;
          await _wait(_backoff(failures));
        }
        sent += batch.length;
        cursor = (updatedAt: batch.last.updatedAt, id: batch.last.id!);
        if (batch.length < restBatchSize) break;
      }
      await _store.writeState(_keyLastSweptAt, startedAt.toIso8601String());
      Log.i(
        _tag,
        'Sweep done: $sent order(s) since ${since.toIso8601String()}',
      );
    } catch (e) {
      Log.e(_tag, 'Sweep failed: $e');
    }
    await _prune();
  }

  Future<void> _prune() async {
    try {
      final int deleted = await _store.deleteDoneBefore(
        _now().subtract(keepDone),
      );
      if (deleted > 0) Log.i(_tag, 'Deleted $deleted old synced order(s)');
    } catch (e) {
      Log.e(_tag, 'Prune failed: $e');
    }
  }

  /// The MQTT order message; the REST elements are exactly this.
  Map<String, dynamic> _message(CloudIdentity identity, OrderRecordRaw record) {
    final Map<String, dynamic> order =
        jsonDecode(record.syncJson) as Map<String, dynamic>;
    return <String, dynamic>{
      'schemaVersion': schemaVersion,
      'eventId': CloudFormat.uuidV4(),
      'eventType': _eventType(order, record.version),
      'storeId': identity.storeId,
      'hubId': identity.hubId,
      'version': record.version,
      'occurredAt': CloudFormat.timestamp(record.updatedAt),
      'order': order,
    };
  }

  static String _eventType(Map<String, dynamic> order, int version) {
    final Object? tab = order['tab'];
    if (tab == 'CANCELLED') return 'ORDER_CANCELLED';
    if (tab == 'DONE') return 'ORDER_COMPLETED';
    return version == 1 ? 'ORDER_CREATED' : 'ORDER_UPDATED';
  }

  String _ordersTopic(CloudIdentity identity) =>
      '${identity.hubTopicPrefix}/orders';

  String _ackTopic(CloudIdentity identity) =>
      '${identity.hubTopicPrefix}/order-ack';

  void _subscribeAck(CloudIdentity identity) =>
      _mqtt.subscribe(_ackTopic(identity));
}

enum _RestOutcome { ok, retry, stop }
