import 'package:freezed_annotation/freezed_annotation.dart';

part 'caye_status_message.freezed.dart';
part 'caye_status_message.g.dart';

/// Published to `beta/flowhub/caye/status` — 0x31's Query Running Status
/// response, retained so a subscriber that (re)connects late immediately
/// sees the machine's current state rather than waiting for the next query.
/// [data] is a raw passthrough of the decrypted JSON rather than named
/// fields — the protocol doc describes what this carries (cleaning/rinsing
/// wait-or-progress state, fault presence, overall brew-availability) but
/// not the actual JSON key names, which haven't been observed from a live
/// machine yet (see CayeMachineDataSource._handleIncoming's 0x31 branch).
/// Once those are confirmed, this can be tightened into real typed fields.
@freezed
abstract class CayeStatusMessage with _$CayeStatusMessage {
  const factory CayeStatusMessage({
    @Default('') String eventId,
    @Default(0) int version,
    @Default(<String, dynamic>{}) Map<String, dynamic> data,
  }) = _CayeStatusMessage;

  factory CayeStatusMessage.fromJson(Map<String, dynamic> json) =>
      _$CayeStatusMessageFromJson(json);
}
