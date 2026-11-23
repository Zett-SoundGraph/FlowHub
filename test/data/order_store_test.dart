import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flowhub/core/utils/cloud_format.dart';
import 'package:flowhub/data/mappers/order_sync_mapper.dart';
import 'package:flowhub/data/models/order_store/order_record_raw.dart';
import 'package:flowhub/data/repositories/order_store_repository_impl.dart';
import 'package:flowhub/data/repositories/order_sync_sender.dart';
import 'package:flowhub/data/sources/local/order_local_data_source.dart';
import 'package:flowhub/data/sources/remote/cloud_mqtt_data_source.dart';
import 'package:flowhub/data/sources/remote/flow_manager_api_data_source.dart';
import 'package:flowhub/domain/entities/cloud/cloud_identity.dart';
import 'package:flowhub/domain/entities/order/order.dart';
import 'package:flowhub/domain/entities/order_sync/order_sync_rejection.dart';
import 'package:flowhub/domain/entities/sub_item/sub_item.dart';
import 'package:flowhub/domain/enums/order_status.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _FakeMqtt implements ICloudMqttDataSource {
  final List<({String topic, Map<String, dynamic> payload})> published =
      <({String topic, Map<String, dynamic> payload})>[];
  final Set<String> subscribed = <String>{};

  @override
  CloudIdentity? identity = const CloudIdentity(storeId: 'S1', hubId: 'H1');

  @override
  bool isConnected = true;

  @override
  Stream<bool> get connectionStream => const Stream<bool>.empty();

  @override
  Stream<CloudIdentity> get identityStream =>
      const Stream<CloudIdentity>.empty();

  @override
  Stream<CloudMqttMessage> get messages =>
      const Stream<CloudMqttMessage>.empty();

  @override
  Future<void> connect(CloudIdentity identity) async {}

  @override
  void subscribe(String topic) => subscribed.add(topic);

  @override
  bool publish(String topic, Map<String, dynamic> payload) {
    if (!isConnected) return false;
    published.add((topic: topic, payload: payload));
    return true;
  }

  List<String> get sentOrderNos => <String>[
    for (final p in published)
      (p.payload['order'] as Map<String, dynamic>)['orderNo'] as String,
  ];
}

/// Answers every REST order with [status], or throws [error].
class _FakeApi implements IFlowManagerApiDataSource {
  final List<({String reason, List<Map<String, dynamic>> orders})> calls =
      <({String reason, List<Map<String, dynamic>> orders})>[];
  String status = 'UPDATED';
  final List<Object> errors = <Object>[];

  @override
  Future<Map<String, dynamic>> getDeviceState(String storeId) async =>
      <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> requestUpdate(List<String> deviceIds) async =>
      <String, dynamic>{};

  @override
  Future<List<Map<String, dynamic>>> syncOrders({
    required String storeId,
    required String hubId,
    required String reason,
    required List<Map<String, dynamic>> orders,
  }) async {
    calls.add((reason: reason, orders: orders));
    if (errors.isNotEmpty) throw errors.removeAt(0);
    return <Map<String, dynamic>>[
      for (final Map<String, dynamic> o in orders)
        <String, dynamic>{
          'orderNo': (o['order'] as Map<String, dynamic>)['orderNo'],
          'version': o['version'],
          'status': status,
        },
    ];
  }

  List<String> orderNosOf(int call) => <String>[
    for (final o in calls[call].orders)
      (o['order'] as Map<String, dynamic>)['orderNo'] as String,
  ];
}

Order _order(
  String orderNo, {
  OrderStatus status = OrderStatus.pending,
  DateTime? receivedAt,
}) => Order(
  orderNo: orderNo,
  receivedAt: receivedAt ?? DateTime(2026, 11, 17, 9, 30, 15, 123),
  items: <SubItem>[SubItem(menuName: 'Latte', skuNo: 'SKU-1', status: status)],
);

OrderRecordRaw _record(
  String orderNo, {
  int? id,
  String orderedAt = '2026-11-17T09:30:15.123+09:00',
  int version = 1,
  int synced = 0,
  int rejected = 0,
  DateTime? updatedAt,
  bool live = false,
}) => OrderRecordRaw(
  id: id,
  orderNo: orderNo,
  orderJson: '{"orderNo":"$orderNo"}',
  syncJson: '{"orderNo":"$orderNo","tab":"NEW"}',
  orderedAt: orderedAt,
  version: version,
  syncedVersion: synced,
  rejectedVersion: rejected,
  updatedAt: updatedAt ?? DateTime.now(),
  live: live,
);

