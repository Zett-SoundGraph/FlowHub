/// One device of the store and its Flow App version, as FlowManager reports
/// it (`GET /api/v2/rest/device/state`).
class StoreDevice {
  const StoreDevice({
    required this.deviceId,
    required this.deviceName,
    required this.appType,
    required this.deviceStatus,
    required this.currentVersion,
    required this.latestVersionId,
    required this.latestVersion,
    required this.releaseNote,
    required this.updateAvailable,
    required this.updateStatus,
  });

  final String deviceId;
  final String deviceName;

  /// FlowManager app type (e.g. `FLOW_HUB`, `FLOW_KIOSK`).
  final String appType;

  /// Online state FlowManager holds for the device (e.g. `ONLINE`).
  final String deviceStatus;

  /// Installed Flow App version; empty when unknown.
  final String currentVersion;

  /// Version ID of the latest build for this device, used to request it.
  final int? latestVersionId;
  final String latestVersion;
  final String releaseNote;

  /// A newer build than [currentVersion] exists.
  final bool updateAvailable;

  /// Last update request state FlowManager holds (e.g. `QUEUED`,
  /// `COMPLETED`, `FAILED`); empty when there was none.
  final String updateStatus;
}

/// The store's devices plus how many update requests are still open.
class StoreDevices {
  const StoreDevices({required this.pending, required this.devices});

  /// Update requests not finished yet.
  final int pending;
  final List<StoreDevice> devices;

  /// Devices that can be updated now.
  List<StoreDevice> get updatable =>
      devices.where((StoreDevice d) => d.updateAvailable).toList();
}
