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
  ledColorHex: json['ledColorHex'] as String?,
  manual: json['manual'] as bool? ?? false,
  itemType: json['itemType'] as String?,
  amount: (json['amount'] as num?)?.toInt(),
  brewStartedAt: json['brewStartedAt'] == null
      ? null
      : DateTime.parse(json['brewStartedAt'] as String),
  brewStartedBy: json['brewStartedBy'] as String?,
  brewCompletedAt: json['brewCompletedAt'] == null
      ? null
      : DateTime.parse(json['brewCompletedAt'] as String),
  brewCompletedBy: json['brewCompletedBy'] as String?,
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
  'ledColorHex': instance.ledColorHex,
  'manual': instance.manual,
  'itemType': instance.itemType,
  'amount': instance.amount,
  'brewStartedAt': instance.brewStartedAt?.toIso8601String(),
  'brewStartedBy': instance.brewStartedBy,
  'brewCompletedAt': instance.brewCompletedAt?.toIso8601String(),
  'brewCompletedBy': instance.brewCompletedBy,
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
