/// Splits an order number for display into its leading-letter badge and the
/// remaining digits (e.g. "A9528" → prefix "A", number "9528"). Originally
/// this letter was meant to be a fixed "K"/"M" (kiosk vs. mobile), but the
/// kiosk actually attaches its own leading letter to every real order
/// number — this just reads that back out as-is, whatever it is, rather
/// than restricting to a hardcoded set. Falls back to an empty prefix (the
/// whole string as the number) for an order number with no leading letter
/// at all.
({String prefix, String number}) splitOrderNoForDisplay(String orderNo) {
  final match = RegExp(r'^([A-Za-z]+)(.*)$').firstMatch(orderNo);
  if (match == null) return (prefix: '', number: orderNo);
  return (prefix: match.group(1)!.toUpperCase(), number: match.group(2)!);
}
