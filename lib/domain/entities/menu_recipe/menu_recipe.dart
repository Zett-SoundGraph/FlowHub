class MenuRecipe {
  final String productKey;
  final String menuNameEN;
  final String beanWeight;
  final String espresso;
  final String waterIce;
  final String waterHot;
  final String milk;
  // CSV column[11] — e.g. "20(Banana_Syrup)" → stored as "Banana_Syrup:20"
  final String dispenserData;

  const MenuRecipe({
    required this.productKey,
    required this.menuNameEN,
    this.beanWeight = '',
    this.espresso = '',
    this.waterIce = '',
    this.waterHot = '',
    this.milk = '',
    this.dispenserData = 'N:0',
  });

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
