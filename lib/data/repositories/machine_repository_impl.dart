import 'package:injectable/injectable.dart' hide Order;
import 'package:kds/data/sources/remote/caye_machine_data_source.dart';
import 'package:kds/domain/entities/index.dart';
import 'package:kds/domain/repositories/machine_repository.dart';

@Singleton(as: MachineRepository)
class MachineRepositoryImpl implements MachineRepository {
  final ICayeMachineDataSource _dataSource;

  const MachineRepositoryImpl(this._dataSource);

  @override
  Stream<ExtractionProgress> get progressStream => _dataSource.progressStream;

  @override
  Stream<bool> get connectionStream => _dataSource.connectionStream;

  @override
  Future<void> sendMakeCommand(String ip, String productKey, String orderNo) =>
      _dataSource.sendMakeCommand(ip, productKey, orderNo);

  @override
  Future<void> sendCancelCommand(String ip, String productKey, String orderNo) =>
      _dataSource.sendCancelCommand(ip, productKey, orderNo);

  @override
  Future<void> sendCheckAvailability(String ip, String productKey) =>
      _dataSource.sendCheckAvailability(ip, productKey);

  @override
  Future<void> sendTimeSyncCommand(String ip) =>
      _dataSource.sendTimeSyncCommand(ip);

  @override
  Future<void> sendRinsingCommand(String ip) =>
      _dataSource.sendRinsingCommand(ip);

  @override
  Future<void> sendCleaningCommand(String ip, {int mode = 0}) =>
      _dataSource.sendCleaningCommand(ip, mode: mode);

  @override
  Future<void> sendQueryStatus(String ip) =>
      _dataSource.sendQueryStatus(ip);

  @override
  Future<void> sendTodayExtractionHistory(String ip) =>
      _dataSource.sendTodayExtractionHistory(ip);

  @override
  void dispose() => _dataSource.dispose();
}
