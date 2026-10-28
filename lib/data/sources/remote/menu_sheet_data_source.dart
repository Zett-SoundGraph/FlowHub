import 'dart:async';

import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/core/utils/log.dart';
import 'package:flowhub/domain/entities/menu_info/menu_info.dart';
import 'package:flowhub/domain/entities/menu_option/menu_option.dart';
import 'package:flowhub/domain/entities/selected_option/selected_option.dart';
import 'package:flowhub/domain/repositories/menu_repository.dart'
    show RecipeDispenser, RecipeTiming;

abstract interface class IMenuSheetDataSource {
  Future<void> load();
  Future<void> reloadNow();
  MenuInfo? getMenuInfo(String menuNameEN);
  MenuInfo? getMenuInfoBySku(String skuNo);
  List<MenuIngredient> getResolvedIngredients(String menuNameEN);
  List<MenuIngredient> resolveOptions(String menuNameEN, List<SelectedOption> options);
  RecipeTiming getRecipeTiming(String skuNo, String temp);
  /// Real pkey + dispenser string for [skuNo] (+ [temp]) — the ingredient
  /// amounts reflect the sheet's base recipe PLUS any [selectedOptions] that
  /// add onto a Nudof ingredient (Caramel Syrup/OP.22, Vanilla Syrup/OP.21 —
  /// see [_additiveOptionToRecipeLabel]), same additive rule as
  /// [getRecipePopupIngredients]'s recipe pills.
  RecipeDispenser getRecipeDispenser(String skuNo, String temp, List<SelectedOption> selectedOptions);
  /// Direct-viewable image URL for [skuNo] (+ [temp])'s recipe illustration —
  /// from the "Recipe List" sheet's Recipe_Image column, or null if the sheet
  /// has no matching row/value.
  String? getRecipeImage(String skuNo, String temp);
  /// Recipe version string for [skuNo] (+ [temp]) — from the "Recipe List"
  /// sheet's Version column, or null if the sheet has no matching row/value.
  String? getRecipeVersion(String skuNo, String temp);
  /// Every recipe ingredient/device label for [skuNo] (+ [temp]) that should
  /// be shown to an operator — name only, no amounts. Combines the Caye
  /// machine's recipe (resolved via the "Recipe List" sheet's Caye_Pkey
  /// pointing into the "CAYE PKey List" sheet: Espresso/Water/Milk, each
  /// shown only if its column has a real value) followed by the Nudof
  /// dispenser's recipe (straight from "Recipe List"'s own Manual_ICE
  /// through Peach_Base columns, same "shown only if non-empty/non-zero"
  /// rule). This is the base recipe only — a customer's actual added
  /// options are a separate concern (see [resolveOptions]).
  List<String> getRecipeIngredientLabels(String skuNo, String temp);
  /// The recipe popup's ingredient pills: base recipe amounts (same
  /// Caye/Nudof sources as [getRecipeIngredientLabels], but with real
  /// amounts this time) combined with [selectedOptions] where they overlap
  /// — an added Espresso shot or Caramel Syrup pump adds onto the matching
  /// recipe amount (e.g. recipe 30 + 1 added shot's 30 = 60), an ICE choice
  /// (Less/Regular/Extra) replaces Manual_ICE's recipe amount outright
  /// (not additive — the customer picked one specific ice level). Any other
  /// selected option (a topping, a syrup with no recipe counterpart) falls
  /// back to the normal added-beyond-default behavior as its own pill (see
  /// [resolveOptions]).
  List<MenuIngredient> getRecipePopupIngredients(
    String skuNo,
    String menuNameEN,
    String temp,
    List<SelectedOption> selectedOptions,
  );
  /// The printed label's [OPTION] section — no recipe data at all (unlike
  /// [getRecipePopupIngredients]), just the customer's actual
  /// added-beyond-default options, formatted as "{OptionName.EN}
  /// {Volume}g[ x{count}]" (the "x{count}" suffix only appears when more
  /// than one was added). Empty when every selected option matches its
  /// recipe default — the label's [OPTION] title itself only shows when
  /// this list is non-empty.
  List<MenuIngredient> getLabelOptions(String menuNameEN, List<SelectedOption> selectedOptions);
}

/// Loads menu/option reference data live from the exhibition's Google Sheet
/// (replacing the old bundled `recipe.csv`, which only ever covered a
/// throwaway 4-item placeholder menu). Only the "Menu List", "Option List",
/// "Group List" and "Category List" tabs are used — "Promotion List" and
/// "Store List" aren't needed by the FlowHub.
///
/// The "Version Info" tab's own CSV publish link is the fixed entry point:
/// it lists every tab's last-updated timestamp plus its own publish-to-web
/// CSV URL, so a cheap re-fetch of just that tab is enough to detect whether
/// any of the 4 tracked sheets actually changed before re-parsing them.
@Singleton(as: IMenuSheetDataSource)
class MenuSheetDataSource implements IMenuSheetDataSource {
  static const _tag = 'MenuSheet';

  static const _versionInfoCsvUrl =
      'https://docs.google.com/spreadsheets/d/e/2PACX-1vRjetA91xB8_tsu6wDnq8hRIi-0Par49dRi1fAy4LUliGtH0L9lADbfRAZrOqouUPjZmIQLcVNpvNY1/pub?gid=844462145&single=true&output=csv';

