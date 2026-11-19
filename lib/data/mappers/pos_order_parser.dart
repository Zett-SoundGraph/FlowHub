import 'package:flowhub/domain/entities/order/order.dart';
import 'package:flowhub/domain/entities/pos_order/pos_order_ack.dart';
import 'package:flowhub/domain/entities/pos_order/pos_order_message.dart';
import 'package:flowhub/domain/entities/selected_option/selected_option.dart';
import 'package:flowhub/domain/entities/sub_item/sub_item.dart';

/// Reads one `pos-order` payload into a [PosOrderMessage].
///
/// Field problems don't throw: they become [PosOrderMessage.error]
/// (MISSING_FIELD, FIELD_TOO_LONG, INVALID_TIMESTAMP), which the Hub answers
/// with REJECTED. Reject only what is truly unreadable: a rejected CANCEL is
/// resent for 24 h.
class PosOrderParser {
  PosOrderParser._();

  /// SKU / option code Flow Cloud sends when the POS item has no Flow mapping.
  static const String unmapped = 'UNMAPPED';

  static const int _maxOrderNo = 64;
  static const int _maxDisplayNo = 20;
  static const int _maxChannel = 10;
  static const int _maxSku = 64;
  static const int _maxMenuName = 255;

  /// 1. Envelope: schemaVersion, messageId, messageType, storeId, hubId.
  /// 2. order.orderNo (both types).
  /// 3. NEW: expiresAt, displayNo, items and the order to create.
  ///    CANCEL: cancelledAt / cancelledBy, from `order` or the top level.
  static PosOrderMessage parse(Map<String, dynamic> json) {
    final Map<String, dynamic> order =
        json['order'] is Map<String, dynamic>
            ? json['order'] as Map<String, dynamic>
            : <String, dynamic>{};
    final String type = _str(json['messageType']).toUpperCase();
    final PosOrderMessageType messageType = switch (type) {
      'NEW' => PosOrderMessageType.newOrder,
      'CANCEL' => PosOrderMessageType.cancel,
      _ => PosOrderMessageType.unknown,
    };
    final String orderNo = _str(order['orderNo']).isNotEmpty
        ? _str(order['orderNo'])
        : _str(json['orderNo']);

    String? error;
    void fail(String code) => error ??= code;

    if (_str(json['messageId']).isEmpty ||
        _str(json['storeId']).isEmpty ||
        _str(json['hubId']).isEmpty ||
        orderNo.isEmpty) {
      fail(PosOrderAckError.missingField);
    }
    if (orderNo.length > _maxOrderNo) {
      fail(PosOrderAckError.fieldTooLong);
    }

    DateTime? expiresAt;
    Order? newOrder;
    DateTime? cancelledAt;
    String? cancelledBy;
    if (messageType == PosOrderMessageType.newOrder) {
      expiresAt = _time(json['expiresAt'], fail, required: true);
      _time(order['orderTime'], fail);
      newOrder = _order(order, orderNo, fail);
    } else if (messageType == PosOrderMessageType.cancel) {
      cancelledAt = _time(order['cancelledAt'] ?? json['cancelledAt'], fail);
      final String by = _str(order['cancelledBy'] ?? json['cancelledBy']);
      cancelledBy = by.isEmpty ? null : by;
    }

    return PosOrderMessage(
      raw: json,
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
      messageId: _str(json['messageId']),
      type: messageType,
      storeId: _str(json['storeId']),
      hubId: _str(json['hubId']),
      orderNo: orderNo,
      expiresAt: expiresAt,
      order: error == null ? newOrder : null,
      cancelledAt: cancelledAt,
      cancelledBy: cancelledBy,
      error: error,
    );
  }

  /// The order to create, or `null` with [fail] called when unreadable.
  /// receivedAt / stateEnteredAt are left for the Hub to set on commit.
  static Order? _order(
    Map<String, dynamic> json,
    String orderNo,
    void Function(String) fail,
  ) {
    final String displayNo = _str(json['displayNo']);
    final String channel = _str(json['channel']);
    if (displayNo.isEmpty || !displayNo.contains(RegExp(r'\d'))) {
      fail(PosOrderAckError.missingField);
    }
    if (displayNo.length > _maxDisplayNo || channel.length > _maxChannel) {
      fail(PosOrderAckError.fieldTooLong);
    }
    final Object? rawItems = json['items'];
    if (rawItems is! List || rawItems.isEmpty) {
      fail(PosOrderAckError.missingField);
      return null;
    }
    final List<SubItem> items = <SubItem>[];
    for (final Object? raw in rawItems) {
      if (raw is! Map<String, dynamic>) {
        fail(PosOrderAckError.missingField);
        return null;
      }
      final SubItem? item = _item(raw, fail);
      if (item == null) {
        return null;
      }
      items.add(item);
    }
    final int foodCount =
        items.where((SubItem i) => i.itemType == 'FOOD').length;
    return Order(
      orderNo: orderNo,
      rawOrderId: orderNo,
      displayNo: displayNo,
      channel: channel,
      language: _str(json['language']),
      totalAmount: (json['totalAmount'] as num?)?.toInt(),
      currency: _nullable(json['currency']),
      paymentStatus: _nullable(json['paymentStatus']),
      items: items,
      drinkCount: items.length - foodCount,
      foodCount: foodCount,
    );
  }

  /// One cup. An UNMAPPED SKU has no recipe, so it is made by hand like a
  /// `manual` item; UNMAPPED options are dropped.
  static SubItem? _item(Map<String, dynamic> json, void Function(String) fail) {
    final String skuNo = _str(json['skuNo']);
    final String menuName = _str(json['menuName']);
    if (skuNo.isEmpty || menuName.isEmpty) {
      fail(PosOrderAckError.missingField);
      return null;
    }
    if (skuNo.length > _maxSku || menuName.length > _maxMenuName) {
      fail(PosOrderAckError.fieldTooLong);
      return null;
    }
    final bool isUnmapped = skuNo == unmapped;
    final List<SelectedOption> options = <SelectedOption>[
      for (final Object? option in (json['options'] as List<Object?>?) ?? <Object?>[])
        if (option is Map<String, dynamic> &&
            _str(option['optionNo']).isNotEmpty &&
            _str(option['optionNo']) != unmapped)
          SelectedOption(
            optionNo: _str(option['optionNo']),
            quantity: (option['quantity'] as num?)?.toInt() ?? 1,
          ),
    ];
    return SubItem.initial(menuName).copyWith(
      skuNo: isUnmapped ? '' : skuNo,
      temp: _str(json['temp']),
      size: _str(json['size']),
      selectedOptions: options,
      manual: json['manual'] == true || isUnmapped,
      itemType: _nullable(json['itemType']),
      amount: (json['amount'] as num?)?.toInt(),
    );
  }

  /// Parses an ISO 8601 time with offset. Missing → [required] decides;
  /// present but unreadable → INVALID_TIMESTAMP.
  static DateTime? _time(
    Object? value,
    void Function(String) fail, {
    bool required = false,
  }) {
    final String text = _str(value);
    if (text.isEmpty) {
      if (required) {
        fail(PosOrderAckError.missingField);
      }
      return null;
    }
    final DateTime? time = DateTime.tryParse(text);
    if (time == null) {
      fail(PosOrderAckError.invalidTimestamp);
    }
    return time;
  }

  static String _str(Object? value) => value?.toString() ?? '';

  static String? _nullable(Object? value) {
    final String text = _str(value);
    return text.isEmpty ? null : text;
  }
}
