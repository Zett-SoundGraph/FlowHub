import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flowhub/domain/entities/menu_option/menu_option.dart';
import 'package:flowhub/domain/entities/selected_option/selected_option.dart';

part 'menu_info.freezed.dart';

/// One `OP.xx`/`OP.xx.Default` column pair from the "Menu List" sheet for a
/// single menu item: whether that option slot is offered at all ([enabled]),
/// and its baked-in recipe default ([defaultRaw] — a count string like `'2'`
/// for [MenuOptionType.quantity] slots, or `'TRUE'`/`'FALSE'` for
/// [MenuOptionType.single]/[MenuOptionType.multi] slots).
@freezed
abstract class MenuOptionSlot with _$MenuOptionSlot {
  const factory MenuOptionSlot({
    required String optionNo,
    required bool enabled,
    required String defaultRaw,
  }) = _MenuOptionSlot;
}

/// A menu item's static reference data from the "Menu List" sheet (joined
/// with "Group List"/"Category List" for human-readable names).
@freezed
abstract class MenuInfo with _$MenuInfo {
  const factory MenuInfo({
    required String menuNameEN,
    @Default(false) bool hot,
    @Default(false) bool iced,
    @Default('') String groupNameEN,
    @Default('') String categoryNameEN,
    String? thumbnailImageUrl,
    @Default([]) List<MenuOptionSlot> optionSlots,
  }) = _MenuInfo;
}

/// A single resolved ingredient/option line for display (order-list tags,
/// recipe popup, printed label). [name] is the specific option name (e.g.
/// "Regular ice") and [groupName] its option group (e.g. "ICE") — different
/// UI spots use different ones (order-row tags want the specific name,
/// the recipe popup's Ingredients line wants the shorter group name).
/// [quantity] is only set (>0) for [MenuOptionType.quantity] slots.
/// [source] is the recipe popup's "• Dispenser/Coffee Machine/Manual" bullet
/// label — null for plain option add-ons that aren't part of the base Caye/
/// Nudof recipe (see GetRecipePopupIngredientsUseCase).
class MenuIngredient {
  final String name;
  final String groupName;
  final String amount;
  final int quantity;
  final String? source;
  const MenuIngredient({
    required this.name,
    required this.groupName,
    required this.amount,
    this.quantity = 0,
    this.source,
  });
}

extension MenuInfoIngredients on MenuInfo {
  /// Resolves this menu's enabled option slots into the ones actually
  /// included by default — i.e. the standard recipe, not a customer's
  /// per-order customization (which this app has no data for yet).
  /// [catalog] is the Option List lookup (by `optionNo`, e.g. `OP.11`).
  List<MenuIngredient> resolvedIngredients(Map<String, MenuOption> catalog) {
    final result = <MenuIngredient>[];
    for (final slot in optionSlots) {
      if (!slot.enabled) continue;
      final option = catalog[slot.optionNo];
      if (option == null) continue;

      switch (option.type) {
        case MenuOptionType.quantity:
          final qty = int.tryParse(slot.defaultRaw) ?? 0;
          if (qty <= 0) continue;
          result.add(
            MenuIngredient(
              name: option.nameEN,
              groupName: option.groupNameEN,
              amount: '${(option.volume * qty).round()}g',
              quantity: qty,
            ),
          );
        case MenuOptionType.single:
        case MenuOptionType.multi:
          if (slot.defaultRaw.trim().toUpperCase() != 'TRUE') continue;
          result.add(
            MenuIngredient(
              name: option.nameEN,
              groupName: option.groupNameEN,
              amount: '${option.volume.round()}g',
            ),
          );
      }
    }
    return result;
  }
}

/// Resolves a real order's actual customer-picked options into display
/// ingredients — but only the part that's an actual customization beyond
/// [menuInfo]'s static default recipe (e.g. a 3rd espresso shot when the
/// recipe default is 2), never the recipe's own baseline ingredients. The
/// kiosk order payload always sends the drink's *complete* resolved option
/// set (defaults included, not just customer-added extras), so this is the
/// only point that can tell "standard recipe" and "customer addition" apart
/// — printed labels/FlowHub tags would otherwise show the full recipe
/// every time, identically, regardless of what was actually customized.
List<MenuIngredient> resolveSelectedOptions(
  MenuInfo menuInfo,
  List<SelectedOption> selected,
  Map<String, MenuOption> catalog,
) {
  final defaultByOptionNo = {for (final slot in menuInfo.optionSlots) slot.optionNo: slot};
  final result = <MenuIngredient>[];
  for (final sel in selected) {
    final option = catalog[sel.optionNo];
    if (option == null) continue;
    final defaultSlot = defaultByOptionNo[sel.optionNo];

    switch (option.type) {
      case MenuOptionType.quantity:
        final defaultQty = int.tryParse(defaultSlot?.defaultRaw ?? '') ?? 0;
        final addedQty = sel.quantity - defaultQty;
        if (addedQty <= 0) continue;
        result.add(
          MenuIngredient(
            name: option.nameEN,
            groupName: option.groupNameEN,
            amount: '${(option.volume * addedQty).round()}g',
            quantity: addedQty,
          ),
        );
      case MenuOptionType.single:
      case MenuOptionType.multi:
        // Already part of the standard recipe (e.g. the default milk/ice
        // choice) — not a customization worth printing.
        final isDefault = defaultSlot?.defaultRaw.trim().toUpperCase() == 'TRUE';
        if (isDefault) continue;
        result.add(
          MenuIngredient(
            name: option.nameEN,
            groupName: option.groupNameEN,
            amount: '${option.volume.round()}g',
          ),
        );
    }
  }
  return result;
}
