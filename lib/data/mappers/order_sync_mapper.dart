import 'package:flowhub/core/utils/cloud_format.dart';
import 'package:flowhub/domain/entities/order/order.dart';
import 'package:flowhub/domain/entities/sub_item/sub_item.dart';
import 'package:flowhub/domain/enums/order_status.dart';

/// Builds the `order` object of an order sync message
/// (`flow/hub/{storeId}/{hubId}/orders`, schema version 4), following the
/// Flow Manager Data Payload sheet.
///
/// `progress` (order and items) is sent with each version, but a change in
/// it alone is not a new version (see the order store), so the gauge tick
/// doesn't create a version every second.
extension OrderSyncMapper on Order {
  /// Sales channel sent when the order carries none (kiosk orders).
  static const String defaultChannel = 'KIOSK';

  /// SKU sent for an item without one (the field is required by the cloud).
  static const String unmappedSku = 'UNMAPPED';

  /// 1. Order fields, with [orderedAt] fixed by the caller (it never changes).
  /// 2. `displayNo`: the POS number as given; otherwise the orderNo without
  ///    its leading letters (`K1001` → `1001`).
  /// 3. `channel`: as received; KIOSK when the order has none.
  /// 4. `tab` = the stage of the item furthest behind, like the FlowHub tabs.
  /// 5. `totalCups` = drinks only.
  /// 6. `brewStartedAt` = the first cup's brewing start; `pickedUpAt` = when
  ///    the order entered DONE.
  /// 7. One item per cup, numbered from 1.
  Map<String, dynamic> toSyncOrder({required String orderedAt}) {
    final String tab = syncTab;
    return <String, dynamic>{
      'orderNo': orderNo,
      'displayNo': _limit(syncDisplayNo, 20),
      'channel': channel.isNotEmpty ? channel : defaultChannel,
      'tab': tab,
      if (paymentStatus != null) 'paymentStatus': paymentStatus,
      'totalCups': syncTotalCups,
      if (totalAmount != null) 'totalAmount': totalAmount,
      if (currency != null) 'currency': currency,
      if (language.isNotEmpty) 'language': _limit(language, 10),
      'progress': _progress(aggregateProgress),
      'orderedAt': orderedAt,
      'brewStartedAt': CloudFormat.timestampOrNull(firstBrewStartedAt),
      'pickedUpAt': tab == 'DONE'
          ? CloudFormat.timestampOrNull(stateEnteredAt)
          : null,
      if (tab == 'DONE' && pickedUpBy != null)
        'pickedUpBy': _limit(pickedUpBy!, 64),
      'cancelledAt': CloudFormat.timestampOrNull(cancelledAt),
      if (cancelledBy != null) 'cancelledBy': _limit(cancelledBy!, 64),
      'items': <Map<String, dynamic>>[
        for (int i = 0; i < items.length; i++)
          items[i].toSyncItem(i + 1, orderCancelled: isCancelled),
      ],
    };
  }

  /// The POS number as given; otherwise the orderNo without its leading
  /// letters, or the whole orderNo when nothing is left.
  String get syncDisplayNo {
    if (displayNo.isNotEmpty) return displayNo;
    final String digits = orderNo.replaceFirst(RegExp(r'^[A-Za-z]+'), '');
    return digits.isEmpty ? orderNo : digits;
  }

  /// Number of drinks: the order's drink count, else every item that is
  /// not food.
  int get syncTotalCups => drinkCount > 0
      ? drinkCount
      : items.where((SubItem i) => !i.isFood).length;

  /// The earliest brewing start of the order's cups; null before any.
  DateTime? get firstBrewStartedAt {
    DateTime? first;
    for (final SubItem item in items) {
      final DateTime? started = item.brewStartedAt;
      if (started != null && (first == null || started.isBefore(first))) {
        first = started;
      }
    }
    return first;
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

/// Progress rounded to 3 decimals, within the cloud's 0 ~ 9.999.
double _progress(double value) =>
    (value.clamp(0.0, 9.999) * 1000).round() / 1000;

extension SubItemSyncMapper on SubItem {
  /// Food item (POS item type FOOD).
  bool get isFood => itemType == 'FOOD';

  /// NEW / BREW / CALL / DONE, mirroring the FlowHub item pill.
  String get syncStage {
    if (status == OrderStatus.pickedUp) return 'DONE';
    if (status == OrderStatus.ready) return 'CALL';
    if (isExtracting || isError) return 'BREW';
    return 'NEW';
  }

  /// Item status for the cloud.
  /// - Order cancelled and the cup not done → CANCELLED.
  /// - Food: KITCHEN until done, then DONE.
  /// - Drinks: the stage, or FAILED for a cup in error.
  String syncStatus({bool orderCancelled = false}) {
    final String stage = syncStage;
    if (orderCancelled && stage != 'DONE') return 'CANCELLED';
    if (isFood) return stage == 'DONE' ? 'DONE' : 'KITCHEN';
    return isError ? 'FAILED' : stage;
  }

  /// PREPARING (not started or brewing), READY (waiting for pickup) or
  /// DONE (picked up).
  String get syncProductionStage => switch (syncStage) {
    'CALL' => 'READY',
    'DONE' => 'DONE',
    _ => 'PREPARING',
  };

  /// [orderCancelled]: cups not done yet go out as CANCELLED.
  Map<String, dynamic> toSyncItem(int seq, {bool orderCancelled = false}) =>
      <String, dynamic>{
        'seq': seq,
        if (itemType != null) 'itemType': itemType,
        'skuNo': skuNo.isEmpty ? OrderSyncMapper.unmappedSku : skuNo,
        'menuName': menuName,
        if (size.isNotEmpty) 'size': size.toUpperCase(),
        if (temp.isNotEmpty) 'temp': temp.toUpperCase(),
        'options': <Map<String, dynamic>>[
          for (final option in selectedOptions)
            <String, dynamic>{
              'optionNo': option.optionNo,
              'quantity': option.quantity,
            },
        ],
        if (amount != null) 'amount': amount,
        'status': syncStatus(orderCancelled: orderCancelled),
        'productionStage': syncProductionStage,
        'progress': _progress(progress),
        'brewStartedAt': CloudFormat.timestampOrNull(brewStartedAt),
        if (brewStartedBy != null) 'brewStartedBy': brewStartedBy,
        'brewCompletedAt': CloudFormat.timestampOrNull(brewCompletedAt),
        if (brewCompletedBy != null) 'brewCompletedBy': brewCompletedBy,
      };
}
