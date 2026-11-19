import 'package:flowhub/data/mappers/pos_order_parser.dart';
import 'package:flowhub/domain/entities/cloud/cloud_identity.dart';
import 'package:flowhub/domain/entities/device/device.dart';
import 'package:flowhub/domain/entities/order/order.dart';
import 'package:flowhub/domain/entities/pos_order/pos_order_ack.dart';
import 'package:flowhub/domain/entities/pos_order/pos_order_message.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/cloud_repository.dart';
import 'package:flowhub/domain/repositories/pos_order_repository.dart';
import 'package:flowhub/domain/usecases/pos_order/decide_pos_order_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide Order;

class _FakeCloud implements CloudRepository {
  @override
  CloudIdentity? identity = const CloudIdentity(storeId: 'STORE-001', hubId: 'YFTC_1');

  @override
  Stream<bool> get connectionStream => const Stream<bool>.empty();

  @override
  bool get isConnected => true;

  @override
  Future<CloudIdentity?> start(Device device) async => identity;
}

class _FakePosOrders implements PosOrderRepository {
  final Set<String> tombstones = <String>{};

  @override
  Stream<PosOrderMessage> get messages => const Stream<PosOrderMessage>.empty();

  @override
  Future<bool> ack(PosOrderMessage message, PosOrderAck ack) async => true;

  @override
  Future<void> addTombstone(String orderNo, DateTime cancelledAt) async =>
      tombstones.add(orderNo);

  @override
  Future<bool> hasTombstone(String orderNo) async => tombstones.contains(orderNo);
}

Map<String, dynamic> _newJson({
  String storeId = 'STORE-001',
  int schemaVersion = 1,
  Duration expiresIn = const Duration(minutes: 10),
  String displayNo = '0045',
  Map<String, dynamic>? item,
}) => <String, dynamic>{
  'schemaVersion': schemaVersion,
  'messageId': 'pos-1842-NEW',
  'messageType': 'NEW',
  'attempt': 1,
  'storeId': storeId,
  'hubId': 'YFTC_1',
  'sentAt': '2026-12-15T08:17:38.204+09:00',
  'expiresAt': DateTime.now().add(expiresIn).toIso8601String(),
  'order': <String, dynamic>{
    'orderNo': 'smaregi-100045',
    'displayNo': displayNo,
    'channel': 'SMAREGI',
    'orderTime': '2026-12-15T08:17:36.000+09:00',
    'totalCups': 1,
    'totalAmount': 500,
    'currency': 'JPY',
    'items': <Map<String, dynamic>>[
      item ??
          <String, dynamic>{
            'seq': 1,
            'skuNo': 'BVSG0001',
            'menuName': 'アイスアメリカーノ M',
            'temp': 'ICED',
            'options': <Map<String, dynamic>>[
              <String, dynamic>{'optionNo': 'OP.11', 'name': 'shot', 'quantity': 1},
              <String, dynamic>{'optionNo': 'UNMAPPED', 'name': '?', 'quantity': 1},
            ],
            'amount': 500,
            'manual': false,
          },
    ],
  },
};

Map<String, dynamic> _cancelJson() => <String, dynamic>{
  'schemaVersion': 1,
  'messageId': 'pos-1842-CANCEL',
  'messageType': 'CANCEL',
  'storeId': 'STORE-001',
  'hubId': 'YFTC_1',
  'order': <String, dynamic>{
    'orderNo': 'smaregi-100045',
    'cancelledAt': '2026-12-15T08:20:00.000+09:00',
    'cancelledBy': 'smaregi',
  },
};

