// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  orderNo: json['orderNo'] as String? ?? '',
  rawOrderId: json['rawOrderId'] as String? ?? '',
  nickname: json['nickname'] as String?,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => SubItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  drinkCount: (json['drinkCount'] as num?)?.toInt() ?? 0,
  foodCount: (json['foodCount'] as num?)?.toInt() ?? 0,
  bottleCount: (json['bottleCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'orderNo': instance.orderNo,
  'rawOrderId': instance.rawOrderId,
  'nickname': instance.nickname,
  'items': instance.items,
  'drinkCount': instance.drinkCount,
  'foodCount': instance.foodCount,
  'bottleCount': instance.bottleCount,
};
