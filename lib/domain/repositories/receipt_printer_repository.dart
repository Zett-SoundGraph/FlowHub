abstract class ReceiptPrinterRepository {
  Future<void> printReceipt({required String orderNo, required List<String> menus});
}
