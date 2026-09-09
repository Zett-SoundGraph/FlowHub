import 'package:flowhub/domain/entities/menu_info/menu_info.dart';
import 'package:flowhub/domain/entities/selected_option/selected_option.dart';

/// Nudof (dispenser) / Caye (coffee machine) estimated seconds for one
/// drink's recipe — from the "Recipe List" sheet's NudofTime/CayeTime
/// columns, defaulting to 20/60 when a row or value is missing.
typedef RecipeTiming = ({int nudofSeconds, int cayeSeconds});

/// Which hardware stage(s) a drink's recipe actually uses.
enum ProductionType { cayeOnly, nudofOnly, combo }

extension RecipeTimingClassifier on RecipeTiming {
  /// Derived from which of the two estimated times is zero — see the
  /// "Recipe List" sheet's own NudofTime/CayeTime columns.
  ProductionType get productionType {
    if (nudofSeconds <= 0 && cayeSeconds > 0) return ProductionType.cayeOnly;
    if (cayeSeconds <= 0 && nudofSeconds > 0) return ProductionType.nudofOnly;
    return ProductionType.combo;
  }
}

/// The real Caye "Product Key" + Nudof dispenser ingredient string to embed
/// in a printed label's QR — from the "Recipe List" sheet's Caye_Pkey column
/// and its Cold_Brew/Water/Caramel_Syrup/Peach_Base ingredient columns.
/// dispenserData only ever lists ingredients the Nudof machine can actually
/// recognize (an unrecognized token makes it reject the whole QR) — Recipe
/// List's SIZE/HOT-ICED/Manual_ICE columns are display-only (FlowHub/label
/// option text) and deliberately never go in here. Falls back to the safe
/// no-op values ('0'/'N:0') when the sheet has no matching row.
typedef RecipeDispenser = ({String cayePkey, String dispenserData});

abstract class MenuRepository {
  Future<void> load();
  /// Forces an immediate re-fetch of every tracked sheet (Menu/Option/Recipe
  /// List etc.), bypassing the periodic Version-Info-timestamp check — the
  /// hamburger menu's "Recipe Sync" button, for applying a just-edited sheet
  /// (timing/pkey/ingredients) without waiting up to 2 minutes.
  Future<void> reloadNow();
  MenuInfo? getMenuInfo(String menuNameEN);
  /// Looks up a menu by SKU instead of name — the kiosk order payload's own
  /// `menuName` is whatever language the customer's kiosk session was in,
  /// never trustworthy as an English display name on its own; `skuNo` is
  /// the only reliable key to resolve the real English name FlowHub/labels
  /// must always show (baristas, not customers, read those).
  MenuInfo? getMenuInfoBySku(String skuNo);
  List<MenuIngredient> getResolvedIngredients(String menuNameEN);
  /// Resolves a real order's actual selected options into display
  /// ingredients — but only the part that's a real customization beyond
  /// [menuNameEN]'s own static default recipe (see
  /// [resolveSelectedOptions]'s doc comment for why that filtering matters).
  List<MenuIngredient> resolveOptions(String menuNameEN, List<SelectedOption> options);
  /// Estimated Nudof/Caye seconds for [skuNo] (+ [temp], where the sheet has
  /// a HOT/ICED-specific row) — defaults to (20, 60) if not found.
  RecipeTiming getRecipeTiming(String skuNo, String temp);
  /// Real pkey + dispenser string for [skuNo] (+ [temp]) — see
  /// [RecipeDispenser]. Ingredient amounts include any [selectedOptions]
  /// that add onto a Nudof ingredient (e.g. an extra Caramel Syrup pump),
  /// not just the sheet's static base recipe.
  RecipeDispenser getRecipeDispenser(String skuNo, String temp, List<SelectedOption> selectedOptions);
  /// Direct-viewable image URL for [skuNo] (+ [temp])'s recipe illustration —
  /// from the "Recipe List" sheet's Recipe_Image column, or null if not found.
  String? getRecipeImage(String skuNo, String temp);
  /// Recipe version string for [skuNo] (+ [temp]) — from the "Recipe List"
  /// sheet's Version column, or null if not found.
  String? getRecipeVersion(String skuNo, String temp);
  /// Every recipe ingredient/device label (Caye + Nudof, name only, no
  /// amounts) for [skuNo] (+ [temp]) — resolved via "Recipe List"'s
  /// Caye_Pkey into "CAYE PKey List" (Espresso/Water/Milk) plus "Recipe
  /// List"'s own Manual_ICE-through-Peach_Base columns (Nudof). This is the
  /// base recipe only, not a customer's actual added options (see
  /// [resolveOptions]).
  List<String> getRecipeIngredientLabels(String skuNo, String temp);
  /// The recipe popup's ingredient pills — base recipe amounts combined
  /// with [selectedOptions] where they overlap (added Espresso/Caramel
  /// Syrup sum onto the recipe amount, an ICE choice replaces Manual_ICE's
  /// amount), any other selected option falling back to its normal
  /// added-beyond-default pill. Unlike [getRecipeIngredientLabels], amounts
  /// are included.
  List<MenuIngredient> getRecipePopupIngredients(
    String skuNo,
    String menuNameEN,
    String temp,
    List<SelectedOption> selectedOptions,
  );
  /// The printed label's [OPTION] section — no recipe data, just the
  /// customer's actual added-beyond-default options, formatted as
  /// "{OptionName.EN} {Volume}g[ x{count}]" (the "x{count}" suffix only
  /// appears when more than one was added). Empty when every selected
  /// option matches its recipe default.
  List<MenuIngredient> getLabelOptions(String menuNameEN, List<SelectedOption> selectedOptions);
}
