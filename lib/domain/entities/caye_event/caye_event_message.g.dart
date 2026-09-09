// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'caye_event_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CayeEventMessage _$CayeEventMessageFromJson(Map<String, dynamic> json) =>
    _CayeEventMessage(
      eventId: json['eventId'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 0,
      status: (json['status'] as num?)?.toInt() ?? 0,
      faults:
          (json['faults'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CayeEventMessageToJson(_CayeEventMessage instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'version': instance.version,
      'status': instance.status,
      'faults': instance.faults,
    };
