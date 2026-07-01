import 'dart:typed_data';

import 'package:injectable/injectable.dart' hide Order;
import 'package:kds/data/sources/remote/printer_data_source.dart';
import 'package:kds/domain/repositories/printer_repository.dart';

@Singleton(as: PrinterRepository)
class PrinterRepositoryImpl implements PrinterRepository {
  final IPrinterDataSource _dataSource;

  PrinterRepositoryImpl(this._dataSource);

  @override
  Stream<bool> get statusStream => _dataSource.statusStream;

  @override
  Future<void> printLabel(Uint8List pngBytes) => _dataSource.printLabel(pngBytes);

  @override
  Future<void> printTest(List<String> menus) => _dataSource.printTest(menus);

  @override
  void dispose() => _dataSource.dispose();
}
