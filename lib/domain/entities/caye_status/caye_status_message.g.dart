// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'caye_status_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CayeStatusMessage _$CayeStatusMessageFromJson(Map<String, dynamic> json) =>
    _CayeStatusMessage(
      eventId: json['eventId'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 0,
      data: json['data'] as Map<String, dynamic>? ?? const <String, dynamic>{},
    );

Map<String, dynamic> _$CayeStatusMessageToJson(_CayeStatusMessage instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'version': instance.version,
      'data': instance.data,
    };
