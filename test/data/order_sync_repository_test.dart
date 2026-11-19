import 'dart:async';

import 'package:flowhub/core/utils/cloud_format.dart';
import 'package:flowhub/data/models/order_sync/order_sync_entry_raw.dart';
import 'package:flowhub/data/repositories/order_sync_repository_impl.dart';
import 'package:flowhub/data/sources/local/order_sync_outbox_data_source.dart';
import 'package:flowhub/data/sources/remote/cloud_mqtt_data_source.dart';
import 'package:flowhub/domain/entities/cloud/cloud_identity.dart';
import 'package:flowhub/domain/entities/order/order.dart';
import 'package:flowhub/domain/entities/sub_item/sub_item.dart';
import 'package:flowhub/domain/enums/order_status.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeMqtt implements ICloudMqttDataSource {
  final StreamController<bool> connection = StreamController<bool>.broadcast();
  final StreamController<CloudMqttMessage> incoming =
      StreamController<CloudMqttMessage>.broadcast();
  final StreamController<CloudIdentity> identities =
      StreamController<CloudIdentity>.broadcast();
  final List<({String topic, Map<String, dynamic> payload})> published =
      <({String topic, Map<String, dynamic> payload})>[];
  final Set<String> subscribed = <String>{};

  @override
  CloudIdentity? identity = const CloudIdentity(storeId: 'S1', hubId: 'H1');

  @override
  bool isConnected = true;

  @override
  Stream<bool> get connectionStream => connection.stream;

  @override
  Stream<CloudIdentity> get identityStream => identities.stream;

  @override
  Stream<CloudMqttMessage> get messages => incoming.stream;

  @override
  Future<void> connect(CloudIdentity identity) async {}

  @override
  void subscribe(String topic) => subscribed.add(topic);

  @override
  bool publish(String topic, Map<String, dynamic> payload) {
    if (!isConnected) {
      return false;
    }
    published.add((topic: topic, payload: payload));
    return true;
  }
}

class _MemoryOutbox implements IOrderSyncOutboxDataSource {
  Map<String, OrderSyncEntryRaw> stored = <String, OrderSyncEntryRaw>{};

  @override
  Future<Map<String, OrderSyncEntryRaw>> load() async =>
      Map<String, OrderSyncEntryRaw>.of(stored);

  @override
  Future<void> save(Map<String, OrderSyncEntryRaw> entries) async =>
      stored = Map<String, OrderSyncEntryRaw>.of(entries);
}

Order _order({OrderStatus status = OrderStatus.pending}) => Order(
  orderNo: 'K1001',
  receivedAt: DateTime(2026, 11, 17, 9, 30, 15, 123),
  items: <SubItem>[
    SubItem(menuName: 'Latte', skuNo: 'SKU-1', status: status),
  ],
);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('CloudFormat.timestamp', () {
    test('has 3 ms digits and the UTC offset', () {
      final String value = CloudFormat.timestamp(
        DateTime(2026, 8, 28, 8, 17, 36, 118),
      );
      expect(
        value,
        matches(RegExp(r'^2026-08-28T08:17:36\.118[+-]\d{2}:\d{2}$')),
      );
    });
  });

  group('OrderSyncRepositoryImpl', () {
    late _FakeMqtt mqtt;
    late _MemoryOutbox outbox;
    late OrderSyncRepositoryImpl repository;

    setUp(() {
      mqtt = _FakeMqtt();
      outbox = _MemoryOutbox();
      repository = OrderSyncRepositoryImpl(mqtt, outbox);
    });

    test('subscribes the order-ack topic of the current identity', () {
      expect(mqtt.subscribed, contains('flow/hub/S1/H1/order-ack'));
    });

    test('publishes a new order as version 1', () async {
      await repository.record(<Order>[_order()]);
      await _settle();
      expect(mqtt.published, hasLength(1));
      final Map<String, dynamic> payload = mqtt.published.single.payload;
      expect(mqtt.published.single.topic, 'flow/hub/S1/H1/orders');
      expect(payload['version'], 1);
      expect(payload['storeId'], 'S1');
      expect(payload['hubId'], 'H1');
      expect((payload['order'] as Map<String, dynamic>)['tab'], 'NEW');
      expect(outbox.stored['K1001']!.version, 1);
    });

    test('an unchanged order keeps its version', () async {
      await repository.record(<Order>[_order()]);
      await repository.record(<Order>[_order()]);
      expect(outbox.stored['K1001']!.version, 1);
    });

    test('a changed order gets version 2 with the same orderedAt', () async {
      await repository.record(<Order>[_order()]);
      final String orderedAt = outbox.stored['K1001']!.orderedAt;
      await repository.record(<Order>[_order(status: OrderStatus.ready)]);
      await _settle();
      final OrderSyncEntryRaw entry = outbox.stored['K1001']!;
      expect(entry.version, 2);
      expect(entry.orderedAt, orderedAt);
      expect(entry.order['tab'], 'CALL');
      expect(mqtt.published.last.payload['version'], 2);
    });

    test('an UPDATED ack marks the version synced', () async {
      await repository.record(<Order>[_order()]);
      mqtt.incoming.add((
        topic: 'flow/hub/S1/H1/order-ack',
        json: <String, dynamic>{
          'orderNo': 'K1001',
          'version': 1,
          'status': 'UPDATED',
        },
      ));
      await _settle();
      await repository.record(const <Order>[]);
      expect(outbox.stored['K1001']!.syncedVersion, 1);
      expect(outbox.stored['K1001']!.isPending, isFalse);
    });

    test('keeps the version pending while offline', () async {
      mqtt.isConnected = false;
      await repository.record(<Order>[_order()]);
      await _settle();
      expect(mqtt.published, isEmpty);
      expect(outbox.stored['K1001']!.isPending, isTrue);
    });
  });
}
