import 'package:freezed_annotation/freezed_annotation.dart';

part 'kiosk_update_message.freezed.dart';
part 'kiosk_update_message.g.dart';

/// Published to `beta/flowhub/kiosk/update` — the same two numbers shown at
/// the bottom-bar's left side (figmaImage/1_main-*.png: order/waiting
/// counts), so the kiosk can mirror them. Deliberately its own topic/shape
/// (not folded into `beta/flowhub/board/update`) since the kiosk is a
/// different audience with a different, even smaller need.
@freezed
abstract class KioskUpdateMessage with _$KioskUpdateMessage {
  const factory KioskUpdateMessage({
    @Default('') String eventId,
    @Default(0) int version,
    @Default(0) int orders,
    @Default(0) int waiting,
  }) = _KioskUpdateMessage;

  factory KioskUpdateMessage.fromJson(Map<String, dynamic> json) =>
      _$KioskUpdateMessageFromJson(json);
}
