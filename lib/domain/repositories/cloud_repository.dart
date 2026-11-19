import 'package:flowhub/domain/entities/cloud/cloud_identity.dart';
import 'package:flowhub/domain/entities/device/device.dart';

/// The Hub's connection to the Flow Cloud MQTT broker (leader only).
///
/// One connection serves every Flow Cloud feature: order sync, POS orders and
/// Flow App update progress. Each feature subscribes to its own topics.
abstract class CloudRepository {
  /// Connects as [device]'s store and hub, or reconnects when they changed.
  /// 1. Returns `null` (and does not connect) while the device is not
  ///    registered or its store code / device ID is empty.
  /// 2. Otherwise connects and returns the identity it connected as.
  /// No-op when the cloud broker is not configured.
  Future<CloudIdentity?> start(Device device);

  /// The identity of the current session; `null` before [start].
  CloudIdentity? get identity;

  /// Connection state changes (`true` = connected).
  Stream<bool> get connectionStream;

  /// Current connection state.
  bool get isConnected;
}