void main() {
  group('PosOrderParser', () {
    test('reads a NEW order and drops UNMAPPED options', () {
      final PosOrderMessage m = PosOrderParser.parse(_newJson());
      expect(m.error, isNull);
      expect(m.type, PosOrderMessageType.newOrder);
      expect(m.order!.displayNo, '0045');
      expect(m.order!.channel, 'SMAREGI');
      expect(m.order!.totalAmount, 500);
      expect(m.order!.items.single.selectedOptions.single.optionNo, 'OP.11');
      expect(m.order!.items.single.manual, isFalse);
    });

    test('an UNMAPPED SKU becomes a manual cup', () {
      final PosOrderMessage m = PosOrderParser.parse(_newJson(
        item: <String, dynamic>{'seq': 1, 'skuNo': 'UNMAPPED', 'menuName': 'X'},
      ));
      expect(m.order!.items.single.manual, isTrue);
      expect(m.order!.items.single.skuNo, isEmpty);
    });

    test('a displayNo without a digit is MISSING_FIELD', () {
      expect(
        PosOrderParser.parse(_newJson(displayNo: 'abc')).error,
        PosOrderAckError.missingField,
      );
    });

    test('a too-long displayNo is FIELD_TOO_LONG', () {
      expect(
        PosOrderParser.parse(_newJson(displayNo: '1' * 21)).error,
        PosOrderAckError.fieldTooLong,
      );
    });

    test('a bad expiresAt is INVALID_TIMESTAMP', () {
      final Map<String, dynamic> json = _newJson()..['expiresAt'] = 'soon';
      expect(PosOrderParser.parse(json).error, PosOrderAckError.invalidTimestamp);
    });
  });

  group('DecidePosOrderUseCase', () {
    late _FakePosOrders posOrders;
    late DecidePosOrderUseCase decide;

    setUp(() {
      posOrders = _FakePosOrders();
      decide = DecidePosOrderUseCase(_FakeCloud(), posOrders);
    });

    Future<PosOrderDecision> run(Map<String, dynamic> json, {Order? existing}) async {
      final Either<BaseException, PosOrderDecision> r = await decide((
        message: PosOrderParser.parse(json),
        existing: existing,
      ));
      return r.getOrElse((BaseException e) => throw e);
    }

    String? statusOf(PosOrderDecision d) =>
        d is PosOrderAnswer ? d.ack.status : null;

    test('a new valid order is created', () async {
      expect(await run(_newJson()), isA<PosOrderCreate>());
    });

    test('a newer schema is REJECTED', () async {
      final PosOrderDecision d = await run(_newJson(schemaVersion: 2));
      expect(statusOf(d), PosOrderAckStatus.rejected);
      expect((d as PosOrderAnswer).ack.error, PosOrderAckError.unsupportedSchemaVersion);
    });

    test('another store is STORE_MISMATCH', () async {
      final PosOrderDecision d = await run(_newJson(storeId: 'STORE-002'));
      expect((d as PosOrderAnswer).ack.error, PosOrderAckError.storeMismatch);
    });

    test('an existing order is DUPLICATE with its orderedAt', () async {
      final DateTime receivedAt = DateTime(2026, 12, 15, 8, 17, 38);
      final PosOrderDecision d = await run(
        _newJson(),
        existing: Order(orderNo: 'smaregi-100045', receivedAt: receivedAt),
      );
      expect(statusOf(d), PosOrderAckStatus.duplicate);
      expect((d as PosOrderAnswer).ack.orderedAt, receivedAt);
    });

    test('a tombstoned order is ALREADY_CANCELLED', () async {
      posOrders.tombstones.add('smaregi-100045');
      expect(statusOf(await run(_newJson())), PosOrderAckStatus.alreadyCancelled);
    });

    test('an order past expiresAt is EXPIRED', () async {
      final PosOrderDecision d = await run(
        _newJson(expiresIn: const Duration(minutes: -1)),
      );
      expect(statusOf(d), PosOrderAckStatus.expired);
    });

    test('CANCEL of a live order cancels it', () async {
      final PosOrderDecision d = await run(
        _cancelJson(),
        existing: const Order(orderNo: 'smaregi-100045'),
      );
      expect(d, isA<PosOrderCancel>());
    });

    test('CANCEL of a cancelled order is ALREADY_CANCELLED', () async {
      final PosOrderDecision d = await run(
        _cancelJson(),
        existing: Order(orderNo: 'smaregi-100045', cancelledAt: DateTime.now()),
      );
      expect(statusOf(d), PosOrderAckStatus.alreadyCancelled);
    });

    test('CANCEL before NEW stores a tombstone', () async {
      expect(await run(_cancelJson()), isA<PosOrderTombstone>());
    });
  });
}
