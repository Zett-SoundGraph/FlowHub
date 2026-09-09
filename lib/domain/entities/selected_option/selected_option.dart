import 'package:freezed_annotation/freezed_annotation.dart';

part 'selected_option.freezed.dart';
part 'selected_option.g.dart';

/// One option a customer actually picked on a real kiosk order — e.g.
/// `{"optionNo": "OP.11", "quantity": 2}` for 2 espresso shots. Unlike
/// [MenuOptionSlot] (the Menu List sheet's baked-in *default* recipe), this
/// is what the customer really chose for this specific order.
@freezed
abstract class SelectedOption with _$SelectedOption {
  const factory SelectedOption({
    required String optionNo,
    @Default(1) int quantity,
  }) = _SelectedOption;

  factory SelectedOption.fromJson(Map<String, dynamic> json) =>
      _$SelectedOptionFromJson(json);
}
