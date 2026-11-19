import 'dart:async';

import 'package:flowhub/core/utils/cloud_format.dart';
import 'package:flowhub/core/utils/log.dart';
import 'package:flowhub/data/mappers/pos_order_parser.dart';
import 'package:flowhub/data/sources/local/pos_order_tombstone_data_source.dart';
import 'package:flowhub/data/sources/remote/cloud_mqtt_data_source.dart';
import 'package:flowhub/domain/entities/cloud/cloud_identity.dart';
import 'package:flowhub/domain/entities/pos_order/pos_order_ack.dart';
import 'package:flowhub/domain/entities/pos_order/pos_order_message.dart';
import 'package:flowhub/domain/repositories/pos_order_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: PosOrderRepository)
class PosOrderRepositoryImpl implements PosOrderRepository {
  /// Lives as long as the app (lazy singleton): the identity listener is
  /// never cancelled. Subscribes `pos-order` for the current and every
  /// later cloud identity.
  PosOrderRepositoryImpl(this._mqtt, this._tombstones) {
    _mqtt.identityStream.listen(_subscribe);
    final CloudIdentity? identity = _mqtt.identity;
    if (identity != null) {
      _subscribe(identity);
    }
  }

  static const String _tag = 'PosOrder';
  static const int _schemaVersion = 1;

  /// Tombstones are kept at least 7 days; one extra day of margin.
  static const Duration _keepTombstones = Duration(days: 8);

  final ICloudMqttDataSource _mqtt;
  final IPosOrderTombstoneDataSource _tombstones;
  Future<Map<String, DateTime>>? _tombstoneCache;

  String _orderTopic(CloudIdentity identity) =>
      '${identity.hubTopicPrefix}/pos-order';

  String _ackTopic(CloudIdentity identity) =>
      '${identity.hubTopicPrefix}/pos-order-ack';

  void _subscribe(CloudIdentity identity) =>
      _mqtt.subscribe(_orderTopic(identity));

  @override
  Stream<PosOrderMessage> get messages => _mqtt.messages
      .where((CloudMqttMessage m) {
        final CloudIdentity? identity = _mqtt.identity;
        return identity != null && m.topic == _orderTopic(identity);
      })
      .map((CloudMqttMessage m) {
        final PosOrderMessage message = PosOrderParser.parse(m.json);
        Log.i(
          _tag,
          'pos-order ${message.type.name} ${message.orderNo} '
          '(${message.messageId}, attempt ${m.json['attempt']})'
          '${message.error == null ? '' : ' error=${message.error}'}',
        );
        return message;
      });

  /// Copies messageId, messageType, orderNo, storeId and hubId from the
  /// message, as the cloud matches the ack against them.
  @override
  Future<bool> ack(PosOrderMessage message, PosOrderAck ack) async {
    final CloudIdentity? identity = _mqtt.identity;
    if (identity == null) {
      return false;
    }
    final Map<String, dynamic> raw = message.raw;
    final bool sent = _mqtt.publish(_ackTopic(identity), <String, dynamic>{
      'schemaVersion': _schemaVersion,
      'messageId': raw['messageId'],
      'messageType': raw['messageType'],
      'orderNo': message.orderNo,
      'storeId': raw['storeId'],
      'hubId': raw['hubId'],
      'status': ack.status,
      'orderedAt': CloudFormat.timestampOrNull(ack.orderedAt),
      'stage': ack.stage,
      'error': ack.error,
    });
    Log.i(_tag, 'ack ${message.orderNo} $ack${sent ? '' : ' (not connected)'}');
    return sent;
  }

  Future<Map<String, DateTime>> get _cache =>
      _tombstoneCache ??= _tombstones.load().then((Map<String, DateTime> all) {
        final DateTime cutoff = DateTime.now().subtract(_keepTombstones);
        all.removeWhere((_, DateTime at) => at.isBefore(cutoff));
        return all;
      });

  @override
  Future<bool> hasTombstone(String orderNo) async =>
      (await _cache).containsKey(orderNo);

  /// Stores the tombstone, keyed by when it was stored (so it is kept 7 days
  /// from now, whatever [cancelledAt] says).
  @override
  Future<void> addTombstone(String orderNo, DateTime cancelledAt) async {
    final Map<String, DateTime> all = await _cache;
    all[orderNo] = DateTime.now();
    await _tombstones.save(all);
    Log.i(_tag, 'Tombstone stored for $orderNo (cancelled $cancelledAt)');
  }
}
