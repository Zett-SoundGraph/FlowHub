import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flowhub/core/constants/flowhub_identity.dart';
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/usecases/get_caye_api_key_usecase.dart';
import 'package:flowhub/domain/usecases/get_machine_connection_snapshot_usecase.dart';
import 'package:flowhub/domain/usecases/observe_machine_connection_usecase.dart';
import 'package:flowhub/domain/usecases/observe_machine_progress_usecase.dart';
import 'package:flowhub/domain/usecases/publish_follower_sync_usecase.dart';
import 'package:flowhub/domain/usecases/send_cancel_command_usecase.dart';
import 'package:flowhub/domain/usecases/send_cleaning_command_usecase.dart';
import 'package:flowhub/domain/usecases/send_extraction_history_usecase.dart';
import 'package:flowhub/domain/usecases/send_query_status_usecase.dart';
import 'package:flowhub/domain/usecases/send_rinsing_command_usecase.dart';
import 'package:flowhub/domain/usecases/send_time_sync_usecase.dart';
import 'package:flowhub/domain/usecases/set_caye_api_key_usecase.dart';

import 'caye_management_state.dart';

/// The 5 fields useful for post-test brew-quality analysis, pulled out of a
/// 0x35 `beverageList[]` entry (see [CayeManagementCubit.queryExtractionHistory])
/// — the machine's response carries several more fields (ts, deviceSn,
/// categoryId, productName, cups, endState, soyura, coffeeTemp, price), left
/// out here since only these 5 are needed right now.
typedef CayeExtractionRecord = ({
  double makeTime,
  double powderWeight,
  double grindTime,
  double extractTime,
  double targetExtractTime,
});

/// [timedOut] distinguishes "the machine responded with zero records for
/// this range" from "no response arrived at all within the timeout" — both
/// look like an empty [records] list, but call for a different message to
/// the operator (widen the time range vs. check the machine/connection).
typedef CayeExtractionQueryResult = ({
  List<CayeExtractionRecord> records,
  bool timedOut,
});

@injectable
class CayeManagementCubit extends Cubit<CayeManagementState> {
  final ObserveMachineConnectionUseCase _observeMachineConnection;
  final GetMachineConnectionSnapshotUseCase _getMachineConnectionSnapshot;
  final SendCancelCommandUseCase _sendCancelCommand;
  final SendRinsingCommandUseCase _sendRinsingCommand;
  final SendCleaningCommandUseCase _sendCleaningCommand;
  final SendQueryStatusUseCase _sendQueryStatus;
  final SendTimeSyncUseCase _sendTimeSync;
  final SendExtractionHistoryUseCase _sendExtractionHistory;
  final ObserveMachineProgressUseCase _observeMachineProgress;
  final PublishFollowerSyncUseCase _publishFollowerSync;
  final GetCayeApiKeyUseCase _getCayeApiKey;
  final SetCayeApiKeyUseCase _setCayeApiKey;

  StreamSubscription<bool>? _connectionSubscription;
  int _followerSyncSeq = 0;

  CayeManagementCubit({
    required ObserveMachineConnectionUseCase observeMachineConnection,
    required GetMachineConnectionSnapshotUseCase getMachineConnectionSnapshot,
    required SendCancelCommandUseCase sendCancelCommand,
    required SendRinsingCommandUseCase sendRinsingCommand,
    required SendCleaningCommandUseCase sendCleaningCommand,
    required SendQueryStatusUseCase sendQueryStatus,
    required SendTimeSyncUseCase sendTimeSync,
    required SendExtractionHistoryUseCase sendExtractionHistory,
    required ObserveMachineProgressUseCase observeMachineProgress,
    required PublishFollowerSyncUseCase publishFollowerSync,
    required GetCayeApiKeyUseCase getCayeApiKey,
    required SetCayeApiKeyUseCase setCayeApiKey,
  })  : _observeMachineConnection = observeMachineConnection,
        _getMachineConnectionSnapshot = getMachineConnectionSnapshot,
        _sendCancelCommand = sendCancelCommand,
        _sendRinsingCommand = sendRinsingCommand,
        _sendCleaningCommand = sendCleaningCommand,
        _sendQueryStatus = sendQueryStatus,
        _sendTimeSync = sendTimeSync,
        _sendExtractionHistory = sendExtractionHistory,
        _observeMachineProgress = observeMachineProgress,
        _publishFollowerSync = publishFollowerSync,
        _getCayeApiKey = getCayeApiKey,
        _setCayeApiKey = setCayeApiKey,
        super(const CayeManagementState()) {
    // Seed from the CURRENT connection state first — the connection stream
    // is a plain broadcast stream that only replays FUTURE transitions, so a
    // cubit created after the machine already connected (e.g. reopening this
    // screen) would otherwise show OFF forever despite a real, live
    // connection, since no new transition may ever fire again.
    emit(state.copyWith(isConnected: _getMachineConnectionSnapshot()));
    _connectionSubscription = _observeMachineConnection().listen((connected) {
      emit(state.copyWith(isConnected: connected));
    });
    // Local read, regardless of role — mirrors how isConnected above is also
    // seeded from this device's own local state. Unlike a write (which must
    // reach whichever device is ACTUALLY leader — see saveApiKey below), the
    // key just displayed here isn't required to be the real active one on a
    // follower; an operator saving a new key always does so at the device
    // they're physically using.
    unawaited(_getCayeApiKey().then((key) {
      if (!isClosed) emit(state.copyWith(apiKey: key));
    }));
  }

