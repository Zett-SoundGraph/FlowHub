import 'package:freezed_annotation/freezed_annotation.dart';

part 'follower_sync_request.freezed.dart';
part 'follower_sync_request.g.dart';

/// Payload for `beta/flowhub/follower/{followerId}/update` (Cafe Beta MQTT
/// Protocol.xlsx) — a follower's request for the leader to perform some
/// action, since only the leader ever touches real hardware (Caye machine,
/// printer) or owns the authoritative order state. [sync] identifies which
/// action (see FlowHubCubit._handleFollowerSyncRequest for the full list); the
/// leader executes it locally then broadcasts the result via
/// [LeaderUpdateMessage] like any other change.
@freezed
abstract class FollowerSyncRequest with _$FollowerSyncRequest {
  const factory FollowerSyncRequest({
    required String sync,
    @Default('') String eventId,
    @Default(0) int version,
    @Default({}) Map<String, dynamic> params,
  }) = _FollowerSyncRequest;

  factory FollowerSyncRequest.fromJson(Map<String, dynamic> json) =>
      _$FollowerSyncRequestFromJson(json);
}
