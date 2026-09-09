// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board_update_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BoardUpdateMessage _$BoardUpdateMessageFromJson(Map<String, dynamic> json) =>
    _BoardUpdateMessage(
      boardName: json['boardName'] as String? ?? 'pickup_board',
      eventId: json['eventId'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 0,
      orders:
          (json['orders'] as List<dynamic>?)
              ?.map((e) => BoardOrder.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$BoardUpdateMessageToJson(_BoardUpdateMessage instance) =>
    <String, dynamic>{
      'boardName': instance.boardName,
      'eventId': instance.eventId,
      'version': instance.version,
      'orders': instance.orders,
    };

_BoardOrder _$BoardOrderFromJson(Map<String, dynamic> json) => _BoardOrder(
  orderNo: json['orderNo'] as String? ?? '',
  tab: json['tab'] as String? ?? 'newOrder',
  totalCups: (json['totalCups'] as num?)?.toInt() ?? 0,
  lang: json['lang'] as String? ?? '',
  progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => BoardOrderItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$BoardOrderToJson(_BoardOrder instance) =>
    <String, dynamic>{
      'orderNo': instance.orderNo,
      'tab': instance.tab,
      'totalCups': instance.totalCups,
      'lang': instance.lang,
      'progress': instance.progress,
      'items': instance.items,
    };

_BoardOrderItem _$BoardOrderItemFromJson(Map<String, dynamic> json) =>
    _BoardOrderItem(
      seq: (json['seq'] as num?)?.toInt() ?? 0,
      skuNo: json['skuNo'] as String? ?? '',
      temp: json['temp'] as String? ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      menuName: json['menuName'] as String? ?? '',
      stage: json['stage'] as String? ?? 'none',
      dispenserName: json['dispenserName'] as String? ?? '',
    );

Map<String, dynamic> _$BoardOrderItemToJson(_BoardOrderItem instance) =>
    <String, dynamic>{
      'seq': instance.seq,
      'skuNo': instance.skuNo,
      'temp': instance.temp,
      'progress': instance.progress,
      'menuName': instance.menuName,
      'stage': instance.stage,
      'dispenserName': instance.dispenserName,
    };
