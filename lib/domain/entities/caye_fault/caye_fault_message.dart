import 'package:freezed_annotation/freezed_annotation.dart';

part 'caye_fault_message.freezed.dart';
part 'caye_fault_message.g.dart';

/// Published to `beta/flowhub/caye/fault` — 0x30's Fault Report, retained so
/// a subscriber that (re)connects late immediately sees the machine's
/// current fault state rather than waiting for the next change.
@freezed
abstract class CayeFaultMessage with _$CayeFaultMessage {
  const factory CayeFaultMessage({
    @Default('') String eventId,
    @Default(0) int version,
    @Default([]) List<CayeFaultEntry> errors,
  }) = _CayeFaultMessage;

  factory CayeFaultMessage.fromJson(Map<String, dynamic> json) =>
      _$CayeFaultMessageFromJson(json);
}

/// One `errors[]` entry — [status] is the entry's own 0=Triggered/1=Cleared
/// value (see CayeFaultCode's class doc comment for why 0x30's shape differs
/// from 0x12/0x22's). [summary] is pre-formatted via
/// [CayeFaultCode.describeEntry] so a subscriber never needs its own copy of
/// the E/S/W lookup table.
@freezed
abstract class CayeFaultEntry with _$CayeFaultEntry {
  const factory CayeFaultEntry({
    @Default('') String code,
    @Default(0) int status,
    @Default('') String summary,
  }) = _CayeFaultEntry;

  factory CayeFaultEntry.fromJson(Map<String, dynamic> json) =>
      _$CayeFaultEntryFromJson(json);
}
