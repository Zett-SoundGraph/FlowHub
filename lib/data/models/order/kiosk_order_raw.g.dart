// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_order_raw.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KioskOrderRaw _$KioskOrderRawFromJson(Map<String, dynamic> json) =>
    _KioskOrderRaw(
      eventId: json['eventId'] as String? ?? '',
      orderNo: json['orderNo'] as String? ?? '',
      language: json['language'] as String? ?? '',
      totalCups: (json['totalCups'] as num?)?.toInt() ?? 0,
      orderTime: json['orderTime'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) => KioskOrderItemRaw.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$KioskOrderRawToJson(_KioskOrderRaw instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'orderNo': instance.orderNo,
      'language': instance.language,
      'totalCups': instance.totalCups,
      'orderTime': instance.orderTime,
      'items': instance.items,
    };

_KioskOrderItemRaw _$KioskOrderItemRawFromJson(Map<String, dynamic> json) =>
    _KioskOrderItemRaw(
      seq: (json['seq'] as num?)?.toInt() ?? 0,
      skuNo: json['skuNo'] as String? ?? '',
      menuName: json['menuName'] as String? ?? '',
      temp: json['temp'] as String? ?? '',
      size: json['size'] as String? ?? '',
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => SelectedOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$KioskOrderItemRawToJson(_KioskOrderItemRaw instance) =>
    <String, dynamic>{
      'seq': instance.seq,
      'skuNo': instance.skuNo,
      'menuName': instance.menuName,
      'temp': instance.temp,
      'size': instance.size,
      'options': instance.options,
    };
