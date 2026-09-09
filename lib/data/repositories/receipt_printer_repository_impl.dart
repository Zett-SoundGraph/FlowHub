import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/data/sources/remote/receipt_printer_data_source.dart';
import 'package:flowhub/domain/repositories/receipt_printer_repository.dart';

@Singleton(as: ReceiptPrinterRepository)
class ReceiptPrinterRepositoryImpl implements ReceiptPrinterRepository {
  final IReceiptPrinterDataSource _dataSource;

  ReceiptPrinterRepositoryImpl(this._dataSource);

  @override
  Future<void> printReceipt({required String orderNo, required List<String> menus}) =>
      _dataSource.printReceipt(orderNo: orderNo, menus: menus);
}
