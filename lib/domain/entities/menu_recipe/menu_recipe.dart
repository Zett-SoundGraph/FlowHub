import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_recipe.freezed.dart';

@freezed
abstract class MenuRecipe with _$MenuRecipe {
  const MenuRecipe._();

  const factory MenuRecipe({
    required String productKey,
    required String menuNameEN,
    @Default('') String beanWeight,
    @Default('') String espresso,
    @Default('') String waterIce,
    @Default('') String waterHot,
    @Default('') String milk,
    // CSV column[11] — e.g. "20(Banana_Syrup)" → stored as "Banana_Syrup:20"
    @Default('N:0') String dispenserData,
  }) = _MenuRecipe;

  bool isValid(String v) => v.isNotEmpty && v != '-';

  List<String> get optionLines {
    final lines = <String>[];
    if (isValid(espresso)) {
      final dose = isValid(beanWeight) ? ' (Bean: ${beanWeight}g)' : '';
      lines.add('- ESP: ${espresso}ml$dose');
    }
    if (isValid(waterIce)) lines.add('- WATER (ICE): ${waterIce}ml');
    if (isValid(waterHot)) lines.add('- WATER (HOT): ${waterHot}ml');
    if (isValid(milk)) lines.add('- MILK: ${milk}ml');
    return lines;
  }
}
