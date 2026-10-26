import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flowhub/domain/entities/order/order.dart';

part 'leader_update_message.freezed.dart';
part 'leader_update_message.g.dart';

/// Payload for `beta/flowhub/leader/update` (Cafe Beta MQTT Protocol.xlsx) —
/// the leader's full state snapshot, broadcast (retained) to all followers
/// and Flow Board whenever anything screen-visible changes. Followers
/// replace their local state wholesale with this rather than computing it
/// themselves, so there's a single source of truth.
@freezed
abstract class LeaderUpdateMessage with _$LeaderUpdateMessage {
  const factory LeaderUpdateMessage({
    @Default('orders_snapshot') String updateType,
    // Generic receiver-group label, not a specific device — this is a
    // single retained broadcast every Follower (F01/F02/...) receives
    // identically, so no one Follower's own name can go here. Never read
    // by any receiver; purely a human-eyeballing label on a raw payload.
    @Default('flowhubF') String boardName,
    @Default('') String eventId,
    // Monotonically increasing — a follower only applies this update if it's
    // newer than the last one it already applied, guarding against
    // out-of-order delivery rolling the UI back to a stale state.
    @Default(0) int version,
    @Default([]) List<Order> orders,
    @Default(false) bool isCalibrating,
    @Default(920) int calibrationHeight,
    @Default(false) bool isPrinterConnected,
    @Default(false) bool isLabelAttached,
    // Raspberry Pi (ToF) and Caye machine connections only physically exist
    // on the leader (direct WebSocket-server / TCP-socket hardware links) —
    // mirrored here the same way isPrinterConnected already is, so a
    // follower's Device Management screen shows the leader's real state
    // instead of being permanently stuck at FlowHubState.initial()'s false.
    @Default(false) bool isConnected,
    @Default(false) bool isCayeConnected,
  }) = _LeaderUpdateMessage;

  factory LeaderUpdateMessage.fromJson(Map<String, dynamic> json) =>
      _$LeaderUpdateMessageFromJson(json);
}
