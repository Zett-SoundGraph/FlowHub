import 'package:freezed_annotation/freezed_annotation.dart';

part 'caye_event_message.freezed.dart';
part 'caye_event_message.g.dart';

/// Shared shape for 0x12 (Rinsing Event) and 0x03 (Cleaning Event) reports —
/// both carry the same {status, errorCode[]} fields on the wire (see
/// CayeMachineDataSource._handleIncoming), so one message type covers both,
/// published to their own topics (`beta/flowhub/caye/rinsing` /
/// `beta/flowhub/caye/cleaning`). [faults] is already formatted via
/// [CayeFaultCode.describe] so a subscriber (e.g. Flow Board) never needs its
/// own copy of the E/S/W lookup table.
@freezed
abstract class CayeEventMessage with _$CayeEventMessage {
  const factory CayeEventMessage({
    @Default('') String eventId,
    @Default(0) int version,
    @Default(0) int status,
    @Default([]) List<String> faults,
  }) = _CayeEventMessage;

  factory CayeEventMessage.fromJson(Map<String, dynamic> json) =>
      _$CayeEventMessageFromJson(json);
}
