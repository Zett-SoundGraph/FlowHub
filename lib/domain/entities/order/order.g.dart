// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Order _$OrderFromJson(Map<String, dynamic> json) => _Order(
  orderNo: json['orderNo'] as String? ?? '',
  menuName: json['menuName'] as String? ?? '',
  status:
      $enumDecodeNullable(_$OrderStatusEnumMap, json['status']) ??
      OrderStatus.pending,
);

Map<String, dynamic> _$OrderToJson(_Order instance) => <String, dynamic>{
  'orderNo': instance.orderNo,
  'menuName': instance.menuName,
  'status': _$OrderStatusEnumMap[instance.status]!,
};

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.ready: 'ready',
  OrderStatus.pickedUp: 'pickedUp',
};
