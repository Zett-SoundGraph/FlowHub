import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:kds/core/utils/log.dart';
import 'package:kds/domain/entities/index.dart';

abstract interface class IRecipeDataSource {
  Future<void> load();
  MenuRecipe? getRecipe(String menuNameEN);
}

@Singleton(as: IRecipeDataSource)
class RecipeDataSource implements IRecipeDataSource {
  final Map<String, MenuRecipe> _recipeMap = {};

  @override
  Future<void> load() async {
    try {
      final String raw = await rootBundle.loadString('assets/data/recipe.csv');
      final normalized = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
      final table = const CsvToListConverter(
        fieldDelimiter: ',',
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(normalized);

      _recipeMap.clear();
      for (var i = 1; i < table.length; i++) {
        final row = table[i];
        if (row.length < 11) continue;
        final menuNameEN = row[3].toString().trim();
        if (menuNameEN.isEmpty) continue;
        _recipeMap[menuNameEN] = MenuRecipe(
          productKey: row[0].toString().trim(),
          menuNameEN: menuNameEN,
          beanWeight: row[5].toString().trim(),
          espresso: row[6].toString().trim(),
          waterIce: row[7].toString().trim(),
          waterHot: row[8].toString().trim(),
          milk: row[10].toString().trim(),
          dispenserData: _parseDispenserData(row.length > 11 ? row[11].toString().trim() : ''),
        );
      }
} catch (e) {
  Log.e('RecipeDataSource', 'Failed to load assets/data/recipe.csv: $e');
}
  }

  @override
  MenuRecipe? getRecipe(String menuNameEN) => _recipeMap[menuNameEN.trim()];

  // "20(Banana_Syrup)" → "Banana_Syrup:20", "-" or empty → "N:0"
  String _parseDispenserData(String raw) {
    if (raw.isEmpty || raw == '-') return 'N:0';
    final openParen = raw.indexOf('(');
    final closeParen = raw.indexOf(')');
    if (openParen > 0 && closeParen > openParen) {
      final amount = raw.substring(0, openParen).trim();
      final name = raw.substring(openParen + 1, closeParen).trim();
      if (amount.isNotEmpty && name.isNotEmpty) return '$name:$amount';
    }
    return 'N:0';
  }
}