  static const _trackedSheets = {
    'Menu List',
    'Option List',
    'Group List',
    'Category List',
    'Recipe List',
    'CAYE PKey List',
  };

  // Recipe List column NAMES — looked up by header rather than fixed
  // position (see _headerIndex/_cell) so inserting/reordering a column in
  // the sheet (which has already happened twice — Version/Recipe_Image
  // shifted everything after MenuName.EN by +2 on 2026-07-29, and a
  // "Recepe Image" column shifted Menu List's OP.xx columns by +1 on
  // 2026-07-22) can never silently misalign every column after it again.
  // Manual_ICE is display-only (FlowHub/label option text) and deliberately
  // has no constant here — see RecipeDispenser.
  static const _colRecipeSkuNo = 'SKUNo';
  static const _colRecipeTemp = 'HOT/ICED';
  static const _colRecipeVersion = 'Version';
  static const _colRecipeImage = 'Recipe_Image';
  static const _colRecipeNudofTime = 'NudofTime';
  static const _colRecipeCayeTime = 'CayeTime';
  static const _colRecipeCayePkey = 'Caye_Pkey';
  static const _colRecipeOx = 'O/X';
  // Freeform notes column, not an ingredient amount — deliberately excluded
  // from the dynamic Nudof column list below even though it sits between
  // Caye_Pkey and O/X.
  static const _colRecipeProcess = 'Process';
  static const _defaultRecipeTiming = (nudofSeconds: 20, cayeSeconds: 60);
  static const _defaultRecipeDispenser = (cayePkey: '0', dispenserData: 'N:0');

  // Fallback column names, used only until the first real "Recipe List"
  // fetch populates [_nudofColumnNames]/[_dispenserColumnNames] below.
  static const _fallbackNudofColumnNames = [
    'Manual_ICE',
    'Cold_Brew',
    'Water',
    'Caramel_Syrup',
    'Peach_Base',
  ];

  /// Every Nudof ingredient/display column currently in "Recipe List" —
  /// DISPLAY use (order tags / recipe popup / label), Manual_ICE included
  /// since it's display-only, never a machine command (see the class
  /// comment on Manual_ICE further down). Computed fresh from the sheet's
  /// own header row every load (see [_columnNamesBetween]) rather than a
  /// fixed list, so a column added/removed to the right of Peach_Base (or
  /// anywhere else between Caye_Pkey and O/X) is picked up automatically —
  /// no code change needed.
  List<String> _nudofColumnNames = _fallbackNudofColumnNames;

  /// The subset of [_nudofColumnNames] that actually goes into a printed
  /// label's QR (see RecipeDispenser) — every Nudof column except
  /// Manual_ICE, since a barista adds ice by hand rather than the machine
  /// dispensing it; each remaining name doubles as the ingredient token the
  /// Nudof machine itself recognizes.
  List<String> _dispenserColumnNames =
      _fallbackNudofColumnNames.where((n) => n != 'Manual_ICE').toList();

  /// Every header strictly between Caye_Pkey and O/X (in sheet column
  /// order), excluding Process — i.e. every Nudof ingredient/display column
  /// "Recipe List" currently defines, whatever they're named. Falls back to
  /// every header after Caye_Pkey if O/X isn't present in this sheet
  /// snapshot, and to [_fallbackNudofColumnNames] if Caye_Pkey itself isn't
  /// found (should never happen against the real sheet).
  List<String> _columnNamesBetween(Map<String, int> headers) {
    final cayeIdx = headers[_colRecipeCayePkey];
    if (cayeIdx == null) return _fallbackNudofColumnNames;
    final oxIdx = headers[_colRecipeOx];
    final entries = headers.entries
        .where((e) =>
            e.value > cayeIdx &&
            (oxIdx == null || e.value < oxIdx) &&
            e.key != _colRecipeProcess)
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return [for (final e in entries) e.key];
  }

  // "CAYE PKey List" column NAMES — a second sheet, joined to "Recipe List"
  // via Caye_Pkey. Espresso's column name really is misspelled "Esprosso" in
  // the live sheet — kept verbatim since lookups are by exact header text.
  static const _colCayePkeyId = 'Caye_Pkey';
  static const _colCayePkeyEspresso = 'Esprosso Volume';
  static const _colCayePkeyHotWater = 'HOT Water (ml)';
  static const _colCayePkeyRtWater = 'RT Water (ml)';
  static const _colCayePkeyMilk = 'Milk Volume (ml)';

  // Menu List's OP.xx / OP.xx.Default column name pairs are just the
  // option number itself plus a ".Default" suffix — no separate position
  // map needed once lookups go by name.
  static const _optionNumbers = [
    'OP.11', 'OP.21', 'OP.22', 'OP.31', 'OP.32', 'OP.33',
    'OP.51', 'OP.52', 'OP.53', 'OP.91', 'OP.92', 'OP.93',
  ];

  static const _refreshInterval = Duration(minutes: 2);

  // A dedicated, bare Dio instance rather than the app's shared one (which
  // has CommonInterceptor attached): that interceptor rejects any response
  // whose body isn't a JSON Map/List (it expects the app's own REST API's
  // {data: ...} envelope), which is exactly the shape of every CSV response
  // here — every request would fail with "Invalid response format" if it
  // went through that client. Google Sheets is a different kind of external
  // service entirely, so it gets its own plain client, no shared interceptor.
  final Dio _dio = Dio(
    BaseOptions(connectTimeout: const Duration(seconds: 20), receiveTimeout: const Duration(seconds: 20)),
  );

