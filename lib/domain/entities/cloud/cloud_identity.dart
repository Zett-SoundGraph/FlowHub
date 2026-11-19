import 'package:flowhub/domain/entities/device/device.dart';

/// Who this Hub is on the Flow Cloud topics `flow/hub/{storeId}/{hubId}/...`.
class CloudIdentity {
  const CloudIdentity({required this.storeId, required this.hubId});

  /// Store code (FlowManager `store_code`, e.g. `STORE-001`).
  final String storeId;

  /// Hub device ID (CloneID, e.g. `YFTC_0000001`).
  final String hubId;

  /// Builds the identity from the FlowUpdater device record.
  /// 1. Returns `null` while the device is not registered to a store.
  /// 2. Returns `null` while the store code or device ID is still empty.
  static CloudIdentity? fromDevice(Device device) {
    if (!device.isRegistered) return null;
    if (device.storeCode.isEmpty || device.deviceId.isEmpty) return null;
    return CloudIdentity(storeId: device.storeCode, hubId: device.deviceId);
  }

  /// Topic prefix every Hub-scoped Flow Cloud topic starts with.
  String get hubTopicPrefix => 'flow/hub/$storeId/$hubId';

  @override
  bool operator ==(Object other) =>
      other is CloudIdentity &&
      other.storeId == storeId &&
      other.hubId == hubId;

  @override
  int get hashCode => Object.hash(storeId, hubId);

  @override
  String toString() => 'CloudIdentity($storeId/$hubId)';
}
