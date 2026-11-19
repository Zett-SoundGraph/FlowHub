import 'package:flowhub/domain/entities/flow_installation/flow_app_update_progress.dart';
import 'package:flowhub/domain/entities/flow_installation/store_device.dart';
import 'package:flowhub/domain/entities/flow_installation/update_request_result.dart';

/// Flow Installation: installing new Flow App versions on the store's
/// devices from FlowHub (FlowManager REST + the cloud MQTT broker).
abstract class FlowInstallationRepository {
  /// The store's devices and their versions. [storeId] is FlowManager's
  /// store ID (the device record's `storeId`).
  Future<StoreDevices> getStoreDevices(String storeId);

  /// Asks FlowManager to update each device in [deviceIds] to its latest
  /// build; FlowManager sends the command to each device's FlowUpdater.
  Future<List<UpdateRequestResult>> requestUpdates(List<String> deviceIds);

  /// Progress reports of [storeId]'s updates; subscribes the store's return
  /// topic on the cloud broker.
  Stream<FlowAppUpdateProgress> watchProgress(String storeId);

  /// Fires when the available Flow App versions may have changed, so the
  /// caller re-reads [getStoreDevices]:
  /// 1. a `flow/system/version` message (retained, so also right after each
  ///    subscribe);
  /// 2. each (re)connection to the cloud broker, for a release published
  ///    while the Hub was offline.
  Stream<void> get versionNotices;
}
