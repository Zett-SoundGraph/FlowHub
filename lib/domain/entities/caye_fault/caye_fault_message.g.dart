// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'caye_fault_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CayeFaultMessage _$CayeFaultMessageFromJson(Map<String, dynamic> json) =>
    _CayeFaultMessage(
      eventId: json['eventId'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 0,
      errors:
          (json['errors'] as List<dynamic>?)
              ?.map((e) => CayeFaultEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CayeFaultMessageToJson(_CayeFaultMessage instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'version': instance.version,
      'errors': instance.errors,
    };

_CayeFaultEntry _$CayeFaultEntryFromJson(Map<String, dynamic> json) =>
    _CayeFaultEntry(
      code: json['code'] as String? ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
      summary: json['summary'] as String? ?? '',
    );

Map<String, dynamic> _$CayeFaultEntryToJson(_CayeFaultEntry instance) =>
    <String, dynamic>{
      'code': instance.code,
      'status': instance.status,
      'summary': instance.summary,
    };
