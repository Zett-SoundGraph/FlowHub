// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follower_sync_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FollowerSyncRequest _$FollowerSyncRequestFromJson(Map<String, dynamic> json) =>
    _FollowerSyncRequest(
      sync: json['sync'] as String,
      eventId: json['eventId'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 0,
      params: json['params'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$FollowerSyncRequestToJson(
  _FollowerSyncRequest instance,
) => <String, dynamic>{
  'sync': instance.sync,
  'eventId': instance.eventId,
  'version': instance.version,
  'params': instance.params,
};
