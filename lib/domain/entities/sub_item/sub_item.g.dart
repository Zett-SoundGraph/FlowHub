// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubItem _$SubItemFromJson(Map<String, dynamic> json) => _SubItem(
  menuName: json['menuName'] as String? ?? '',
  status:
      $enumDecodeNullable(_$OrderStatusEnumMap, json['status']) ??
      OrderStatus.pending,
  progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
  logs:
      (json['logs'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isExtracting: json['isExtracting'] as bool? ?? false,
  isError: json['isError'] as bool? ?? false,
  errorCode: json['errorCode'] as String?,
  currentStage: json['currentStage'] as String? ?? 'Pending',
);

Map<String, dynamic> _$SubItemToJson(_SubItem instance) => <String, dynamic>{
  'menuName': instance.menuName,
  'status': _$OrderStatusEnumMap[instance.status]!,
  'progress': instance.progress,
  'logs': instance.logs,
  'isExtracting': instance.isExtracting,
  'isError': instance.isError,
  'errorCode': instance.errorCode,
  'currentStage': instance.currentStage,
};

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.ready: 'ready',
  OrderStatus.pickedUp: 'pickedUp',
};
