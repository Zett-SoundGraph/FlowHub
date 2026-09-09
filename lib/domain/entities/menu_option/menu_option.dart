import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_option.freezed.dart';

/// How an option group behaves: [quantity] options (e.g. espresso shots) can
/// be incremented/decremented independent of the group, [single] options let
/// the customer pick exactly one within the group (e.g. milk type), and
/// [multi] options allow picking any number within the group (e.g. toppings).
enum MenuOptionType { quantity, single, multi }

MenuOptionType menuOptionTypeFromSheet(String raw) => switch (raw.trim().toLowerCase()) {
  'quantity' => MenuOptionType.quantity,
  'single' => MenuOptionType.single,
  'multi' => MenuOptionType.multi,
  _ => MenuOptionType.single,
};

/// A single sellable option from the "Option List" sheet (e.g. `OP.11` =
/// Espresso Shot), keyed by [optionNo] in the catalog held by the menu data
/// source.
@freezed
abstract class MenuOption with _$MenuOption {
  const factory MenuOption({
    required String optionNo,
    required MenuOptionType type,
    required String nameEN,
    @Default('') String groupNameEN,
    @Default(0.0) double volume,
  }) = _MenuOption;
}