Future<Database> _memoryDb() => databaseFactoryFfi.openDatabase(
  inMemoryDatabasePath,
  options: OpenDatabaseOptions(
    version: 1,
    singleInstance: false,
    onCreate: (Database db, int _) => OrderLocalDataSource.createSchema(db),
  ),
);

/// Inserts rows as they are, sync columns included (saveLive never writes
/// those).
Future<void> _insert(Database db, List<OrderRecordRaw> records) async {
  for (final OrderRecordRaw r in records) {
    await db.insert('orders', r.toRow());
  }
}

void main() {
  sqfliteFfiInit();

  late Database db;
  late OrderLocalDataSource store;
  late _FakeMqtt mqtt;
  late _FakeApi api;
  late DateTime clock;
  late OrderSyncSender sender;

  setUp(() async {
    db = await _memoryDb();
    store = OrderLocalDataSource.withDatabase(
      () async => db,
      legacyDir: Directory.systemTemp.createTempSync('order_store_none'),
    );
    mqtt = _FakeMqtt();
    api = _FakeApi();
    clock = DateTime.now();
    sender = OrderSyncSender.manual(mqtt, store, api, now: () => clock);
  });

  tearDown(() => db.close());

  /// Every stored row of [orderNo], oldest first.
  Future<List<OrderRecordRaw>> rowsOf(String orderNo) async =>
      (await store.findByOrderNos(<String>[orderNo]))[orderNo] ??
      const <OrderRecordRaw>[];

  /// The only stored row of [orderNo].
  Future<OrderRecordRaw> rowOf(String orderNo) async =>
      (await rowsOf(orderNo)).single;

  group('OrderLocalDataSource', () {
    test('saveLive keeps an ack that landed after the read', () async {
      await store.saveLive(<OrderRecordRaw>[_record('A', live: true)]);
      final int id = (await rowOf('A')).id!;
      await store.markSynced('A', 1);
      await store.saveLive(<OrderRecordRaw>[_record('A', id: id, live: true)]);
      expect((await rowOf('A')).syncedVersion, 1);
    });

    test(
      'only the saved orders stay live; clearLive empties the board',
      () async {
        await store.saveLive(<OrderRecordRaw>[_record('A'), _record('B')]);
        final int b = (await rowOf('B')).id!;
        await store.saveLive(<OrderRecordRaw>[_record('B', id: b)]);
        expect(await store.loadLiveOrderJson(), <String>['{"orderNo":"B"}']);
        await store.clearLive();
        expect(await store.loadLiveOrderJson(), isEmpty);
        expect(await store.findByOrderNos(<String>['A', 'B']), hasLength(2));
      },
    );

    test('pending leaves out synced and rejected versions', () async {
      await _insert(db, <OrderRecordRaw>[
        _record('A'),
        _record('B', synced: 1),
        _record('C', rejected: 1),
        _record('D', version: 2, synced: 1),
      ]);
      final List<String> pending = (await store.pending(
        limit: 10,
      )).map((r) => r.orderNo).toList();
      expect(pending, <String>['A', 'D']);
    });

    test('deleteDoneBefore keeps live and pending orders', () async {
      final DateTime old = DateTime.now().subtract(const Duration(days: 9));
      await _insert(db, <OrderRecordRaw>[
        _record('done', synced: 1, updatedAt: old),
        _record('pending', updatedAt: old),
        _record('live', synced: 1, updatedAt: old, live: true),
      ]);
      final int deleted = await store.deleteDoneBefore(
        DateTime.now().subtract(const Duration(days: 8)),
      );
      expect(deleted, 1);
      expect(
        (await store.findByOrderNos(<String>['done', 'pending', 'live'])).keys,
        unorderedEquals(<String>['pending', 'live']),
      );
    });

    test('imports the old JSON files once, then deletes them', () async {
      final Directory dir = Directory.systemTemp.createTempSync('order_store');
      final File outbox = File('${dir.path}/order_sync_outbox.json')
        ..writeAsStringSync(
          jsonEncode(<Map<String, dynamic>>[
            <String, dynamic>{
              'orderNo': 'K1',
              'orderedAt': '2026-11-17T09:00:00.000+09:00',
              'version': 3,
              'syncedVersion': 2,
              'order': <String, dynamic>{'orderNo': 'K1', 'tab': 'BREW'},
              'updatedAt': '2026-11-18T10:00:00.000',
            },
          ]),
        );
      final File snapshot = File('${dir.path}/live_orders_snapshot.json')
        ..writeAsStringSync(
          jsonEncode(<Map<String, dynamic>>[
            <String, dynamic>{'orderNo': 'K1'},
            <String, dynamic>{'orderNo': 'K2'},
          ]),
        );
      final OrderLocalDataSource migrating = OrderLocalDataSource.withDatabase(
        () async => db,
        legacyDir: dir,
      );
      final Map<String, List<OrderRecordRaw>> rows = await migrating
          .findByOrderNos(<String>['K1', 'K2']);
      expect(rows['K1']!.single.version, 3);
      expect(rows['K1']!.single.syncedVersion, 2);
      expect(rows['K1']!.single.live, isTrue);
      expect(rows['K2']!.single.version, 0);
      expect(rows['K2']!.single.live, isTrue);
      expect(outbox.existsSync(), isFalse);
      expect(snapshot.existsSync(), isFalse);
    });

    test('an MQTT ack goes to the oldest row still waiting for it', () async {
      await _insert(db, <OrderRecordRaw>[
        _record('K1', orderedAt: '2026-11-19T10:00:00.000+09:00'),
        _record('K1', orderedAt: '2026-11-20T10:00:00.000+09:00'),
      ]);
      await store.markSynced('K1', 1);
      final List<OrderRecordRaw> once = await rowsOf('K1');
      expect(once.map((r) => r.syncedVersion), <int>[1, 0]);
      await store.markSynced('K1', 1);
      expect((await rowsOf('K1')).map((r) => r.syncedVersion), <int>[1, 1]);
    });

    test('a schema 1 table (orderNo key) is moved to schema 2', () async {
      final Database v1 = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );
      await v1.execute('''
        CREATE TABLE orders (
          order_no TEXT PRIMARY KEY, order_json TEXT NOT NULL,
          sync_json TEXT NOT NULL, ordered_at TEXT NOT NULL,
          version INTEGER NOT NULL, synced_version INTEGER NOT NULL DEFAULT 0,
          rejected_version INTEGER NOT NULL DEFAULT 0,
          updated_at INTEGER NOT NULL, live INTEGER NOT NULL DEFAULT 0)''');
      await v1.execute(
        'CREATE INDEX idx_orders_updated ON orders (updated_at, order_no)',
      );
      await v1.execute('CREATE INDEX idx_orders_live ON orders (live)');
      await v1.execute(
        'CREATE TABLE sync_state (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
      );
      await v1.insert('orders', _record('K2', version: 10, synced: 10).toRow());
      await OrderLocalDataSource.upgradeSchema(v1, 1);
      final OrderLocalDataSource upgraded = OrderLocalDataSource.withDatabase(
        () async => v1,
        legacyDir: Directory.systemTemp.createTempSync('order_store_none'),
      );
      final OrderRecordRaw row = (await upgraded.findByOrderNos(<String>[
        'K2',
      ]))['K2']!.single;
      expect(row.id, isNotNull);
      expect(row.version, 10);
      expect(row.syncedVersion, 10);
      await v1.close();
    });
  });

  group('OrderStoreRepositoryImpl', () {
    late OrderStoreRepositoryImpl repository;

    setUp(() => repository = OrderStoreRepositoryImpl(store, sender));

    test(
      'versions: new 1, unchanged same, changed +1 with the same orderedAt',
      () async {
        await repository.save(<Order>[_order('K1')]);
        final OrderRecordRaw first = await rowOf('K1');
        expect(first.version, 1);
        await repository.save(<Order>[_order('K1')]);
        expect((await rowOf('K1')).version, 1);
        await repository.save(<Order>[_order('K1', status: OrderStatus.ready)]);
        final OrderRecordRaw changed = await rowOf('K1');
        expect(changed.version, 2);
        expect(changed.orderedAt, first.orderedAt);
        expect(jsonDecode(changed.syncJson)['tab'], 'CALL');
      },
    );

    test('an order migrated without sync state gets version 1', () async {
      await _insert(db, <OrderRecordRaw>[
        OrderRecordRaw(
          orderNo: 'K1',
          orderJson: '{}',
          syncJson: '',
          orderedAt: '',
          version: 0,
          syncedVersion: 0,
          rejectedVersion: 0,
          updatedAt: DateTime.now(),
          live: true,
        ),
      ]);
      await repository.save(<Order>[_order('K1')]);
      expect((await rowOf('K1')).version, 1);
    });

    test('the same orderNo on another day is a new order', () async {
      final DateTime yesterday = DateTime(2026, 11, 19, 17, 53, 9, 950);
      final DateTime today = DateTime(2026, 11, 20, 10, 5, 23, 613);
      await repository.save(<Order>[_order('K2', receivedAt: yesterday)]);
      await repository.save(<Order>[
        _order('K2', receivedAt: yesterday, status: OrderStatus.ready),
      ]);
      await repository.clearLive();
      await repository.save(<Order>[_order('K2', receivedAt: today)]);
      final List<OrderRecordRaw> rows = await rowsOf('K2');
      expect(rows, hasLength(2));
      expect(rows[0].version, 2);
      expect(rows[0].live, isFalse);
      expect(rows[0].orderedAt, CloudFormat.timestamp(yesterday));
      expect(rows[1].version, 1);
      expect(rows[1].live, isTrue);
      expect(rows[1].orderedAt, CloudFormat.timestamp(today));
      expect(
        jsonDecode(rows[1].syncJson)['orderedAt'],
        CloudFormat.timestamp(today),
      );
    });

    test('a merged row on the board is left for a new row of today', () async {
      await _insert(db, <OrderRecordRaw>[
        _record(
          'K2',
          version: 10,
          synced: 10,
          live: true,
          orderedAt: '2026-11-19T17:53:09.950+09:00',
        ),
      ]);
      await repository.save(<Order>[
        _order('K2', receivedAt: DateTime(2026, 11, 20, 10, 5, 23, 613)),
      ]);
      final List<OrderRecordRaw> rows = await rowsOf('K2');
      expect(rows.map((r) => r.version), <int>[10, 1]);
      expect(rows.map((r) => r.live), <bool>[false, true]);
    });

    test(
      'loadLive restores the saved orders; clearLive empties them',
      () async {
        await repository.save(<Order>[_order('K1'), _order('K2')]);
        expect(
          (await repository.loadLive()).map((Order o) => o.orderNo),
          <String>['K1', 'K2'],
        );
        await repository.clearLive();
        expect(await repository.loadLive(), isEmpty);
      },
    );

    test('a progress-only change keeps the version and snapshot', () async {
      Order withProgress(double p) => Order(
        orderNo: 'K1',
        items: <SubItem>[
          SubItem(menuName: 'Latte', isExtracting: true, progress: p),
        ],
      );
      await repository.save(<Order>[withProgress(0.2)]);
      await repository.save(<Order>[withProgress(0.7)]);
      final OrderRecordRaw row = await rowOf('K1');
      expect(row.version, 1);
      expect(jsonDecode(row.syncJson)['progress'], 0.2);
    });
  });

  group('OrderSyncMapper', () {
    Map<String, dynamic> sync(Order order) =>
        order.toSyncOrder(orderedAt: '2026-11-19T09:00:00.000+09:00');

    test('displayNo: the POS number, else orderNo without its letters', () {
      expect(sync(_order('K1001'))['displayNo'], '1001');
      expect(
        sync(_order('smaregi-1').copyWith(displayNo: '0045'))['displayNo'],
        '0045',
      );
    });

    test('channel: as received, KIOSK when none', () {
      expect(sync(_order('K1'))['channel'], 'KIOSK');
      expect(
        sync(_order('K1').copyWith(channel: 'SMAREGI'))['channel'],
        'SMAREGI',
      );
    });

    test('totalCups counts drinks only', () {
      final Order order = Order(
        orderNo: 'K1',
        items: <SubItem>[
          const SubItem(menuName: 'Latte'),
          const SubItem(menuName: 'Cookie', itemType: 'FOOD'),
        ],
      );
      expect(sync(order)['totalCups'], 1);
    });

    test('item status and productionStage follow the sheet', () {
      final Order order = Order(
        orderNo: 'K1',
        items: <SubItem>[
          const SubItem(menuName: 'A', size: 'md', temp: 'iced'),
          const SubItem(menuName: 'B', isExtracting: true),
          const SubItem(menuName: 'C', status: OrderStatus.ready),
          const SubItem(menuName: 'D', status: OrderStatus.pickedUp),
          const SubItem(menuName: 'E', itemType: 'FOOD'),
        ],
      );
      final List<Map<String, dynamic>> items = (sync(order)['items'] as List)
          .cast<Map<String, dynamic>>();
      expect(items.map((i) => i['status']), <String>[
        'NEW',
        'BREW',
        'CALL',
        'DONE',
        'KITCHEN',
      ]);
      expect(items.map((i) => i['productionStage']), <String>[
        'PREPARING',
        'PREPARING',
        'READY',
        'DONE',
        'PREPARING',
      ]);
      expect(items.first['size'], 'MD');
      expect(items.first['temp'], 'ICED');
    });

    test('brew times: per cup, and the order takes the first start', () {
      final DateTime first = DateTime(2026, 11, 19, 9, 1);
      final Order order = Order(
        orderNo: 'K1',
        items: <SubItem>[
          SubItem(
            menuName: 'A',
            brewStartedAt: first.add(const Duration(minutes: 1)),
            brewStartedBy: 'flowhub-leader',
            brewCompletedAt: first.add(const Duration(minutes: 3)),
            brewCompletedBy: 'flow-qr-reader-call',
          ),
          SubItem(menuName: 'B', brewStartedAt: first),
        ],
      );
      final Map<String, dynamic> json = sync(order);
      expect(json['brewStartedAt'], CloudFormat.timestamp(first));
      final Map<String, dynamic> item =
          (json['items'] as List).first as Map<String, dynamic>;
      expect(item['brewStartedBy'], 'flowhub-leader');
      expect(item['brewCompletedBy'], 'flow-qr-reader-call');
      expect(
        item['brewCompletedAt'],
        CloudFormat.timestamp(first.add(const Duration(minutes: 3))),
      );
    });

    test('pickedUpBy is sent once the order is DONE', () {
      final Order done = _order(
        'K1',
        status: OrderStatus.pickedUp,
      ).copyWith(pickedUpBy: 'flow-pickup-table');
      expect(sync(done)['pickedUpBy'], 'flow-pickup-table');
      expect(sync(_order('K1'))['pickedUpBy'], isNull);
    });
  });

  group('OrderSyncSender', () {
    Future<void> advance(int seconds) async {
      clock = clock.add(Duration(seconds: seconds));
      await sender.tick();
    }

    void ack(String orderNo, int version, String status, [String error = '']) =>
        sender.handleMessage((
          topic: 'flow/hub/S1/H1/order-ack',
          json: <String, dynamic>{
            'orderNo': orderNo,
            'version': version,
            'status': status,
            'error': error,
          },
        ));

    test('sends a new version as the MQTT order message', () async {
      await _insert(db, <OrderRecordRaw>[_record('K1', version: 3)]);
      await sender.tick();
      expect(mqtt.published, hasLength(1));
      final Map<String, dynamic> message = mqtt.published.single.payload;
      expect(mqtt.published.single.topic, 'flow/hub/S1/H1/orders');
      expect(message['schemaVersion'], 4);
      expect(message['storeId'], 'S1');
      expect(message['hubId'], 'H1');
      expect(message['version'], 3);
      expect(message['eventType'], 'ORDER_UPDATED');
      expect((message['order'] as Map<String, dynamic>)['orderNo'], 'K1');
    });

    test('resends after 10, 20 and 40 s, then moves to REST (R3)', () async {
      await _insert(db, <OrderRecordRaw>[_record('K1')]);
      await sender.tick();
      await advance(9);
      expect(mqtt.published, hasLength(1));
      await advance(1);
      expect(mqtt.published, hasLength(2));
      await advance(20);
      expect(mqtt.published, hasLength(3));
      await advance(40);
      expect(mqtt.published, hasLength(4));
      expect(api.calls, isEmpty);
      await advance(40);
      expect(mqtt.published, hasLength(4));
      expect(api.calls.single.reason, 'FALLBACK');
      expect((await store.pending(limit: 10)), isEmpty);
    });

    test('an UPDATED ack stops the resends', () async {
      await _insert(db, <OrderRecordRaw>[_record('K1')]);
      await sender.tick();
      ack('K1', 1, 'UPDATED');
      await Future<void>.delayed(Duration.zero);
      await advance(10);
      expect(mqtt.published, hasLength(1));
      expect((await store.pending(limit: 10)), isEmpty);
    });

    test('a REJECTED ack stops that version and is announced', () async {
      final List<OrderSyncRejection> rejections = <OrderSyncRejection>[];
      sender.rejections.listen(rejections.add);
      await _insert(db, <OrderRecordRaw>[_record('K1')]);
      await sender.tick();
      ack('K1', 1, 'REJECTED', 'MISSING_FIELD');
      await Future<void>.delayed(Duration.zero);
      await advance(10);
      expect(mqtt.published, hasLength(1));
      expect(rejections.single.orderNo, 'K1');
      expect(rejections.single.error, 'MISSING_FIELD');
      expect((await rowOf('K1')).rejectedVersion, 1);
    });

    test('MQTT down for 60 s sends over REST (R4)', () async {
      await _insert(db, <OrderRecordRaw>[_record('K1')]);
      mqtt.isConnected = false;
      sender.handleConnection(false);
      await advance(59);
      expect(api.calls, isEmpty);
      await advance(1);
      expect(api.calls.single.reason, 'FALLBACK');
      expect(mqtt.published, isEmpty);
    });

    test('past 100 pending, the oldest go over REST (R5)', () async {
      final DateTime start = DateTime.now().subtract(const Duration(hours: 1));
      await _insert(db, <OrderRecordRaw>[
        for (int i = 0; i < 102; i++)
          _record(
            'K${i.toString().padLeft(3, '0')}',
            updatedAt: start.add(Duration(seconds: i)),
          ),
      ]);
      await sender.tick();
      expect(api.calls.single.reason, 'BACKLOG');
      expect(api.orderNosOf(0), <String>['K000', 'K001']);
      expect(mqtt.published, hasLength(100));
      expect(mqtt.sentOrderNos.first, 'K002');
    });

    test('a HELD result keeps the order pending', () async {
      api.status = 'HELD';
      await _insert(db, <OrderRecordRaw>[_record('K1')]);
      mqtt.isConnected = false;
      sender.handleConnection(false);
      await advance(60);
      expect(api.calls, hasLength(1));
      expect((await store.pending(limit: 10)), hasLength(1));
      await advance(2);
      expect(api.calls, hasLength(1), reason: 'no REST resend within 30 s');
      await advance(30);
      expect(api.calls, hasLength(2));
    });

    test('the sweep resends recent orders, acked ones included', () async {
      final DateTime now = DateTime.now();
      await _insert(db, <OrderRecordRaw>[
        _record(
          'old',
          synced: 1,
          updatedAt: now.subtract(const Duration(days: 8)),
        ),
        _record(
          'acked',
          synced: 1,
          updatedAt: now.subtract(const Duration(days: 2)),
        ),
        _record('pending', updatedAt: now.subtract(const Duration(hours: 1))),
        _record(
          'rejected',
          rejected: 1,
          updatedAt: now.subtract(const Duration(hours: 1)),
        ),
      ]);
      await sender.sweep();
      expect(api.calls.single.reason, 'HOURLY_SWEEP');
      expect(api.orderNosOf(0), <String>['acked', 'pending']);
      expect(await store.readState('last_swept_at'), isNotNull);
    });

    test('the next sweep starts 10 min before the last one', () async {
      final DateTime now = DateTime.now();
      await store.writeState(
        'last_swept_at',
        now.subtract(const Duration(hours: 1)).toIso8601String(),
      );
      await _insert(db, <OrderRecordRaw>[
        _record('before', updatedAt: now.subtract(const Duration(minutes: 71))),
        _record(
          'overlap',
          updatedAt: now.subtract(const Duration(minutes: 69)),
        ),
      ]);
      await sender.sweep();
      expect(api.orderNosOf(0), <String>['overlap']);
    });

    test('the sweep retries a 503 and keeps last_swept_at on a 400', () async {
      await _insert(db, <OrderRecordRaw>[_record('K1')]);
      api.errors.add(const BaseException.serverException(statusCode: 503));
      await sender.sweep();
      expect(api.calls, hasLength(2));
      expect(await store.readState('last_swept_at'), isNotNull);

      await store.writeState('last_swept_at', 'kept');
      api.errors.add(const BaseException.serverException(statusCode: 400));
      await sender.sweep();
      expect(api.calls, hasLength(3));
      expect(await store.readState('last_swept_at'), 'kept');
    });
  });

  test('CloudFormat.timestamp has 3 ms digits and the UTC offset', () {
    expect(
      CloudFormat.timestamp(DateTime(2026, 8, 28, 8, 17, 36, 118)),
      matches(RegExp(r'^2026-08-28T08:17:36\.118[+-]\d{2}:\d{2}$')),
    );
  });
}
