import 'dart:async';
import 'dart:io';

import 'package:flow_updater_sdk/flow_updater_sdk.dart';
import 'package:flowhub/core/utils/log.dart';
import 'package:flutter/foundation.dart';

/// Answers FlowUpdater's "about to update you" question: `true` when the app
/// is busy and the update must wait (BUSY), `false` when it may proceed (ACK).
/// The checker may prepare for the restart (e.g. persist state) before it
/// returns `false`.
typedef UpdateBusyChecker = Future<bool> Function();

/// FlowHub's link to FlowUpdater (Android only), over `flow_updater_sdk`.
/// Mirrors FlowKioskApp's `FlowUpdaterService`; the only addition is
/// [setUpdateBusyChecker], since FlowHub must not restart mid-order.
///
/// One instance for the whole app: a second [FlowUpdaterClient] would take
/// over the callbacks of the first. On other platforms every call is a no-op.
class FlowUpdaterService {
  FlowUpdaterService({@visibleForTesting bool? isSupported})
    : isSupported = isSupported ?? (!kIsWeb && Platform.isAndroid);

  static const String _tag = 'FlowUpdaterService';

  /// How long [getDeviceInfo] waits for the handshake before asking.
  static const Duration _connectWait = Duration(seconds: 20);

  final bool isSupported;
  FlowUpdaterClient? _client;
  UpdateBusyChecker? _busyChecker;
  final StreamController<void> _deviceInfoChanges =
      StreamController<void>.broadcast();

  /// Fires on `device.changed`: FlowUpdater refreshed its device record, so
  /// [getDeviceInfo] would now answer something newer.
  Stream<void> get deviceInfoChanges => _deviceInfoChanges.stream;

  /// Creates the client and starts connecting. Completes with the first
  /// handshake; the SDK keeps reconnecting in the background afterwards, so
  /// callers should not await this before `runApp`.
  Future<void> connect() async {
    if (!isSupported || _client != null) {
      return;
    }
    final FlowUpdaterClient client = FlowUpdaterClient(
      onUpdateImminent: _onUpdateImminent, // answers "I'm about to update you"
      onDeviceInfoChanged: handleDeviceInfoChanged, // device.changed
    );
    _client = client;
    client.connectionStates.listen(
      (UpdaterConnectionState state) => Log.i(_tag, 'state: ${state.wire}'),
    );
    try {
      final IpcResult<WelcomePayload> result = await client.connect();
      if (result.isOk) {
        final WelcomePayload welcome = result.value!;
        Log.i(
          _tag,
          'Connected to ${welcome.updaterPackage} '
          '${welcome.updaterVersionName}',
        );
      } else {
        Log.w(
          _tag,
          'Not connected yet: ${result.error!.code.wire} '
          '${result.error!.message}',
        );
      }
    } catch (e, st) {
      Log.e(_tag, 'connect failed: $e\n$st');
    }
  }

  /// Tells FlowUpdater the app works, for its `IPC_READY` health check after
  /// an update. Safe before the connection is up; the SDK resends it after
  /// every reconnect.
  Future<void> markReady() async {
    final FlowUpdaterClient? client = _client;
    if (client == null) {
      return;
    }
    try {
      await client.markReady();
      Log.i(_tag, 'markReady()');
    } catch (e, st) {
      Log.e(_tag, 'markReady failed: $e\n$st');
    }
  }

  /// The device record (`device.getInfo`). Waits up to
  /// [_connectWait] for the handshake first, since the app may ask right
  /// after startup. IPC failures come back in [IpcResult.error].
  Future<IpcResult<DeviceInfo>> getDeviceInfo() async {
    final FlowUpdaterClient? client = _client;
    if (client == null) {
      return const IpcResult<DeviceInfo>.failed(
        IpcErrorPayload(
          IpcErrorCode.notConnected,
          'FlowUpdater is not available on this platform',
        ),
      );
    }
    await _awaitConnected(client);
    final IpcResult<DeviceInfo> result = await client.getDeviceInfo();
    if (result.isOk) {
      Log.i(_tag, 'device.getInfo: ${result.value!.deviceId}');
    } else {
      Log.w(
        _tag,
        'device.getInfo: ${result.error!.code.wire} '
        '${result.error!.message}',
      );
    }
    return result;
  }

  /// Registers who decides ACK/BUSY on `update.imminent`; `null` clears it.
  /// With no checker the answer is ACK, as in FlowKioskApp.
  void setUpdateBusyChecker(UpdateBusyChecker? checker) {
    _busyChecker = checker;
    Log.i(_tag, 'busy checker ${checker == null ? 'cleared' : 'set'}');
  }

  Future<void> _awaitConnected(FlowUpdaterClient client) async {
    if (client.connectionState == UpdaterConnectionState.connected) {
      return;
    }
    try {
      await client.connectionStates
          .firstWhere(
            (UpdaterConnectionState s) => s == UpdaterConnectionState.connected,
          )
          .timeout(_connectWait);
    } on TimeoutException {
      // Ask anyway: the SDK answers NOT_CONNECTED.
    } on StateError {
      // connectionStates closed (client disposed).
    }
  }

  /// The `onDeviceInfoChanged` callback the SDK calls on `device.changed`.
  @visibleForTesting
  void handleDeviceInfoChanged() {
    Log.i(_tag, 'device.changed');
    _deviceInfoChanges.add(null);
  }

  /// 1. No checker registered → ACK (follower, or before the cubit starts).
  /// 2. Ask the checker → BUSY when it reports work in progress, else ACK.
  /// 3. Checker throws → BUSY: an unknown state must not cut a live order.
  ///    FlowUpdater retries later (defer), so this only delays the update.
  Future<QuiesceDecision> _onUpdateImminent(
    UpdateImminentPayload payload,
  ) async {
    final String target =
        '${payload.targetVersionCode} (session ${payload.sessionId})';
    final UpdateBusyChecker? checker = _busyChecker;
    if (checker == null) {
      Log.i(_tag, 'update.imminent → $target: ACK (no busy checker)');
      return QuiesceDecision.ack;
    }
    try {
      final bool busy = await checker();
      Log.i(_tag, 'update.imminent → $target: ${busy ? 'BUSY' : 'ACK'}');
      return busy ? QuiesceDecision.busy : QuiesceDecision.ack;
    } catch (e, st) {
      Log.e(_tag, 'update.imminent → $target: BUSY (checker failed: $e)\n$st');
      return QuiesceDecision.busy;
    }
  }
}
