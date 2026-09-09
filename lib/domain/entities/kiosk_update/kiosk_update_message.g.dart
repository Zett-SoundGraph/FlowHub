// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kiosk_update_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KioskUpdateMessage _$KioskUpdateMessageFromJson(Map<String, dynamic> json) =>
    _KioskUpdateMessage(
      eventId: json['eventId'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 0,
      orders: (json['orders'] as num?)?.toInt() ?? 0,
      waiting: (json['waiting'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$KioskUpdateMessageToJson(_KioskUpdateMessage instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'version': instance.version,
      'orders': instance.orders,
      'waiting': instance.waiting,
    };