  Map<String, MenuInfo> _menuMap = {};
  Map<String, MenuInfo> _menuMapBySku = {};
  Map<String, MenuOption> _optionCatalog = {};
  Map<String, RecipeTiming> _recipeTimingMap = {};
  Map<String, RecipeDispenser> _recipeDispenserMap = {};
  Map<String, String> _recipeImageMap = {};
  Map<String, String> _recipeVersionMap = {};
  Map<String, String> _cayePkeyBySkuMap = {};
  // Both keyed by display label ('Espresso'/'Water'/'Milk' for Caye,
  // 'Manual ICE'/'Cold Brew'/'Water'/'Caramel Syrup'/'Peach Base' for
  // Nudof) — amounts, not presence booleans, since the recipe popup needs
  // real numbers to add an option's amount onto. A missing/zero entry means
  // "not part of this recipe" (see [_hasValue]).
  Map<String, Map<String, int>> _nudofAmountsMap = {};
  Map<String, Map<String, int>> _cayePkeyAmountsMap = {};
  // Cached rather than re-fetched every reload — Menu List parsing needs
  // these to resolve Group.Code/Category.Code into display names, but they
  // themselves rarely change, so a Menu-List-only update (the common case)
  // should reuse whatever these already are instead of re-fetching them too.
  Map<String, String> _groupNames = {};
  Map<String, String> _categoryNames = {};
  final Map<String, String> _lastUpdated = {};
  Timer? _refreshTimer;

