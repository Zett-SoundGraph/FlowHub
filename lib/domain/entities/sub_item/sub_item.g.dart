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
  skuNo: json['skuNo'] as String? ?? '',
  temp: json['temp'] as String? ?? '',
  size: json['size'] as String? ?? '',
  selectedOptions:
      (json['selectedOptions'] as List<dynamic>?)
          ?.map((e) => SelectedOption.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  phaseStartedAt: json['phaseStartedAt'] == null
      ? null
      : DateTime.parse(json['phaseStartedAt'] as String),
  phaseStartProgress: (json['phaseStartProgress'] as num?)?.toDouble() ?? 0.0,
  phaseTargetProgress: (json['phaseTargetProgress'] as num?)?.toDouble() ?? 0.0,
  phaseDurationSeconds: (json['phaseDurationSeconds'] as num?)?.toInt() ?? 0,
  stage:
      $enumDecodeNullable(_$ProductionStageEnumMap, json['stage']) ??
      ProductionStage.none,
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
  'skuNo': instance.skuNo,
  'temp': instance.temp,
  'size': instance.size,
  'selectedOptions': instance.selectedOptions,
  'phaseStartedAt': instance.phaseStartedAt?.toIso8601String(),
  'phaseStartProgress': instance.phaseStartProgress,
  'phaseTargetProgress': instance.phaseTargetProgress,
  'phaseDurationSeconds': instance.phaseDurationSeconds,
  'stage': _$ProductionStageEnumMap[instance.stage]!,
};

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.ready: 'ready',
  OrderStatus.pickedUp: 'pickedUp',
};

const _$ProductionStageEnumMap = {
  ProductionStage.none: 'none',
  ProductionStage.nudofDispensing: 'nudofDispensing',
  ProductionStage.cayeCommandSent: 'cayeCommandSent',
  ProductionStage.cayeExtracting: 'cayeExtracting',
  ProductionStage.cayeComplete: 'cayeComplete',
  ProductionStage.cayeCanceled: 'cayeCanceled',
  ProductionStage.cayeFailed: 'cayeFailed',
};
