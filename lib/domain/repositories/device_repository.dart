import 'package:flowhub/domain/entities/device/device.dart';

/// Signature of the update busy check: `true` = busy (defer the update),
/// `false` = the app may be stopped and updated now.
typedef UpdateBusyCheck = Future<bool> Function();

abstract class DeviceRepository {
  /// Asks FlowUpdater for the device record (`device.getInfo`).
  Future<Device> getDeviceInfo();

  /// Fires when FlowUpdater refreshed the device record (`device.changed`):
  /// call [getDeviceInfo] again.
  Stream<void> get deviceInfoChanges;

  /// Registers who answers FlowUpdater's `update.imminent` (ACK/BUSY);
  /// `null` clears it, which answers ACK. FlowHub-only (not in FlowKioskApp).
  void setUpdateBusyCheck(UpdateBusyCheck? check);
}
