import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/data/sources/remote/caye_machine_data_source.dart';
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/repositories/machine_repository.dart';

@Singleton(as: MachineRepository)
class MachineRepositoryImpl implements MachineRepository {
  final ICayeMachineDataSource _dataSource;

  const MachineRepositoryImpl(this._dataSource);

  @override
  Stream<ExtractionProgress> get progressStream => _dataSource.progressStream;

  @override
  Stream<bool> get connectionStream => _dataSource.connectionStream;

  @override
  bool get isConnected => _dataSource.isConnected;

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
  Future<void> sendExtractionHistory(String ip, {required int startTs, required int endTs}) =>
      _dataSource.sendExtractionHistory(ip, startTs: startTs, endTs: endTs);

  @override
  Future<void> setApiKey(String key) => _dataSource.setApiKey(key);

  @override
  Future<String> get currentApiKey => _dataSource.currentApiKey;

  @override
  void dispose() => _dataSource.dispose();
}
