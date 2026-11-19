import 'package:flowhub/core/utils/cloud_format.dart';
import 'package:flowhub/domain/entities/order/order.dart';
import 'package:flowhub/domain/entities/sub_item/sub_item.dart';
import 'package:flowhub/domain/enums/order_status.dart';
import 'package:flowhub/domain/enums/production_stage.dart';

/// Builds the `order` object of an order sync message
/// (`flow/hub/{storeId}/{hubId}/orders`, schema version 4).
///
/// Only fields that change on a real order event go in: the live gauge
/// values (`progress`) are left out, so the gauge tick doesn't create a new
/// version every second.
extension OrderSyncMapper on Order {
  /// Sales channel sent when the order carries none (kiosk orders).
  static const String defaultChannel = 'KIOSK';

  /// SKU sent for an item without one (the field is required by the cloud).
  static const String unmappedSku = 'UNMAPPED';

  /// 1. Order fields, with [orderedAt] fixed by the caller (it never changes).
  /// 2. `tab` = the stage of the item furthest behind, like the FlowHub tabs.
  /// 3. `pickedUpAt` = when the order entered DONE.
  /// 4. One item per cup, numbered from 1.
  Map<String, dynamic> toSyncOrder({required String orderedAt}) {
    final String tab = syncTab;
    return <String, dynamic>{
      'orderNo': orderNo,
      'displayNo': _limit(displayNo.isNotEmpty ? displayNo : orderNo, 20),
      'channel': channel.isNotEmpty ? channel : defaultChannel,
      'tab': tab,
      if (paymentStatus != null) 'paymentStatus': paymentStatus,
      'totalCups': totalCups,
      if (totalAmount != null) 'totalAmount': totalAmount,
      if (currency != null) 'currency': currency,
      if (language.isNotEmpty) 'language': _limit(language, 10),
      'orderedAt': orderedAt,
      'pickedUpAt':
          tab == 'DONE' ? CloudFormat.timestampOrNull(stateEnteredAt) : null,
      'cancelledAt': CloudFormat.timestampOrNull(cancelledAt),
      if (cancelledBy != null) 'cancelledBy': cancelledBy,
      'items': <Map<String, dynamic>>[
        for (int i = 0; i < items.length; i++)
          items[i].toSyncItem(i + 1, orderCancelled: isCancelled),
      ],
    };
  }

  /// CANCELLED for a cancelled order; otherwise NEW / BREW / CALL / DONE of
  /// the item furthest behind (FlowHub tab rule).
  String get syncTab {
    if (isCancelled) return 'CANCELLED';
    if (items.isEmpty) return 'NEW';
    const List<String> order = <String>['NEW', 'BREW', 'CALL', 'DONE'];
    return items
        .map((SubItem i) => i.syncStage)
        .reduce((a, b) => order.indexOf(a) <= order.indexOf(b) ? a : b);
  }

  static String _limit(String value, int max) =>
      value.length <= max ? value : value.substring(0, max);
}

extension SubItemSyncMapper on SubItem {
  /// NEW / BREW / CALL / DONE, mirroring the FlowHub item pill.
  String get syncStage {
    if (status == OrderStatus.pickedUp) return 'DONE';
    if (status == OrderStatus.ready) return 'CALL';
    if (isExtracting || isError) return 'BREW';
    return 'NEW';
  }

  /// Item status for the cloud: the stage, or FAILED for an item in error.
  String get syncStatus => isError ? 'FAILED' : syncStage;

  /// [orderCancelled]: items not done yet go out as CANCELLED.
  Map<String, dynamic> toSyncItem(int seq, {bool orderCancelled = false}) =>
      <String, dynamic>{
    'seq': seq,
    if (itemType != null) 'itemType': itemType,
    'skuNo': skuNo.isEmpty ? OrderSyncMapper.unmappedSku : skuNo,
    'menuName': menuName,
    if (size.isNotEmpty) 'size': size,
    if (temp.isNotEmpty) 'temp': temp,
    'options': <Map<String, dynamic>>[
      for (final option in selectedOptions)
        <String, dynamic>{
          'optionNo': option.optionNo,
          'quantity': option.quantity,
        },
    ],
    if (amount != null) 'amount': amount,
    'status': orderCancelled && syncStage != 'DONE' ? 'CANCELLED' : syncStatus,
    if (stage != ProductionStage.none) 'productionStage': stage.name,
  };
}
