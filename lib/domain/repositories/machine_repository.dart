import 'package:kds/domain/entities/index.dart';

abstract class MachineRepository {
  Stream<ExtractionProgress> get progressStream;
  Stream<bool> get connectionStream;

  Future<void> sendMakeCommand(String ip, String productKey, String orderNo);
  Future<void> sendCancelCommand(String ip, String productKey, String orderNo);
  Future<void> sendCheckAvailability(String ip, String productKey);
  Future<void> sendTimeSyncCommand(String ip);
  Future<void> sendRinsingCommand(String ip);
  Future<void> sendCleaningCommand(String ip, {int mode = 0});
  Future<void> sendQueryStatus(String ip);
  Future<void> sendTodayExtractionHistory(String ip);
  void dispose();
}