  @override
  Future<void> load() async {
    await _reload(await _fetchSheetMeta());
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => unawaited(_checkForUpdates()));
  }

  /// Same "only what actually changed" check the periodic timer runs — the
  /// Recipe Sync button's immediate version, for applying a just-edited
  /// sheet without waiting up to [_refreshInterval].
  @override
  Future<void> reloadNow() => _checkForUpdates();

  @override
  MenuInfo? getMenuInfo(String menuNameEN) => _menuMap[menuNameEN.trim()];

  @override
  MenuInfo? getMenuInfoBySku(String skuNo) => _menuMapBySku[skuNo.trim()];

  @override
  List<MenuIngredient> getResolvedIngredients(String menuNameEN) {
    final info = _menuMap[menuNameEN.trim()];
    if (info == null) return const [];
    return info.resolvedIngredients(_optionCatalog);
  }

  @override
  List<MenuIngredient> resolveOptions(String menuNameEN, List<SelectedOption> options) {
    final info = _menuMap[menuNameEN.trim()];
    if (info == null) return const [];
    return resolveSelectedOptions(info, options, _optionCatalog);
  }

  /// Tries the SKU+temp-specific row first (the sheet has separate HOT/ICED
  /// rows per SKU), then falls back to whichever row for that SKU was seen
  /// first, then the hardcoded default — a temp-string mismatch (e.g. "ICE"
  /// vs the sheet's "ICED") still resolves correctly this way since real
  /// sheet rows share the same times across temps anyway.
  @override
  RecipeTiming getRecipeTiming(String skuNo, String temp) {
    final sku = skuNo.trim();
    if (sku.isEmpty) return _defaultRecipeTiming;
    final key = '$sku|${temp.trim().toUpperCase()}';
    return _recipeTimingMap[key] ?? _recipeTimingMap[sku] ?? _defaultRecipeTiming;
  }

  @override
  RecipeDispenser getRecipeDispenser(String skuNo, String temp, List<SelectedOption> selectedOptions) {
    final sku = skuNo.trim();
    if (sku.isEmpty) return _defaultRecipeDispenser;
    final key = '$sku|${temp.trim().toUpperCase()}';
    final base = _recipeDispenserMap[key] ?? _recipeDispenserMap[sku] ?? _defaultRecipeDispenser;
    final baseNudof = _nudofAmountsMap[key] ?? _nudofAmountsMap[sku] ?? const <String, int>{};

    // Start from the sheet's own base amounts (display-label keys, e.g.
    // 'Caramel Syrup': 15), re-expressed as the QR's column-name tokens
    // (e.g. 'Caramel_Syrup') — only the ones this machine actually
    // recognizes ([_dispenserColumnNames], i.e. never Manual_ICE).
    final amounts = <String, int>{
      for (final name in _dispenserColumnNames)
        if ((baseNudof[name.replaceAll('_', ' ')] ?? 0) > 0)
          name: baseNudof[name.replaceAll('_', ' ')]!,
    };

    // Add on any selected option that adds onto a Nudof ingredient (e.g. an
    // extra Caramel Syrup pump) — same "beyond the recipe default" rule as
    // getRecipePopupIngredients, otherwise a customer's actual added-option
    // amount never reaches the machine and only the sheet's static recipe
    // default gets sent every time.
    final menuInfo = _menuMapBySku[sku];
    final defaultByOptionNo = {
      for (final slot in menuInfo?.optionSlots ?? const []) slot.optionNo: slot,
    };
    for (final sel in selectedOptions) {
      final recipeLabel = _additiveOptionToRecipeLabel[sel.optionNo];
      final column = recipeLabel?.replaceAll(' ', '_');
      if (column == null || !_dispenserColumnNames.contains(column)) continue;
      final option = _optionCatalog[sel.optionNo];
      if (option == null) continue;
      final defaultQty = int.tryParse(defaultByOptionNo[sel.optionNo]?.defaultRaw ?? '') ?? 0;
      final addedQty = sel.quantity - defaultQty;
      if (addedQty <= 0) continue;
      amounts[column] = (amounts[column] ?? 0) + (option.volume * addedQty).round();
    }

    final parts = [
      for (final name in _dispenserColumnNames)
        if ((amounts[name] ?? 0) > 0) '$name:${amounts[name]}',
    ];
    return (
      cayePkey: base.cayePkey,
      dispenserData: parts.isEmpty ? _defaultRecipeDispenser.dispenserData : parts.join(','),
    );
  }

  @override
  String? getRecipeImage(String skuNo, String temp) {
    final sku = skuNo.trim();
    if (sku.isEmpty) return null;
    final key = '$sku|${temp.trim().toUpperCase()}';
    return _recipeImageMap[key] ?? _recipeImageMap[sku];
  }

  @override
  String? getRecipeVersion(String skuNo, String temp) {
    final sku = skuNo.trim();
    if (sku.isEmpty) return null;
    final key = '$sku|${temp.trim().toUpperCase()}';
    return _recipeVersionMap[key] ?? _recipeVersionMap[sku];
  }

  /// A cell counts as "has a real value" if it's non-empty and not literally
  /// '0' — checked as a string rather than parsed as a number, since some
  /// real sheet values aren't pure numbers (e.g. an annotated amount).
  bool _hasValue(String raw) {
    final trimmed = raw.trim();
    return trimmed.isNotEmpty && trimmed != '0';
  }

  int _parseAmount(String raw) => (num.tryParse(raw.trim()) ?? 0).round();

  // Recipe popup bullet labels ("• Dispenser" / "• Coffee Machine" /
  // "• Manual") — Coffee Machine is always Caye; Dispenser is every Nudof
  // column except Manual ICE, which is its own "Manual" bullet (a barista
  // physically drops ice in by hand, unlike the other Nudof ingredients).
  static const _sourceCoffeeMachine = 'Coffee Machine';
  static const _sourceDispenser = 'Dispenser';
  static const _sourceManual = 'Manual';

  /// Every recipe ingredient's amount (+ bullet source) for [skuNo] (+
  /// [temp]), keyed by display label — Caye's Espresso/Water/Milk (via
  /// Caye_Pkey → "CAYE PKey List") merged with Nudof's own Manual ICE/Cold
  /// Brew/Water/Caramel Syrup/Peach Base (straight from "Recipe List").
  /// Zero/absent entries are omitted entirely, not included as 0.
  Map<String, ({int amount, String source})> getRecipeBaseAmounts(String skuNo, String temp) {
    final sku = skuNo.trim();
    if (sku.isEmpty) return const {};
    final key = '$sku|${temp.trim().toUpperCase()}';

    final amounts = <String, ({int amount, String source})>{};
    final cayePkey = _cayePkeyBySkuMap[key] ?? _cayePkeyBySkuMap[sku];
    final cayeAmounts = cayePkey == null ? null : _cayePkeyAmountsMap[cayePkey];
    if (cayeAmounts != null) {
      for (final entry in cayeAmounts.entries) {
        amounts[entry.key] = (amount: entry.value, source: _sourceCoffeeMachine);
      }
    }
    final nudofAmounts = _nudofAmountsMap[key] ?? _nudofAmountsMap[sku] ?? const <String, int>{};
    for (final entry in nudofAmounts.entries) {
      amounts[entry.key] = (
        amount: entry.value,
        source: entry.key == 'Manual ICE' ? _sourceManual : _sourceDispenser,
      );
    }
    return amounts;
  }

  @override
  List<String> getRecipeIngredientLabels(String skuNo, String temp) =>
      getRecipeBaseAmounts(skuNo, temp).keys.toList();

  // Option numbers whose selected amount adds onto (not replaces) the
  // matching recipe ingredient's own base amount — fixed for this
  // exhibition's current Option List (if another recipe-linked option is
  // added later this needs a matching entry). Espresso Shot (OP.11) adds
  // onto Caye's Espresso, Caramel Syrup (OP.22) and Vanilla Syrup (OP.21)
  // add onto their same-named Nudof column (see Dispenser Slot List — both
  // are real Nudof-dispensed syrups, same as Caramel Syrup).
  static const _additiveOptionToRecipeLabel = {
    'OP.11': 'Espresso',
    'OP.21': 'Vanilla Syrup',
    'OP.22': 'Caramel Syrup',
  };
  static const _additiveOptionSource = {
    'OP.11': _sourceCoffeeMachine,
    'OP.21': _sourceDispenser,
    'OP.22': _sourceDispenser,
  };

  // ICE options (Less/Regular/Extra) REPLACE Manual ICE's recipe amount
  // outright rather than adding to it — the customer picked one specific
  // ice level, not "extra on top of the recipe default".
  static const _iceOptionNumbers = {'OP.91', 'OP.92', 'OP.93'};

  @override
  List<MenuIngredient> getRecipePopupIngredients(
    String skuNo,
    String menuNameEN,
    String temp,
    List<SelectedOption> selectedOptions,
  ) {
    final baseAmounts = getRecipeBaseAmounts(skuNo, temp);
    final amounts = <String, int>{for (final e in baseAmounts.entries) e.key: e.value.amount};
    final sources = <String, String>{for (final e in baseAmounts.entries) e.key: e.value.source};
    final matchedOptionNos = <String>{};
    final menuInfo = _menuMapBySku[skuNo.trim()] ?? _menuMap[menuNameEN.trim()];
    final defaultByOptionNo = {
      for (final slot in menuInfo?.optionSlots ?? const []) slot.optionNo: slot,
    };

    for (final sel in selectedOptions) {
      final option = _optionCatalog[sel.optionNo];
      if (option == null) continue;

      if (_iceOptionNumbers.contains(sel.optionNo)) {
        amounts['Manual ICE'] = option.volume.round();
        sources['Manual ICE'] = _sourceManual;
        matchedOptionNos.add(sel.optionNo);
        continue;
      }

      final recipeLabel = _additiveOptionToRecipeLabel[sel.optionNo];
      if (recipeLabel == null) continue;
      matchedOptionNos.add(sel.optionNo);
      final defaultQty = int.tryParse(defaultByOptionNo[sel.optionNo]?.defaultRaw ?? '') ?? 0;
      final addedQty = sel.quantity - defaultQty;
      if (addedQty <= 0) continue;
      amounts[recipeLabel] = (amounts[recipeLabel] ?? 0) + (option.volume * addedQty).round();
      sources.putIfAbsent(recipeLabel, () => _additiveOptionSource[sel.optionNo]!);
    }

    final recipePills = [
      for (final entry in amounts.entries)
        if (entry.value > 0)
          MenuIngredient(
            name: entry.key,
            groupName: entry.key,
            amount: '${entry.value}${_unitFor(entry.key)}',
            source: sources[entry.key],
          ),
    ];

    final otherOptions = selectedOptions.where((s) => !matchedOptionNos.contains(s.optionNo)).toList();
    // Options with no recipe counterpart (a topping, or a syrup/milk variant
    // not in use this exhibition) aren't tied to a Dispenser/Coffee Machine
    // amount — bulleted as "Manual" since a barista is the one physically
    // adding them, same reasoning as Manual ICE above.
    final extraPills = menuInfo == null
        ? const <MenuIngredient>[]
        : resolveSelectedOptions(menuInfo, otherOptions, _optionCatalog)
            .map((i) => MenuIngredient(
                  name: i.name,
                  groupName: i.groupName,
                  amount: i.amount,
                  quantity: i.quantity,
                  source: _sourceManual,
                ))
            .toList();

    return [...recipePills, ...extraPills];
  }

  @override
  List<MenuIngredient> getLabelOptions(
    String menuNameEN,
    List<SelectedOption> selectedOptions,
  ) {
    final info = _menuMap[menuNameEN.trim()];
    if (info == null) return const [];
    final defaultByOptionNo = {for (final slot in info.optionSlots) slot.optionNo: slot};

    final lines = <MenuIngredient>[];
    for (final sel in selectedOptions) {
      final option = _optionCatalog[sel.optionNo];
      if (option == null) continue;
      final defaultSlot = defaultByOptionNo[sel.optionNo];
      final volume = option.volume.round();

      switch (option.type) {
        case MenuOptionType.quantity:
          final defaultQty = int.tryParse(defaultSlot?.defaultRaw ?? '') ?? 0;
          final addedQty = sel.quantity - defaultQty;
          if (addedQty <= 0) continue;
          lines.add(MenuIngredient(
            name: option.nameEN,
            groupName: option.groupNameEN,
            amount: '${(option.volume * addedQty).round()}g',
            quantity: addedQty,
          ));
        case MenuOptionType.single:
        case MenuOptionType.multi:
          final isDefault = defaultSlot?.defaultRaw.trim().toUpperCase() == 'TRUE';
          if (isDefault) continue;
          lines.add(MenuIngredient(
            name: option.nameEN,
            groupName: option.groupNameEN,
            amount: '${volume}g',
          ));
      }
    }
    return lines;
  }

  // Caye amounts (Espresso/Water/Milk) are all "(ml)" columns in "CAYE PKey
  // List"; Nudof amounts (Manual ICE/Cold Brew/Caramel Syrup/Peach Base) are
  // grams, matching the printed label's existing dispenser-amount
  // convention (see order_label_widget.dart's dispenserData formatting).
  static const _mlLabels = {'Espresso', 'Water', 'Milk'};
  String _unitFor(String label) => _mlLabels.contains(label) ? 'ml' : 'g';

  /// Fetches just the "Version Info" tab and re-loads only whichever
  /// tracked tabs' last-updated timestamp actually changed.
  Future<void> _checkForUpdates() async {
    try {
      final meta = await _fetchSheetMeta();
      final changed = meta.entries
          .where((e) => _lastUpdated[e.key] != e.value.lastUpdated)
          .map((e) => e.key)
          .toSet();
      if (changed.isEmpty) return;
      Log.d(_tag, 'Detected sheet update — reloading: ${changed.join(', ')}');
      await _reload(meta, sheetsToFetch: changed);
    } catch (e) {
      Log.e(_tag, 'Update check failed: $e');
    }
  }

  /// Re-fetches and re-parses [sheetsToFetch] (every tracked sheet if null —
  /// the very first [load]) and updates internal state. Menu List parsing
  /// depends on Group List/Category List's resolved names, so it's re-parsed
  /// whenever either of those needs fetching too, even if Menu List's own
  /// timestamp didn't change — using freshly fetched names if those were
  /// fetched this round, or the cached ones otherwise.
  Future<void> _reload(
    Map<String, ({String lastUpdated, String csvUrl})> sheetMeta, {
    Set<String>? sheetsToFetch,
  }) async {
    try {
      final fetch = sheetsToFetch ?? _trackedSheets;

      if (fetch.contains('Group List')) {
        _groupNames = await _fetchAndParse(sheetMeta['Group List'], _parseGroupList) ?? _groupNames;
      }
      if (fetch.contains('Category List')) {
        _categoryNames =
            await _fetchAndParse(sheetMeta['Category List'], _parseCategoryList) ?? _categoryNames;
      }
      if (fetch.contains('Option List')) {
        _optionCatalog = await _fetchAndParse(sheetMeta['Option List'], _parseOptionList) ?? _optionCatalog;
      }
      final needsMenu = fetch.contains('Menu List') ||
          fetch.contains('Group List') ||
          fetch.contains('Category List');
      if (needsMenu) {
        final menuSheet = await _fetchAndParse(
          sheetMeta['Menu List'],
          (table) => _parseMenuList(table, _groupNames, _categoryNames),
        );
        _menuMap = menuSheet?.byName ?? _menuMap;
        _menuMapBySku = menuSheet?.bySku ?? _menuMapBySku;
      }
      if (fetch.contains('Recipe List')) {
        final recipeSheet = await _fetchAndParse(sheetMeta['Recipe List'], _parseRecipeList);
        _recipeTimingMap = recipeSheet?.timings ?? _recipeTimingMap;
        _recipeDispenserMap = recipeSheet?.dispensers ?? _recipeDispenserMap;
        _recipeImageMap = recipeSheet?.images ?? _recipeImageMap;
        _recipeVersionMap = recipeSheet?.versions ?? _recipeVersionMap;
        _cayePkeyBySkuMap = recipeSheet?.cayePkeys ?? _cayePkeyBySkuMap;
        _nudofAmountsMap = recipeSheet?.nudofAmounts ?? _nudofAmountsMap;
        _nudofColumnNames = recipeSheet?.nudofColumnNames ?? _nudofColumnNames;
        _dispenserColumnNames = recipeSheet?.dispenserColumnNames ?? _dispenserColumnNames;
      }
      if (fetch.contains('CAYE PKey List')) {
        _cayePkeyAmountsMap =
            await _fetchAndParse(sheetMeta['CAYE PKey List'], _parseCayePkeyList) ?? _cayePkeyAmountsMap;
      }

      // Every tracked sheet's timestamp gets recorded, not just the ones
      // actually fetched this round — an unfetched sheet's content hasn't
      // changed, but its timestamp still needs to stay current so the next
      // check doesn't see a stale mismatch and re-fetch it for nothing.
      for (final entry in sheetMeta.entries) {
        _lastUpdated[entry.key] = entry.value.lastUpdated;
      }
      Log.d(_tag,
          'Loaded ${_menuMap.length} menu items, ${_optionCatalog.length} options, ${_recipeTimingMap.length} recipe timings');
    } catch (e) {
      Log.e(_tag, 'Failed to load menu sheet data: $e');
    }
  }

  Future<T?> _fetchAndParse<T>(
    ({String lastUpdated, String csvUrl})? sheetMeta,
    T Function(List<List<dynamic>> table) parser,
  ) async {
    if (sheetMeta == null) return null;
    final raw = await _fetchCsv(sheetMeta.csvUrl);
    return parser(_parseCsvTable(raw));
  }

  Future<Map<String, ({String lastUpdated, String csvUrl})>> _fetchSheetMeta() async {
    final raw = await _fetchCsv(_versionInfoCsvUrl);
    final table = _parseCsvTable(raw);
    final headers = _headerIndex(table);
    final result = <String, ({String lastUpdated, String csvUrl})>{};
    for (var i = 1; i < table.length; i++) {
      final row = table[i];
      final name = _cell(row, headers, 'Sheets');
      if (!_trackedSheets.contains(name)) continue;
      result[name] = (
        lastUpdated: _cell(row, headers, 'Last Updated (Sheet)'),
        csvUrl: _cell(row, headers, 'CSV File URL'),
      );
    }
    return result;
  }

  Future<String> _fetchCsv(String url) async {
    // The publish-to-web CSV URL always answers with an HTTP 307 redirect to
    // a googleusercontent.com CDN URL, never the CSV directly — confirmed via
    // `curl -sD -` (no -L). The shared Dio client has followRedirects=false
    // (di.dart, presumably intentional for the app's own REST API), so that
    // must be overridden per-request here or every fetch fails as a "bad
    // response" DioException before ever reaching the real CSV content.
    final response = await _dio.get<String>(
      url,
      options: Options(
        responseType: ResponseType.plain,
        followRedirects: true,
        maxRedirects: 5,
      ),
    );
    return response.data ?? '';
  }

  List<List<dynamic>> _parseCsvTable(String raw) {
    final normalized = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    return const CsvToListConverter(
      fieldDelimiter: ',',
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(normalized);
  }

  /// Maps each header cell (row 0) to its column position, so every parser
  /// below looks values up by name instead of a fixed index — a column
  /// inserted/reordered in the sheet just shifts positions in this map,
  /// never silently misaligns a hardcoded number again.
  Map<String, int> _headerIndex(List<List<dynamic>> table) {
    if (table.isEmpty) return const {};
    final header = table.first;
    final map = <String, int>{};
    for (var i = 0; i < header.length; i++) {
      final name = header[i].toString().trim();
      if (name.isNotEmpty) map[name] = i;
    }
    return map;
  }

  /// [row]'s value under column [name], or '' if that column doesn't exist
  /// in this sheet (unknown header) or this particular row is short one.
  String _cell(List<dynamic> row, Map<String, int> headers, String name) {
    final idx = headers[name];
    if (idx == null || idx >= row.length) return '';
    return row[idx].toString().trim();
  }

  Map<String, String> _parseGroupList(List<List<dynamic>> table) {
    final headers = _headerIndex(table);
    final map = <String, String>{};
    for (var i = 1; i < table.length; i++) {
      final row = table[i];
      final code = _cell(row, headers, 'Group.Code');
      if (code.isEmpty) continue;
      map[code] = _cell(row, headers, 'GroupName.EN');
    }
    return map;
  }

  Map<String, String> _parseCategoryList(List<List<dynamic>> table) {
    final headers = _headerIndex(table);
    final map = <String, String>{};
    for (var i = 1; i < table.length; i++) {
      final row = table[i];
      final code = _cell(row, headers, 'Category.Code');
      if (code.isEmpty) continue;
      map[code] = _cell(row, headers, 'Category.EN');
    }
    return map;
  }

  Map<String, MenuOption> _parseOptionList(List<List<dynamic>> table) {
    final headers = _headerIndex(table);
    final map = <String, MenuOption>{};
    for (var i = 1; i < table.length; i++) {
      final row = table[i];
      final optionNo = _cell(row, headers, 'Option No');
      if (optionNo.isEmpty) continue;
      map[optionNo] = MenuOption(
        optionNo: optionNo,
        type: menuOptionTypeFromSheet(_cell(row, headers, 'Type')),
        nameEN: _cell(row, headers, 'OptionName.EN'),
        groupNameEN: _cell(row, headers, 'GroupName.EN'),
        volume: double.tryParse(_cell(row, headers, 'Volume (g)')) ?? 0.0,
      );
    }
    return map;
  }

  /// Keys each row two ways: `SKU|TEMP` (exact) and bare `SKU` (first-seen
  /// fallback, used when a lookup's temp string doesn't match this sheet's
  /// exactly) — see [getRecipeTiming]/[getRecipeDispenser]/[getRecipeImage].
  /// All three maps come from the same row loop since they're the same
  /// sheet fetch.
  ({
    Map<String, RecipeTiming> timings,
    Map<String, RecipeDispenser> dispensers,
    Map<String, String> images,
    Map<String, String> versions,
    Map<String, String> cayePkeys,
    Map<String, Map<String, int>> nudofAmounts,
    List<String> nudofColumnNames,
    List<String> dispenserColumnNames,
  }) _parseRecipeList(List<List<dynamic>> table) {
    final headers = _headerIndex(table);
    final timings = <String, RecipeTiming>{};
    final dispensers = <String, RecipeDispenser>{};
    final images = <String, String>{};
    final versions = <String, String>{};
    final cayePkeys = <String, String>{};
    final nudofAmounts = <String, Map<String, int>>{};
    final nudofColumnNames = _columnNamesBetween(headers);
    final dispenserColumnNames = nudofColumnNames.where((n) => n != 'Manual_ICE').toList();

    for (var i = 1; i < table.length; i++) {
      final row = table[i];
      final skuNo = _cell(row, headers, _colRecipeSkuNo);
      if (skuNo.isEmpty) continue;
      final temp = _cell(row, headers, _colRecipeTemp).toUpperCase();
      final key = '$skuNo|$temp';

      final imageUrl = _resolveDriveImageUrl(_cell(row, headers, _colRecipeImage));
      if (imageUrl != null) {
        images[key] = imageUrl;
        images.putIfAbsent(skuNo, () => imageUrl);
      }

      final version = _cell(row, headers, _colRecipeVersion);
      if (version.isNotEmpty) {
        versions[key] = version;
        versions.putIfAbsent(skuNo, () => version);
      }

      final nudofSeconds = int.tryParse(_cell(row, headers, _colRecipeNudofTime));
      final cayeSeconds = int.tryParse(_cell(row, headers, _colRecipeCayeTime));
      final timing = (
        nudofSeconds: nudofSeconds ?? _defaultRecipeTiming.nudofSeconds,
        cayeSeconds: cayeSeconds ?? _defaultRecipeTiming.cayeSeconds,
      );
      timings[key] = timing;
      timings.putIfAbsent(skuNo, () => timing);

      final cayePkey = _cell(row, headers, _colRecipeCayePkey);
      final ingredientParts = <String>[];
      for (final name in dispenserColumnNames) {
        final raw = _cell(row, headers, name);
        final amount = num.tryParse(raw);
        if (amount == null || amount == 0) continue;
        ingredientParts.add('$name:$raw');
      }
      final dispenser = (
        cayePkey: cayePkey.isNotEmpty ? cayePkey : _defaultRecipeDispenser.cayePkey,
        dispenserData: ingredientParts.isEmpty
            ? _defaultRecipeDispenser.dispenserData
            : ingredientParts.join(','),
      );
      dispensers[key] = dispenser;
      dispensers.putIfAbsent(skuNo, () => dispenser);

      if (_hasValue(cayePkey)) {
        cayePkeys[key] = cayePkey;
        cayePkeys.putIfAbsent(skuNo, () => cayePkey);
      }

      final nudofRow = <String, int>{};
      for (final name in nudofColumnNames) {
        final raw = _cell(row, headers, name);
        if (!_hasValue(raw)) continue;
        nudofRow[name.replaceAll('_', ' ')] = _parseAmount(raw);
      }
      if (nudofRow.isNotEmpty) {
        nudofAmounts[key] = nudofRow;
        nudofAmounts.putIfAbsent(skuNo, () => nudofRow);
      }
    }
    return (
      timings: timings,
      dispensers: dispensers,
      images: images,
      versions: versions,
      cayePkeys: cayePkeys,
      nudofAmounts: nudofAmounts,
      nudofColumnNames: nudofColumnNames,
      dispenserColumnNames: dispenserColumnNames,
    );
  }

  /// Parses "CAYE PKey List", keyed by its own Caye_Pkey column (joined from
  /// "Recipe List"'s row of the same name — see [getRecipeBaseAmounts]).
  /// Only Espresso/Water/Milk with a real value ([_hasValue]) are kept; a
  /// zero/blank column is omitted entirely rather than stored as 0.
  Map<String, Map<String, int>> _parseCayePkeyList(List<List<dynamic>> table) {
    final headers = _headerIndex(table);
    final map = <String, Map<String, int>>{};
    for (var i = 1; i < table.length; i++) {
      final row = table[i];
      final pkey = _cell(row, headers, _colCayePkeyId);
      if (pkey.isEmpty) continue;

      final espresso = _cell(row, headers, _colCayePkeyEspresso);
      final hotWater = _cell(row, headers, _colCayePkeyHotWater);
      final rtWater = _cell(row, headers, _colCayePkeyRtWater);
      final milk = _cell(row, headers, _colCayePkeyMilk);
      // HOT Water and RT Water can never both be present on the same Caye
      // recipe (the machine draws one or the other, never both), so this
      // can't double-count — whichever one is set becomes "Water".
      final water = _hasValue(hotWater) ? hotWater : (_hasValue(rtWater) ? rtWater : '');

      final amounts = <String, int>{
        if (_hasValue(espresso)) 'Espresso': _parseAmount(espresso),
        if (_hasValue(water)) 'Water': _parseAmount(water),
        if (_hasValue(milk)) 'Milk': _parseAmount(milk),
      };
      if (amounts.isNotEmpty) map[pkey] = amounts;
    }
    return map;
  }

  ({Map<String, MenuInfo> byName, Map<String, MenuInfo> bySku}) _parseMenuList(
    List<List<dynamic>> table,
    Map<String, String>? groupNames,
    Map<String, String>? categoryNames,
  ) {
    final headers = _headerIndex(table);
    final byName = <String, MenuInfo>{};
    final bySku = <String, MenuInfo>{};
    for (var i = 1; i < table.length; i++) {
      final row = table[i];
      final skuNo = _cell(row, headers, 'SKUNo');
      final menuNameEN = _cell(row, headers, 'MenuName.EN');
      if (menuNameEN.isEmpty) continue;
      final groupCode = _cell(row, headers, 'Group.Code');
      final categoryCode = _cell(row, headers, 'Category.Code');

      final slots = [
        for (final optionNo in _optionNumbers)
          MenuOptionSlot(
            optionNo: optionNo,
            enabled: _cell(row, headers, optionNo).toUpperCase() == 'TRUE',
            defaultRaw: _cell(row, headers, '$optionNo.Default'),
          ),
      ];

      final info = MenuInfo(
        menuNameEN: menuNameEN,
        hot: _cell(row, headers, 'HOT').toUpperCase() == 'TRUE',
        iced: _cell(row, headers, 'ICED').toUpperCase() == 'TRUE',
        groupNameEN: groupNames?[groupCode] ?? groupCode,
        categoryNameEN: categoryNames?[categoryCode] ?? categoryCode,
        thumbnailImageUrl: _resolveDriveImageUrl(_cell(row, headers, 'Thumbnail.Image')),
        optionSlots: slots,
      );
      byName[menuNameEN] = info;
      if (skuNo.isNotEmpty) bySku[skuNo] = info;
    }
    return (byName: byName, bySku: bySku);
  }

  /// Converts a Google Drive "view" share link into a direct-viewable image
  /// URL (`lh3.googleusercontent.com`), or null if no file ID can be found.
  String? _resolveDriveImageUrl(String rawUrl) {
    if (rawUrl.isEmpty) return null;
    final match = RegExp(r'/d/([a-zA-Z0-9_-]+)').firstMatch(rawUrl);
    final id = match?.group(1);
    if (id == null) return null;
    return 'https://lh3.googleusercontent.com/d/$id=s200';
  }
}
