import 'dart:typed_data';

import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/data/sources/remote/printer_data_source.dart';
import 'package:flowhub/domain/repositories/printer_repository.dart';

@Singleton(as: PrinterRepository)
class PrinterRepositoryImpl implements PrinterRepository {
  final IPrinterDataSource _dataSource;

  PrinterRepositoryImpl(this._dataSource);

  @override
  Stream<bool> get statusStream => _dataSource.statusStream;

  @override
  Stream<bool> get connectionStream => _dataSource.connectionStream;

  @override
  Future<void> printLabel(Uint8List pngBytes) => _dataSource.printLabel(pngBytes);

  @override
  Future<void> printTest(List<String> menus) => _dataSource.printTest(menus);

  @override
  Future<void> reconnect() => _dataSource.reconnect();

  @override
  Future<void> setAwaitingDetach(bool awaiting) => _dataSource.setAwaitingDetach(awaiting);

  @override
  void dispose() => _dataSource.dispose();
}
