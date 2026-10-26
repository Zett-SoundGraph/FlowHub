// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leader_update_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeaderUpdateMessage _$LeaderUpdateMessageFromJson(Map<String, dynamic> json) =>
    _LeaderUpdateMessage(
      updateType: json['updateType'] as String? ?? 'orders_snapshot',
      boardName: json['boardName'] as String? ?? 'flowhubF',
      eventId: json['eventId'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 0,
      orders:
          (json['orders'] as List<dynamic>?)
              ?.map((e) => Order.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isCalibrating: json['isCalibrating'] as bool? ?? false,
      calibrationHeight: (json['calibrationHeight'] as num?)?.toInt() ?? 920,
      isPrinterConnected: json['isPrinterConnected'] as bool? ?? false,
      isLabelAttached: json['isLabelAttached'] as bool? ?? false,
      isConnected: json['isConnected'] as bool? ?? false,
      isCayeConnected: json['isCayeConnected'] as bool? ?? false,
    );

Map<String, dynamic> _$LeaderUpdateMessageToJson(
  _LeaderUpdateMessage instance,
) => <String, dynamic>{
  'updateType': instance.updateType,
  'boardName': instance.boardName,
  'eventId': instance.eventId,
  'version': instance.version,
  'orders': instance.orders,
  'isCalibrating': instance.isCalibrating,
  'calibrationHeight': instance.calibrationHeight,
  'isPrinterConnected': instance.isPrinterConnected,
  'isLabelAttached': instance.isLabelAttached,
  'isConnected': instance.isConnected,
  'isCayeConnected': instance.isCayeConnected,
};
