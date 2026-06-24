// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_raw.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderRaw _$OrderRawFromJson(Map<String, dynamic> json) => _OrderRaw(
  orderNo: json['orderNo'] as String? ?? '',
  rawOrderId: json['rawOrderId'] as String? ?? '',
  nickname: json['nickname'] as String?,
  menuNames:
      (json['menuNames'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  drinkCount: (json['drinkCount'] as num?)?.toInt() ?? 0,
  foodCount: (json['foodCount'] as num?)?.toInt() ?? 0,
  bottleCount: (json['bottleCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$OrderRawToJson(_OrderRaw instance) => <String, dynamic>{
  'orderNo': instance.orderNo,
  'rawOrderId': instance.rawOrderId,
  'nickname': instance.nickname,
  'menuNames': instance.menuNames,
  'drinkCount': instance.drinkCount,
  'foodCount': instance.foodCount,
  'bottleCount': instance.bottleCount,
};
