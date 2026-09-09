import 'package:flowhub/domain/entities/index.dart';

abstract class MachineRepository {
  Stream<ExtractionProgress> get progressStream;
  Stream<bool> get connectionStream;
  bool get isConnected;

  Future<void> sendMakeCommand(String ip, String productKey, String orderNo);
  Future<void> sendCancelCommand(String ip, String productKey, String orderNo);
  Future<void> sendCheckAvailability(String ip, String productKey);
  Future<void> sendTimeSyncCommand(String ip);
  Future<void> sendRinsingCommand(String ip);
  Future<void> sendCleaningCommand(String ip, {int mode = 0});
  Future<void> sendQueryStatus(String ip);
  /// Queries the machine's brew history between [startTs] and [endTs] (Unix
  /// ms) — response arrives via [progressStream] as a 0x35 packet.
  Future<void> sendExtractionHistory(String ip, {required int startTs, required int endTs});

  /// Persists [key] as the AES key used to encrypt/decrypt every packet sent
  /// to the Caye machine, replacing whatever was in effect — survives an app
  /// restart. Each physical Caye unit uses its own key, so this is what the
  /// Caye Machine Control screen's Save button applies after swapping to a
  /// different physical machine.
  Future<void> setApiKey(String key);
  /// The AES key currently in effect — whatever was last saved via
  /// [setApiKey] (this session or a previous one), or the built-in default
  /// if none ever was.
  Future<String> get currentApiKey;

  void dispose();
}
