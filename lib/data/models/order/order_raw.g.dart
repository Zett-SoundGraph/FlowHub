// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_raw.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderRaw _$OrderRawFromJson(Map<String, dynamic> json) => _OrderRaw(
  orderNo: json['orderNo'] as String? ?? '',
  menuName: json['menuName'] as String? ?? '',
  status:
      $enumDecodeNullable(_$OrderStatusEnumMap, json['status']) ??
      OrderStatus.pending,
);

Map<String, dynamic> _$OrderRawToJson(_OrderRaw instance) => <String, dynamic>{
  'orderNo': instance.orderNo,
  'menuName': instance.menuName,
  'status': _$OrderStatusEnumMap[instance.status]!,
};

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.ready: 'ready',
  OrderStatus.pickedUp: 'pickedUp',
};