  /// On a follower, publishes a request for the (always-alive) leader
  /// FlowHubCubit to dispatch instead — only the leader ever touches the real
  /// Caye machine socket. See FlowHubCubit._handleFollowerSyncRequest.
  void _requestSync(String syncType, Map<String, dynamic> params) {
    _followerSyncSeq++;
    unawaited(
      _publishFollowerSync(
        FollowerSyncRequest(
          sync: syncType,
          eventId: 'caye-${DateTime.now().millisecondsSinceEpoch}-$_followerSyncSeq',
          version: _followerSyncSeq,
          params: params,
        ),
      ),
    );
  }

  Future<void> sendCancelCommand(String ip, String productKey, String orderNo) async {
    await _sendCancelCommand((ip: ip, productKey: productKey, orderNo: orderNo));
  }

  Future<void> sendRinsingCommand(String ip) {
    if (FlowHubIdentity.role == FlowHubRole.follower) {
      _requestSync('caye_rinsing', const {});
      return Future.value();
    }
    return _sendRinsingCommand(ip);
  }

  Future<void> sendCleaningCommand(String ip, {int mode = 0}) async {
    if (FlowHubIdentity.role == FlowHubRole.follower) {
      _requestSync('caye_cleaning', {'mode': mode});
      return;
    }
    await _sendCleaningCommand((ip: ip, mode: mode));
  }

  Future<void> sendQueryStatus(String ip) => _sendQueryStatus(ip);

  Future<void> sendTimeSync(String ip) {
    if (FlowHubIdentity.role == FlowHubRole.follower) {
      _requestSync('caye_sync', const {});
      return Future.value();
    }
    return _sendTimeSync(ip);
  }

  /// No real reboot use case exists yet (leader-side is a no-op too, see
  /// caye_management_screen.dart) — deferred until a confirmed protocol
  /// value is found; this just keeps the follower path symmetric with the
  /// other 3 commands for when one is added.
  void requestReboot() {
    if (FlowHubIdentity.role == FlowHubRole.follower) {
      _requestSync('caye_reboot', const {});
    }
  }

  /// Sends a 0x35 extraction-history query for [startTs]..[endTs] (Unix ms,
  /// required — an empty body is rejected per the confirmed protocol spec)
  /// and waits for the machine's response on the shared progress stream,
  /// returning just the 5 fields useful for post-test analysis (see
  /// [CayeExtractionRecord]). [CayeExtractionQueryResult.timedOut] is true
  /// if no response arrived within [timeout] at all — as opposed to a real
  /// response that just happened to carry zero records for this range,
  /// which also yields an empty list but with timedOut false. Both cases
  /// look identical from the machine's own wire format, so the log's
  /// `[Sent] 0x35` / `[Received] 0x35` lines are the only way to confirm
  /// which one actually happened if this is surprising.
  ///
  /// Only meaningful on the leader, which owns the real Caye socket — a
  /// follower's call resolves to an empty, non-timed-out result immediately
  /// rather than forwarding the request, since the response would land on
  /// the LEADER's own progress stream with no relay back to whichever
  /// follower asked. This is a manual debug tool (Caye Machine Control
  /// screen's test button), not a production data path, so that asymmetry
  /// is acceptable for now — flag if a follower needs this reachable too.
  Future<CayeExtractionQueryResult> queryExtractionHistory(
    String ip, {
    required int startTs,
    required int endTs,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (FlowHubIdentity.role == FlowHubRole.follower) {
      return (records: const <CayeExtractionRecord>[], timedOut: false);
    }

    final completer = Completer<List<CayeExtractionRecord>>();
    late final StreamSubscription<ExtractionProgress> subscription;
    subscription = _observeMachineProgress().listen((progress) {
      if (progress.code == 0x35 && !completer.isCompleted) {
        completer.complete(_parseBeverageList(progress.data));
      }
    });

    await _sendExtractionHistory((ip: ip, startTs: startTs, endTs: endTs));

    var timedOut = false;
    final records = await completer.future.timeout(
      timeout,
      onTimeout: () {
        timedOut = true;
        return const <CayeExtractionRecord>[];
      },
    );
    await subscription.cancel();
    return (records: records, timedOut: timedOut);
  }

  List<CayeExtractionRecord> _parseBeverageList(Map<String, dynamic> data) {
    final list = data['beverageList'];
    if (list is! List) return const [];
    return list.whereType<Map<String, dynamic>>().map((e) {
      double asDouble(String key) => (e[key] as num?)?.toDouble() ?? 0.0;
      return (
        makeTime: asDouble('makeTime'),
        powderWeight: asDouble('powderWeight'),
        grindTime: asDouble('grindTime'),
        extractTime: asDouble('extractTime'),
        targetExtractTime: asDouble('targetExtractTime'),
      );
    }).toList();
  }

  /// Saves [key] as the Caye machine's AES key (Caye Machine Control
  /// screen's Save button) — only the leader's own [CayeMachineDataSource]
  /// instance ever holds the real socket to the physical machine (see the
  /// class doc comment on isCayeConnected in device_management_screen.dart),
  /// so a follower forwards this to the leader instead of persisting it
  /// locally, same as every other real Caye command above.
  Future<void> saveApiKey(String key) async {
    if (FlowHubIdentity.role == FlowHubRole.follower) {
      _requestSync('caye_set_api_key', {'apiKey': key});
      emit(state.copyWith(apiKey: key));
      return;
    }
    await _setCayeApiKey(key);
    emit(state.copyWith(apiKey: key));
  }

  @override
  Future<void> close() async {
    await _connectionSubscription?.cancel();
    return super.close();
  }
}
