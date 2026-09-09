import 'package:freezed_annotation/freezed_annotation.dart';

part 'board_update_message.freezed.dart';
part 'board_update_message.g.dart';

/// Published to `beta/flowhub/board/update` — a deliberately separate,
/// lightweight broadcast for display boards (Flow Board / Pickup Board),
/// distinct from `beta/flowhub/leader/update` (the internal KDS
/// leader/follower state sync). Boards don't need the full internal Order
/// snapshot (logs, calibration, printer status, etc.), just enough to place
/// an order number in the right section and resolve its drink image/text —
/// keeping the two audiences on separate topics means neither payload shape
/// constrains the other as each evolves.
@freezed
abstract class BoardUpdateMessage with _$BoardUpdateMessage {
  const factory BoardUpdateMessage({
    @Default('pickup_board') String boardName,
    @Default('') String eventId,
    @Default(0) int version,
    @Default([]) List<BoardOrder> orders,
  }) = _BoardUpdateMessage;

  factory BoardUpdateMessage.fromJson(Map<String, dynamic> json) =>
      _$BoardUpdateMessageFromJson(json);
}

/// tab is one of OrderTab's names ('newOrder'/'brew'/'call'/'done') — boards
/// decide their own Preparing/Ready/removed grouping from this rather than
/// KDS dictating a board-specific status vocabulary.
@freezed
abstract class BoardOrder with _$BoardOrder {
  const factory BoardOrder({
    @Default('') String orderNo,
    @Default('newOrder') String tab,
    @Default(0) int totalCups,
    @Default('') String lang,
    // Average of every item's own progress (see Order.aggregateProgress) —
    // reaches 1.0 only once every item is individually confirmed complete.
    @Default(0.0) double progress,
    @Default([]) List<BoardOrderItem> items,
  }) = _BoardOrder;

  factory BoardOrder.fromJson(Map<String, dynamic> json) =>
      _$BoardOrderFromJson(json);
}

/// seq is the item's 1-based position within its order (matches the printed
/// label's own seq/totSeq numbering), for gauge display.
@freezed
abstract class BoardOrderItem with _$BoardOrderItem {
  const factory BoardOrderItem({
    @Default(0) int seq,
    @Default('') String skuNo,
    @Default('') String temp,
    // Estimated-time (Nudof) or real-telemetry (Caye) progress, continuously
    // pushed by KDS — see SubItem's phase-tracking fields for how this is
    // computed. Holds at 0.99 for any phase whose completion is confirmed by
    // a real signal rather than the estimate alone.
    @Default(0.0) double progress,
    // Plain display name (e.g. "Cafe Latte") — for boards to fill the
    // "[Menu Name]" token in a Language List bottom-bar template without
    // needing their own SKU->name lookup.
    @Default('') String menuName,
    // ProductionStage's name (e.g. "nudofDispensing") — see that enum's doc
    // comment for the full event list a board can key a bottom-bar message
    // off of. 'none' means no stage-worthy event has happened yet.
    @Default('none') String stage,
    // First Nudof ingredient name involved (e.g. "Cold_Brew"), for the
    // "[Dispenser]" token in the PB.BB.0002 template — only meaningful when
    // stage is 'nudofDispensing', empty otherwise.
    @Default('') String dispenserName,
  }) = _BoardOrderItem;

  factory BoardOrderItem.fromJson(Map<String, dynamic> json) =>
      _$BoardOrderItemFromJson(json);
}
