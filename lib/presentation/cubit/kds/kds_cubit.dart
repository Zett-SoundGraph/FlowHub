import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/core/constants/flowhub_identity.dart';
import 'package:flowhub/core/constants/network.dart';
import 'package:flowhub/core/utils/log.dart';
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/enums/order_status.dart';
import 'package:flowhub/domain/enums/production_stage.dart';
import 'package:flowhub/domain/usecases/append_order_history_usecase.dart';
import 'package:flowhub/domain/usecases/check_machine_availability_usecase.dart';
import 'package:flowhub/domain/usecases/complete_cooking_usecase.dart';
import 'package:flowhub/domain/usecases/complete_pickup_usecase.dart';
import 'package:flowhub/domain/usecases/connect_order_socket_usecase.dart';
import 'package:flowhub/domain/usecases/disconnect_order_socket_usecase.dart';
import 'package:flowhub/domain/usecases/dispose_machine_usecase.dart';
import 'package:flowhub/domain/usecases/dispose_printer_usecase.dart';
import 'package:flowhub/domain/usecases/get_menu_info_by_sku_usecase.dart';
import 'package:flowhub/domain/repositories/menu_repository.dart'
    show ProductionType, RecipeDispenser, RecipeTiming, RecipeTimingClassifier;
import 'package:flowhub/domain/usecases/get_menu_ingredients_usecase.dart';
import 'package:flowhub/domain/usecases/get_menu_info_usecase.dart';
import 'package:flowhub/domain/usecases/get_machine_connection_snapshot_usecase.dart';
import 'package:flowhub/domain/usecases/get_recipe_dispenser_usecase.dart';
import 'package:flowhub/domain/usecases/get_recipe_image_usecase.dart';
import 'package:flowhub/domain/usecases/get_label_options_usecase.dart';
import 'package:flowhub/domain/usecases/get_recipe_ingredient_labels_usecase.dart';
import 'package:flowhub/domain/usecases/get_recipe_popup_ingredients_usecase.dart';
import 'package:flowhub/domain/usecases/get_recipe_timing_usecase.dart';
import 'package:flowhub/domain/usecases/get_recipe_version_usecase.dart';
import 'package:flowhub/domain/usecases/observe_machine_connection_usecase.dart';
import 'package:flowhub/domain/usecases/observe_barcode_scan_usecase.dart';
import 'package:flowhub/domain/usecases/observe_calibration_status_usecase.dart';
import 'package:flowhub/domain/usecases/observe_follower_sync_request_usecase.dart';
import 'package:flowhub/domain/usecases/observe_kiosk_order_usecase.dart';
import 'package:flowhub/domain/usecases/observe_leader_update_usecase.dart';
import 'package:flowhub/domain/usecases/observe_machine_progress_usecase.dart';
import 'package:flowhub/domain/usecases/observe_order_connection_usecase.dart';
import 'package:flowhub/domain/usecases/observe_pickup_complete_usecase.dart';
import 'package:flowhub/domain/usecases/observe_printer_connection_usecase.dart';
import 'package:flowhub/domain/usecases/observe_printer_status_usecase.dart';
import 'package:flowhub/domain/usecases/observe_qr_complete_usecase.dart';
import 'package:flowhub/domain/usecases/print_label_usecase.dart';
import 'package:flowhub/domain/usecases/print_receipt_usecase.dart';
import 'package:flowhub/domain/usecases/publish_board_update_usecase.dart';
import 'package:flowhub/domain/usecases/publish_caye_cleaning_usecase.dart';
import 'package:flowhub/domain/usecases/publish_caye_fault_usecase.dart';
import 'package:flowhub/domain/usecases/publish_caye_rinsing_usecase.dart';
import 'package:flowhub/domain/usecases/publish_caye_status_usecase.dart';
import 'package:flowhub/domain/usecases/publish_follower_sync_usecase.dart';
import 'package:flowhub/domain/usecases/publish_kiosk_update_usecase.dart';
import 'package:flowhub/domain/usecases/publish_leader_update_usecase.dart';
import 'package:flowhub/domain/usecases/reconnect_printer_usecase.dart';
import 'package:flowhub/domain/usecases/resolve_menu_options_usecase.dart';
import 'package:flowhub/domain/usecases/send_cancel_command_usecase.dart';
import 'package:flowhub/domain/usecases/send_cleaning_command_usecase.dart';
import 'package:flowhub/domain/usecases/send_make_command_usecase.dart';
import 'package:flowhub/domain/usecases/send_query_status_usecase.dart';
import 'package:flowhub/domain/usecases/send_rinsing_command_usecase.dart';
import 'package:flowhub/domain/usecases/send_time_sync_usecase.dart';
import 'package:flowhub/domain/usecases/set_awaiting_detach_usecase.dart';
import 'package:flowhub/domain/usecases/set_caye_api_key_usecase.dart';
import 'package:flowhub/domain/usecases/start_calibration_usecase.dart';
import 'package:flowhub/domain/usecases/sync_recipe_data_usecase.dart';
import 'package:flowhub/presentation/enums/order_tab.dart';
import 'package:flowhub/presentation/widgets/order_label_widget.dart';
import 'package:screenshot/screenshot.dart';

import 'kds_state.dart';

part 'kds_cubit_barcode.dart';
part 'kds_cubit_manufacturing.dart';
part 'kds_cubit_printer.dart';

// Dummy orderNo shared by every queue item startConsecutiveShotTest() adds —
// never matches a real Order, so _updateSubItemByIndex silently no-ops for
// these; also used by _applyProgressToSubItem (kds_cubit_manufacturing.dart)
// to recognize a completion as belonging to the shot test, for the
// shotTestCompleted/shotTestFinishedAt bookkeeping.
const _shotTestOrderNo = '__shot_test__';

@injectable
class KdsCubit extends Cubit<KdsState> {
  final CompleteCookingUseCase _completeCooking;
  final CompletePickupUseCase _completePickup;
  final ConnectOrderSocketUseCase _connectOrderSocket;
  final DisconnectOrderSocketUseCase _disconnectOrderSocket;
  final ObserveOrderConnectionUseCase _observeOrderConnection;
  final ObserveBarcodeScanUseCase _observeBarcodeScan;
  final ObserveQrCompleteUseCase _observeQrComplete;
  final ObservePickupCompleteUseCase _observePickupComplete;
  final ObserveKioskOrderUseCase _observeKioskOrder;
  final ObserveMachineProgressUseCase _observeMachineProgress;
  final CheckMachineAvailabilityUseCase _checkMachineAvailability;
  // Sent alongside _checkMachineAvailability (0x23) right before a brew
  // attempt — 0x23 answers "can THIS recipe be made right now", 0x31
  // answers "what's the machine's overall state" (cleaning/rinsing
  // wait-or-progress, fault presence + list). Reception-side is
  // observational only for now (see CayeMachineDataSource._handleIncoming's
  // 0x31 branch) — the real response's field shape hasn't been seen yet.
  final SendQueryStatusUseCase _sendQueryStatus;
  final SendMakeCommandUseCase _sendMakeCommand;
  final SendCancelCommandUseCase _sendCancelCommand;
  final ObservePrinterStatusUseCase _observePrinterStatus;
  final ObservePrinterConnectionUseCase _observePrinterConnection;
  final ObserveMachineConnectionUseCase _observeMachineConnection;
  final GetMachineConnectionSnapshotUseCase _getMachineConnectionSnapshot;
  final PrintLabelUseCase _printLabel;
  final PrintReceiptUseCase _printReceipt;
  final ReconnectPrinterUseCase _reconnectPrinter;
  final SetAwaitingDetachUseCase _setAwaitingDetach;
  final AppendOrderHistoryUseCase _appendOrderHistory;
  final StartCalibrationUseCase _startCalibration;
  final SyncRecipeDataUseCase _syncRecipeData;
  final GetMenuInfoUseCase _getMenuInfo;
  final GetMenuInfoBySkuUseCase _getMenuInfoBySku;
  final GetRecipeTimingUseCase _getRecipeTiming;
  final GetRecipeDispenserUseCase _getRecipeDispenser;
  final GetRecipeImageUseCase _getRecipeImage;
  final GetRecipeVersionUseCase _getRecipeVersion;
  final GetRecipeIngredientLabelsUseCase _getRecipeIngredientLabels;
  final GetRecipePopupIngredientsUseCase _getRecipePopupIngredients;
  final GetLabelOptionsUseCase _getLabelOptions;
  final GetMenuIngredientsUseCase _getMenuIngredients;
  final ResolveMenuOptionsUseCase _resolveMenuOptions;
  final ObserveCalibrationStatusUseCase _observeCalibrationStatus;
  final DisposeMachineUseCase _disposeMachine;
  final DisposePrinterUseCase _disposePrinter;

  // Leader/follower sync (see FlowHubIdentity) — leader broadcasts full
  // state on every change and executes whatever followers ask for; a
  // follower has none of the subscriptions above at all, and instead just
  // mirrors whatever the leader broadcasts.
  final ObserveLeaderUpdateUseCase _observeLeaderUpdate;
  final ObserveFollowerSyncRequestUseCase _observeFollowerSyncRequest;
  final PublishLeaderUpdateUseCase _publishLeaderUpdate;
  final PublishFollowerSyncUseCase _publishFollowerSync;
  final PublishBoardUpdateUseCase _publishBoardUpdate;
  final PublishKioskUpdateUseCase _publishKioskUpdate;
  // Caye machine diagnostics (0x30/0x31/0x12/0x03) — published on their own
  // dedicated topics as soon as they're observed, independent of whether a
  // brew task is currently queued (see _handleMachineProgress's early
  // branches for these codes).
  final PublishCayeFaultUseCase _publishCayeFault;
  final PublishCayeStatusUseCase _publishCayeStatus;
  final PublishCayeRinsingUseCase _publishCayeRinsing;
  final PublishCayeCleaningUseCase _publishCayeCleaning;
  // Caye commands a follower might ask for — kept here (not just in
  // CayeManagementCubit) because this cubit is the one instance that's
  // always alive for the app's lifetime, so a follower's request can't be
  // missed just because the leader's own Caye Machine Control screen isn't
  // currently open.
  final SendRinsingCommandUseCase _sendRinsingCommand;
  final SendCleaningCommandUseCase _sendCleaningCommand;
  final SendTimeSyncUseCase _sendTimeSync;
  final SetCayeApiKeyUseCase _setCayeApiKey;

  final ScreenshotController _screenshotController = ScreenshotController();

  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<String>? _barcodeScanSubscription;
  StreamSubscription<String>? _qrCompleteSubscription;
  StreamSubscription<({String orderNo, String menuName})>?
  _pickupCompleteSubscription;
  StreamSubscription<Order>? _kioskOrderSubscription;
  StreamSubscription<ExtractionProgress>? _machineProgressSubscription;
  StreamSubscription<bool>? _printerStatusSubscription;
  StreamSubscription<bool>? _printerConnectionSubscription;
  StreamSubscription<bool>? _cayeConnectionSubscription;
  StreamSubscription<String>? _calibrationStatusSubscription;
  StreamSubscription<LeaderUpdateMessage>? _leaderUpdateSubscription;
  StreamSubscription<FollowerSyncRequest>? _followerSyncRequestSubscription;

  int _leaderUpdateVersion = 0;
  int _lastAppliedLeaderVersion = -1;
  int _followerSyncSeq = 0;

  // Throttles [_broadcastLeaderUpdate] so a burst of rapid state changes
  // (e.g. the printer's paper sensor flipping ATTACHED/DETACHED several
  // times a second while a print job feeds through) collapses into one
  // publish per [_broadcastMinInterval] instead of one per emit() — real
  // devices were seen receiving nothing but empty payloads on
  // beta/flowhub/leader/update once the leader published several times a
  // second, consistent with the broker's flood/flapping protection kicking
  // in (see the "persistent session" comment in mqtt_data_source.dart).
  static const _broadcastMinInterval = Duration(milliseconds: 500);
  DateTime? _lastBroadcastAt;
  Timer? _pendingBroadcastTimer;

  final List<ManufacturingQueueItem> _manufacturingQueue = [];
  bool _isMachineBusy = false;
  bool _acceptMachinePackets = false;
  bool _isWaitingForCleanStart = false;
  bool _isRetrying = false;
  Timer? _availabilityTimer;

  final List<ManufacturingQueueItem> _pendingPrintJobs = [];
  bool _isPrinting = false;

  /// Print jobs that have been sent to the printer and are waiting for the
  /// physical DETACHED signal (label peeled off) before the order enters
  /// BREW. [sawAttached] starts false and only flips true once a real
  /// ATTACHED tick is observed for this job — a DETACHED tick before that
  /// doesn't mean "peeled off", it just means the label hasn't physically
  /// reached the sensor yet (print/cut still in flight), so it must be
  /// ignored rather than resolving the job early. See [_handlePrinterStatus].
  final List<({String orderNo, int subItemIndex, bool sawAttached})> _awaitingDetachQueue = [];

  /// Recomputes every active estimated-time gauge phase (see SubItem's
  /// phase-tracking fields) and re-emits — the Caye machine's own real
  /// telemetry (0x24 packets) drives its own items directly instead, this
  /// timer only interpolates phases that have no real signal to follow
  /// (Nudof, which has no data channel at all).
  static const _gaugeTickInterval = Duration(milliseconds: 500);
  Timer? _gaugeTickTimer;

  KdsCubit({
    required CompleteCookingUseCase completeCooking,
    required CompletePickupUseCase completePickup,
    required ConnectOrderSocketUseCase connectOrderSocket,
    required DisconnectOrderSocketUseCase disconnectOrderSocket,
    required ObserveOrderConnectionUseCase observeOrderConnection,
    required ObserveBarcodeScanUseCase observeBarcodeScan,
    required ObserveQrCompleteUseCase observeQrComplete,
    required ObservePickupCompleteUseCase observePickupComplete,
    required ObserveKioskOrderUseCase observeKioskOrder,
    required ObserveMachineProgressUseCase observeMachineProgress,
    required CheckMachineAvailabilityUseCase checkMachineAvailability,
    required SendQueryStatusUseCase sendQueryStatus,
    required SendMakeCommandUseCase sendMakeCommand,
    required SendCancelCommandUseCase sendCancelCommand,
    required ObservePrinterStatusUseCase observePrinterStatus,
    required ObservePrinterConnectionUseCase observePrinterConnection,
    required ObserveMachineConnectionUseCase observeMachineConnection,
    required GetMachineConnectionSnapshotUseCase getMachineConnectionSnapshot,
    required PrintLabelUseCase printLabel,
    required PrintReceiptUseCase printReceipt,
    required ReconnectPrinterUseCase reconnectPrinter,
    required SetAwaitingDetachUseCase setAwaitingDetach,
    required AppendOrderHistoryUseCase appendOrderHistory,
    required StartCalibrationUseCase startCalibration,
    required SyncRecipeDataUseCase syncRecipeData,
    required GetMenuInfoUseCase getMenuInfo,
    required GetMenuInfoBySkuUseCase getMenuInfoBySku,
    required GetRecipeTimingUseCase getRecipeTiming,
    required GetRecipeDispenserUseCase getRecipeDispenser,
    required GetRecipeImageUseCase getRecipeImage,
    required GetRecipeVersionUseCase getRecipeVersion,
    required GetRecipeIngredientLabelsUseCase getRecipeIngredientLabels,
    required GetRecipePopupIngredientsUseCase getRecipePopupIngredients,
    required GetLabelOptionsUseCase getLabelOptions,
    required GetMenuIngredientsUseCase getMenuIngredients,
    required ResolveMenuOptionsUseCase resolveMenuOptions,
    required ObserveCalibrationStatusUseCase observeCalibrationStatus,
    required DisposeMachineUseCase disposeMachine,
    required DisposePrinterUseCase disposePrinter,
    required ObserveLeaderUpdateUseCase observeLeaderUpdate,
    required ObserveFollowerSyncRequestUseCase observeFollowerSyncRequest,
    required PublishLeaderUpdateUseCase publishLeaderUpdate,
    required PublishFollowerSyncUseCase publishFollowerSync,
    required PublishBoardUpdateUseCase publishBoardUpdate,
    required PublishKioskUpdateUseCase publishKioskUpdate,
    required PublishCayeFaultUseCase publishCayeFault,
    required PublishCayeStatusUseCase publishCayeStatus,
    required PublishCayeRinsingUseCase publishCayeRinsing,
    required PublishCayeCleaningUseCase publishCayeCleaning,
    required SendRinsingCommandUseCase sendRinsingCommand,
    required SendCleaningCommandUseCase sendCleaningCommand,
    required SendTimeSyncUseCase sendTimeSync,
    required SetCayeApiKeyUseCase setCayeApiKey,
  }) : _completeCooking = completeCooking,
       _completePickup = completePickup,
       _connectOrderSocket = connectOrderSocket,
       _disconnectOrderSocket = disconnectOrderSocket,
       _observeOrderConnection = observeOrderConnection,
       _observeBarcodeScan = observeBarcodeScan,
       _observeQrComplete = observeQrComplete,
       _observePickupComplete = observePickupComplete,
       _observeKioskOrder = observeKioskOrder,
       _observeMachineProgress = observeMachineProgress,
       _checkMachineAvailability = checkMachineAvailability,
       _sendQueryStatus = sendQueryStatus,
       _sendMakeCommand = sendMakeCommand,
       _sendCancelCommand = sendCancelCommand,
       _observePrinterStatus = observePrinterStatus,
       _observePrinterConnection = observePrinterConnection,
       _observeMachineConnection = observeMachineConnection,
       _getMachineConnectionSnapshot = getMachineConnectionSnapshot,
       _printLabel = printLabel,
       _printReceipt = printReceipt,
       _reconnectPrinter = reconnectPrinter,
       _setAwaitingDetach = setAwaitingDetach,
       _appendOrderHistory = appendOrderHistory,
       _startCalibration = startCalibration,
       _syncRecipeData = syncRecipeData,
       _getMenuInfo = getMenuInfo,
       _getMenuInfoBySku = getMenuInfoBySku,
       _getRecipeTiming = getRecipeTiming,
       _getRecipeDispenser = getRecipeDispenser,
       _getRecipeImage = getRecipeImage,
       _getRecipeVersion = getRecipeVersion,
       _getRecipeIngredientLabels = getRecipeIngredientLabels,
       _getRecipePopupIngredients = getRecipePopupIngredients,
       _getLabelOptions = getLabelOptions,
       _getMenuIngredients = getMenuIngredients,
       _resolveMenuOptions = resolveMenuOptions,
       _observeCalibrationStatus = observeCalibrationStatus,
       _disposeMachine = disposeMachine,
       _disposePrinter = disposePrinter,
       _observeLeaderUpdate = observeLeaderUpdate,
       _observeFollowerSyncRequest = observeFollowerSyncRequest,
       _publishLeaderUpdate = publishLeaderUpdate,
       _publishFollowerSync = publishFollowerSync,
       _publishBoardUpdate = publishBoardUpdate,
       _publishKioskUpdate = publishKioskUpdate,
       _publishCayeFault = publishCayeFault,
       _publishCayeStatus = publishCayeStatus,
       _publishCayeRinsing = publishCayeRinsing,
       _publishCayeCleaning = publishCayeCleaning,
       _sendRinsingCommand = sendRinsingCommand,
       _sendCleaningCommand = sendCleaningCommand,
       _sendTimeSync = sendTimeSync,
       _setCayeApiKey = setCayeApiKey,
       super(KdsState.initial()) {
    _init();
  }

  /// Connects to the order socket/MQTT (needed by both roles — MQTT is
  /// bundled into the same connect() call), then wires up role-appropriate
  /// subscriptions: the leader owns every real hardware/order-source stream
  /// (see [_initAsLeader]); a follower has none of them and instead mirrors
  /// whatever the leader broadcasts (see [_initAsFollower]).
  void _init() {
    unawaited(_connectOrderSocket());
    if (FlowHubIdentity.role == FlowHubRole.follower) {
      _initAsFollower();
    } else {
      _initAsLeader();
    }
  }

  /// 1. Observe order socket connection state
  /// 2. Observe barcode scan events → [_handleBarcodeScan]
  /// 3. Observe pickup complete events → [_handlePickupComplete]
  /// 4. Observe Caye machine progress → [_handleMachineProgress]
  /// 5. Observe printer status → [_handlePrinterStatus]
  /// 6. Observe calibration status → [_handleCalibrationStatus]
  /// 7. Observe follower action requests → [_handleFollowerSyncRequest]
  void _initAsLeader() {
    _connectionSubscription = _observeOrderConnection().listen((connected) {
      emit(state.copyWith(isConnected: connected));
    });
    _barcodeScanSubscription = _observeBarcodeScan().listen(
      this._handleBarcodeScan,
    );
    _qrCompleteSubscription = _observeQrComplete().listen(
      this._handleQrComplete,
    );
    _pickupCompleteSubscription = _observePickupComplete().listen(
      _handlePickupComplete,
    );
    _kioskOrderSubscription = _observeKioskOrder().listen(_handleKioskOrder);
    _machineProgressSubscription = _observeMachineProgress().listen(
      this._handleMachineProgress,
    );
    _printerStatusSubscription = _observePrinterStatus().listen(
      _handlePrinterStatus,
    );
    _printerConnectionSubscription = _observePrinterConnection().listen(
      (connected) => emit(state.copyWith(isPrinterConnected: connected)),
    );
    // Seed from the CURRENT connection state first — connectionStream is a
    // plain broadcast stream that only replays FUTURE transitions, so if
    // Caye is already connected by the time this cubit starts, no new
    // transition may ever fire and the Device Management screen would show
    // OFF forever despite a real, live connection (same reasoning as
    // CayeManagementCubit's own seeding).
    emit(state.copyWith(isCayeConnected: _getMachineConnectionSnapshot()));
    _cayeConnectionSubscription = _observeMachineConnection().listen(
      (connected) => emit(state.copyWith(isCayeConnected: connected)),
    );
    _calibrationStatusSubscription = _observeCalibrationStatus().listen(
      _handleCalibrationStatus,
    );
    _followerSyncRequestSubscription = _observeFollowerSyncRequest().listen(
      _handleFollowerSyncRequest,
    );
    _gaugeTickTimer = Timer.periodic(_gaugeTickInterval, (_) => _tickGaugePhases());
  }

  /// No hardware/order-source subscriptions at all — this device's state is
  /// entirely a mirror of whatever the leader last broadcast.
  void _initAsFollower() {
    _leaderUpdateSubscription = _observeLeaderUpdate().listen(_handleLeaderUpdate);
  }

  /// Broadcasts the current full state to all followers — called from the
  /// [emit] override below, so every single state change (a new order, a
  /// printer status flip, a calibration toggle) gets synced automatically
  /// without every mutating method needing to remember to do it.
  void _broadcastLeaderUpdate() {
    final version = _nextLeaderUpdateVersion();
    unawaited(
      _publishLeaderUpdate(
        LeaderUpdateMessage(
          eventId: '${NetworkConstants.mqttDeviceId}-$version',
          version: version,
          orders: state.orders,
          isCalibrating: state.isCalibrating,
          calibrationHeight: state.calibrationHeight,
          isPrinterConnected: state.isPrinterConnected,
          isLabelAttached: state.isLabelAttached,
          isConnected: state.isConnected,
          isCayeConnected: state.isCayeConnected,
        ),
      ),
    );
    unawaited(
      _publishBoardUpdate(
        BoardUpdateMessage(
          eventId: '${NetworkConstants.mqttDeviceId}-board-$version',
          version: version,
          orders: state.orders.map(_toBoardOrder).toList(),
        ),
      ),
    );
    // Same two numbers as the bottom summary bar's left side
    // (kds_main_screen.dart) — orders/cups not yet picked up.
    final activeOrders = state.orders.where((o) => o.currentTab != OrderTab.done);
    unawaited(
      _publishKioskUpdate(
        KioskUpdateMessage(
          eventId: '${NetworkConstants.mqttDeviceId}-kiosk-$version',
          version: version,
          orders: activeOrders.length,
          waiting: activeOrders.fold<int>(0, (sum, o) => sum + o.totalCups),
        ),
      ),
    );
  }

  /// Reduces a full internal [Order] down to what a display board actually
  /// needs — see the doc comment on [BoardUpdateMessage] for why this is a
  /// separate, leaner shape rather than the same one followers get.
  BoardOrder _toBoardOrder(Order order) => BoardOrder(
    orderNo: order.orderNo,
    tab: order.currentTab.name,
    totalCups: order.totalCups,
    lang: order.language,
    progress: order.aggregateProgress,
    items: [
      for (var i = 0; i < order.items.length; i++)
        BoardOrderItem(
          seq: i + 1,
          skuNo: order.items[i].skuNo,
          temp: order.items[i].temp,
          progress: order.items[i].progress,
          menuName: order.items[i].menuName,
          stage: order.items[i].stage.name,
          dispenserName: _firstDispenserName(order.items[i]),
        ),
    ],
  );

  /// First Nudof ingredient name (e.g. "Cold_Brew") from [item]'s recipe —
  /// the "[Dispenser]" token in the PB.BB.0002 bottom-bar template. Empty
  /// for Caye-only items (dispenserData is the 'N:0' no-op placeholder).
  String _firstDispenserName(SubItem item) {
    final data = _recipeDispenserFor(item).dispenserData;
    if (data.isEmpty || data == 'N:0') return '';
    return data.split(',').first.split(':').first;
  }

  /// Estimated Nudof/Caye seconds for [item]'s recipe — see
  /// GetRecipeTimingUseCase; always succeeds (falls back to the sheet's own
  /// default of 20/60s), so the Left branch here never actually triggers.
  RecipeTiming _recipeTimingFor(SubItem item) => _getRecipeTiming((
    skuNo: item.skuNo,
    temp: item.temp,
  )).fold((_) => (nudofSeconds: 20, cayeSeconds: 60), (r) => r);

  /// Interpolates `progress` for every sub-item currently in an active
  /// estimated-time phase (phaseStartedAt != null — see label-DETACH in
  /// [_handlePrinterStatus], which is the only place that starts one).
  /// Caye's real telemetry (0x24) updates its own items directly and never
  /// sets phaseStartedAt, so this never fights with it.
  void _tickGaugePhases() {
    final now = DateTime.now();
    bool changed = false;
    final updatedOrders = state.orders.map((o) {
      final items = o.items.map((item) {
        final startedAt = item.phaseStartedAt;
        if (startedAt == null) return item;
        final durationMs = item.phaseDurationSeconds * 1000;
        final fraction = durationMs <= 0
            ? 1.0
            : (now.difference(startedAt).inMilliseconds / durationMs).clamp(0.0, 1.0);
        final newProgress = item.phaseStartProgress +
            (item.phaseTargetProgress - item.phaseStartProgress) * fraction;
        if ((newProgress - item.progress).abs() < 0.001) return item;
        changed = true;
        return item.copyWith(progress: newProgress);
      }).toList();
      return o.copyWith(items: items);
    }).toList();
    if (changed) emit(state.copyWith(orders: updatedOrders));
  }

  /// Wall-clock-based, not a simple 0-based counter — a plain incrementing
  /// counter resets to 0 on every leader app restart, which would then get
  /// silently rejected forever by any follower that already applied a
  /// higher version from before the restart (the version-gate in
  /// [_handleLeaderUpdate] exists specifically to reject exactly that kind
  /// of "older" update). Real time only moves forward regardless of
  /// restarts, so this can't regress. Falls back to a plain increment on
  /// the rare chance two calls land in the same millisecond, to keep it
  /// strictly increasing either way.
  int _nextLeaderUpdateVersion() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _leaderUpdateVersion = now > _leaderUpdateVersion ? now : _leaderUpdateVersion + 1;
    return _leaderUpdateVersion;
  }

  /// Follower-side: replaces local state wholesale with the leader's latest
  /// broadcast — never computed locally, so there's a single source of
  /// truth. Ignores anything older than the last update already applied, so
  /// an out-of-order/redelivered message can't roll the UI back.
  void _handleLeaderUpdate(LeaderUpdateMessage message) {
    if (message.version <= _lastAppliedLeaderVersion) {
      Log.d(
        'KDS',
        'Ignoring stale leader update (version=${message.version}, last=$_lastAppliedLeaderVersion)',
      );
      return;
    }
    _lastAppliedLeaderVersion = message.version;
    Log.d(
      'KDS',
      'Applied leader update (version=${message.version}, ${message.orders.length} orders)',
    );
    emit(
      state.copyWith(
        orders: message.orders,
        isCalibrating: message.isCalibrating,
        calibrationHeight: message.calibrationHeight,
        isPrinterConnected: message.isPrinterConnected,
        isLabelAttached: message.isLabelAttached,
        isConnected: message.isConnected,
        isCayeConnected: message.isCayeConnected,
      ),
    );
  }

  /// Follower-side: asks the leader to perform [syncType] (see the switch in
  /// [_handleFollowerSyncRequest] for the full list) instead of mutating
  /// local state directly — the actual change arrives back via the next
  /// leader broadcast.
  void _requestSync(String syncType, Map<String, dynamic> params) {
    _followerSyncSeq++;
    unawaited(
      _publishFollowerSync(
        FollowerSyncRequest(
          sync: syncType,
          eventId: '${NetworkConstants.mqttDeviceId}-$_followerSyncSeq',
          version: _followerSyncSeq,
          params: params,
        ),
      ),
    );
  }

  /// Leader-side: executes whatever a follower asked for, using this
  /// cubit's own (already-role-gated) methods — since this instance IS the
  /// leader, those methods run their real logic rather than requesting sync
  /// again.
  void _handleFollowerSyncRequest(FollowerSyncRequest request) {
    final params = request.params;
    switch (request.sync) {
      case 'move_tab':
        final orderNo = params['orderNo']?.toString() ?? '';
        final targetTab = _orderTabByName(params['targetTab']?.toString() ?? '');
        if (orderNo.isNotEmpty && targetTab != null) {
          moveOrderToTab(orderNo, targetTab);
        }
      case 'calibration_start':
        final height = (params['height'] as num?)?.toDouble();
        if (height != null) startCalibration(height);
      case 'print_order':
        final orderNo = params['orderNo']?.toString() ?? '';
        final order = _orderByNo(orderNo);
        if (order != null) printOrderLabels(order);
      case 'print_single':
        final orderNo = params['orderNo']?.toString() ?? '';
        final subItemIndex = (params['subItemIndex'] as num?)?.toInt();
        final order = _orderByNo(orderNo);
        if (order != null && subItemIndex != null) {
          printSingleLabel(order, subItemIndex);
        }
      case 'cycle_item_status':
        final orderNo = params['orderNo']?.toString() ?? '';
        final subItemIndex = (params['subItemIndex'] as num?)?.toInt();
        if (orderNo.isNotEmpty && subItemIndex != null) {
          cycleItemStatus(orderNo, subItemIndex);
        }
      case 'caye_rinsing':
        unawaited(_sendRinsingCommand(NetworkConstants.cayeMachineIp));
      case 'caye_cleaning':
        final mode = (params['mode'] as num?)?.toInt() ?? 0;
        unawaited(
          _sendCleaningCommand((ip: NetworkConstants.cayeMachineIp, mode: mode)),
        );
      case 'caye_sync':
        unawaited(_sendTimeSync(NetworkConstants.cayeMachineIp));
      case 'caye_set_api_key':
        final apiKey = params['apiKey']?.toString() ?? '';
        if (apiKey.isNotEmpty) unawaited(_setCayeApiKey(apiKey));
      case 'caye_reboot':
        // No SendRestartCommandUseCase exists yet — nothing real to call
        // until a confirmed protocol value is found (matches the
        // direct-leader button's own no-op, see caye_management_screen.dart).
        break;
      case 'caye_shot_test':
        final count = (params['count'] as num?)?.toInt() ?? 10;
        final productKey = params['productKey']?.toString() ?? '2';
        startConsecutiveShotTest(count: count, productKey: productKey);
      case 'reconnect_printer':
        reconnectPrinter();
      default:
        Log.w('KDS', 'Unknown follower sync request: ${request.sync}');
    }
  }

  OrderTab? _orderTabByName(String name) {
    for (final tab in OrderTab.values) {
      if (tab.name == name) return tab;
    }
    return null;
  }

  Order? _orderByNo(String orderNo) {
    for (final order in state.orders) {
      if (order.orderNo == orderNo) return order;
    }
    return null;
  }

  /// Broadcasts to followers on every single state change (leader-only) —
  /// a single choke point so no mutating method needs to remember to sync.
  @override
  void emit(KdsState newState) {
    super.emit(newState);
    if (FlowHubIdentity.role == FlowHubRole.leader) {
      _scheduleLeaderBroadcast();
    }
  }

  /// Throttle-with-trailing-edge: publishes immediately if the last
  /// broadcast was more than [_broadcastMinInterval] ago, otherwise schedules
  /// exactly one more publish for the end of the current window (which reads
  /// whatever state is live when it fires, so nothing is lost — just
  /// coalesced).
  void _scheduleLeaderBroadcast() {
    final now = DateTime.now();
    final elapsed = _lastBroadcastAt == null
        ? _broadcastMinInterval
        : now.difference(_lastBroadcastAt!);
    if (elapsed >= _broadcastMinInterval) {
      _pendingBroadcastTimer?.cancel();
      _pendingBroadcastTimer = null;
      _lastBroadcastAt = now;
      _broadcastLeaderUpdate();
      return;
    }
    _pendingBroadcastTimer ??= Timer(_broadcastMinInterval - elapsed, () {
      _pendingBroadcastTimer = null;
      _lastBroadcastAt = DateTime.now();
      _broadcastLeaderUpdate();
    });
  }

  /// Adds a real kiosk order (beta/kiosk/order) to the NEW tab and starts
  /// printing its labels.
  void _handleKioskOrder(Order order) {
    if (state.orders.any((o) => o.orderNo == order.orderNo)) {
      Log.w('KDS', 'Kiosk order ${order.orderNo} already exists — ignoring duplicate');
      return;
    }
    final resolvedOrder = order.copyWith(
      items: order.items.map(_withEnglishMenuName).toList(),
    );
    emit(state.copyWith(orders: [...state.orders, resolvedOrder]));
    printOrderLabels(resolvedOrder);
    Log.d('KDS', 'Kiosk order ${order.orderNo} received (${order.items.length} items)');
  }

  /// Replaces [item]'s `menuName` with the Menu List sheet's English name
  /// for its `skuNo` — the kiosk sends whatever language the customer's
  /// session was in, but FlowHub/labels are read by baristas, not
  /// customers, so they must always show English regardless of what the
  /// order itself arrived in. Falls back to the kiosk's own raw name only
  /// if the sheet has no matching SKU (e.g. not loaded yet), rather than
  /// showing nothing at all.
  SubItem _withEnglishMenuName(SubItem item) {
    final info = _getMenuInfoBySku(item.skuNo).fold((_) => null, (r) => r);
    if (info == null) return item;
    return item.copyWith(menuName: info.menuNameEN);
  }

  /// Marks the order picked-up (moves it to DONE) when pickup is confirmed.
  void _handlePickupComplete(({String orderNo, String menuName}) event) {
    final updatedOrders = state.orders.map((o) {
      if (o.orderNo != event.orderNo) return o;
      return _restampIfTabChanged(o, _markPickedUp(o));
    }).toList();
    emit(state.copyWith(orders: updatedOrders));
    Log.d('KDS', 'Pickup complete — order ${event.orderNo} moved to DONE');
  }

  /// Updates label-attached state from the printer status stream, and — once
  /// a real ATTACHED→DETACHED sequence is observed for the head of
  /// [_awaitingDetachQueue] — starts BREW for that print job (FIFO, since the
  /// printer only holds one label at a time), then only NOW prints the next
  /// queued label. Printing the next label any earlier (e.g. right after the
  /// previous print command finishes, regardless of whether it's been peeled
  /// off yet) would let a single peel promote more than one sub-item to
  /// BREW, since the next label would already be sitting in
  /// [_awaitingDetachQueue] before the operator ever touched it.
  ///
  /// A DETACHED tick alone is NOT enough to resolve the queue: right after
  /// sending a print command, the label hasn't physically reached the
  /// printer's paper sensor yet, so the very next poll tick can still read
  /// DETACHED even though nothing has been peeled — that's "not out yet",
  /// not "removed". [job.sawAttached] gates this: only a DETACHED that comes
  /// AFTER a real ATTACHED was already observed for this job counts as an
  /// actual peel. Once printed, the physical cut reliably reaches the sensor
  /// as ATTACHED even for a near-instant peel (confirmed by hand-testing),
  /// so requiring that sequence doesn't reintroduce the original "peeled too
  /// fast to see any signal" problem this whole design exists to fix.
  ///
  /// While [_awaitingDetachQueue] is non-empty, native posts the printer's
  /// raw current status on every poll tick (not just on change — see
  /// [_processPrintQueue]'s call to [_setAwaitingDetach]), so an edge that
  /// occurred entirely between two polls — and was therefore never seen as a
  /// transition — still gets caught here on the very next tick, because this
  /// reads the real current state rather than waiting for a native-side
  /// edge. [state.isLabelAttached] is only emitted on an actual change so the
  /// repeated ticks don't spam broadcasts; the queue-resolution check below
  /// runs every tick regardless. Native goes back to edge-only reporting
  /// (below the noise floor) as soon as the queue empties again.
  void _handlePrinterStatus(bool attached) {
    if (attached != state.isLabelAttached) {
      emit(state.copyWith(isLabelAttached: attached));
    }
    if (_awaitingDetachQueue.isEmpty) return;
    final front = _awaitingDetachQueue.first;
    if (attached) {
      if (!front.sawAttached) {
        _awaitingDetachQueue[0] = (
          orderNo: front.orderNo,
          subItemIndex: front.subItemIndex,
          sawAttached: true,
        );
      }
      return;
    }
    if (!front.sawAttached) return; // Never actually attached yet — not a real peel, ignore.
    final job = _awaitingDetachQueue.removeAt(0);
    if (_awaitingDetachQueue.isEmpty) {
      unawaited(_setAwaitingDetach(false));
    }
    _updateSubItemByIndex(
      job.orderNo,
      job.subItemIndex,
      (s) {
        // Nudof has no data channel at all, so its portion of the gauge is
        // the only one driven by a pure time estimate rather than a real
        // signal — starting the instant the label is detached, since that's
        // the earliest (and only) observable proxy for "Nudof dispensing has
        // begun." Caye-only items get nothing here; their progress stays at
        // 0 until the machine's own real telemetry arrives (see
        // _applyProgressToSubItem), matching Caye's ability to report an
        // actual start signal that Nudof simply doesn't have.
        final timing = _recipeTimingFor(s);
        final productionType = timing.productionType;
        final startsNudofPhase = productionType == ProductionType.nudofOnly ||
            productionType == ProductionType.combo;
        return s.copyWith(
          isExtracting: true,
          currentStage: 'Label attached — awaiting scan',
          progress: startsNudofPhase ? 0.0 : s.progress,
          phaseStartedAt: startsNudofPhase ? DateTime.now() : s.phaseStartedAt,
          phaseStartProgress: startsNudofPhase ? 0.0 : s.phaseStartProgress,
          phaseTargetProgress: startsNudofPhase
              ? (productionType == ProductionType.nudofOnly ? 0.99 : 0.25)
              : s.phaseTargetProgress,
          phaseDurationSeconds: startsNudofPhase
              ? timing.nudofSeconds
              : s.phaseDurationSeconds,
          // Bottom-bar PB.BB.0002 trigger — Caye-only items get no stage
          // here at all (skipped, per the bottom-bar message design).
          stage: startsNudofPhase ? ProductionStage.nudofDispensing : s.stage,
        );
      },
      extraLog: 'Label detached',
    );
    unawaited(this._processPrintQueue());
  }

  /// Marks every sub-item of [order] as picked up.
  Order _markPickedUp(Order order) => order.copyWith(
    items: order.items
        .map(
          (i) => i.copyWith(
            status: OrderStatus.pickedUp,
            isExtracting: false,
            isError: false,
            progress: 1.0,
            // Stop any still-running estimated-time gauge timer — see the
            // same note on _handleQrComplete's copyWith.
            phaseStartedAt: null,
          ),
        )
        .toList(),
  );

  /// Manually moves [orderNo] into [targetTab] (figmaImage/3_orderSlide-*.png
  /// — dragging an order left/right to an adjacent tab). Brew→Call runs the
  /// same real action the equivalent label scan would have — see
  /// [_advanceOneSubItem] — so this doubles as the manual fallback for a
  /// torn/misread label, not just a cosmetic override. New→Brew, backward
  /// moves, and jumps straight into Done stay a pure operator override on
  /// the KDS screen's own display state (see [_advanceOneSubItem] for why
  /// New→Brew deliberately never fires the real Caye command).
  void moveOrderToTab(String orderNo, OrderTab targetTab) {
    if (FlowHubIdentity.role == FlowHubRole.follower) {
      _requestSync('move_tab', {'orderNo': orderNo, 'targetTab': targetTab.name});
      return;
    }
    final orderIndex = state.orders.indexWhere((o) => o.orderNo == orderNo);
    if (orderIndex == -1) return;
    final order = state.orders[orderIndex];
    for (int i = 0; i < order.items.length; i++) {
      _advanceOneSubItem(order, i, order.items[i].tab, targetTab);
    }
    Log.d('KDS', 'Order $orderNo manually moved to ${targetTab.name}');
  }

  /// The field-set a sub-item needs to genuinely be classified as
  /// [targetTab] by [SubItemTabClassifier.tab] — shared by [moveOrderToTab]
  /// (whole-order override) and [cycleItemStatus] (single-item override).
  SubItem _subItemForTab(SubItem item, OrderTab targetTab) => switch (targetTab) {
    OrderTab.newOrder => item.copyWith(
      status: OrderStatus.pending,
      isExtracting: false,
      isError: false,
      progress: 0.0,
      currentStage: 'Pending',
      phaseStartedAt: null,
    ),
    OrderTab.brew => _subItemForBrewTab(item),
    OrderTab.call => item.copyWith(
      status: OrderStatus.ready,
      isExtracting: false,
      isError: false,
      progress: 1.0,
      currentStage: 'Complete',
      phaseStartedAt: null,
    ),
    OrderTab.done => item.copyWith(
      status: OrderStatus.pickedUp,
      isExtracting: false,
      isError: false,
      progress: 1.0,
      phaseStartedAt: null,
    ),
  };

  /// Manually moving into Brew has no real detach/start signal to drive the
  /// gauge from, so — same as label-DETACH in [_handlePrinterStatus] — this
  /// starts the Nudof estimated-time phase itself for Nudof-only/combo
  /// items, since Nudof never has a real signal to wait for at all. Caye-
  /// only items still just wait for the real 0x22 status=1 signal (see
  /// _applyProgressToSubItem) — a manual move can't fake that, matching the
  /// same "real signal or nothing" rule a real DETACH would follow too.
  SubItem _subItemForBrewTab(SubItem item) {
    final timing = _recipeTimingFor(item);
    final productionType = timing.productionType;
    final startsNudofPhase = productionType == ProductionType.nudofOnly ||
        productionType == ProductionType.combo;
    return item.copyWith(
      status: OrderStatus.pending,
      isExtracting: true,
      isError: false,
      progress: 0.0,
      currentStage: 'Extracting',
      phaseStartedAt: startsNudofPhase ? DateTime.now() : null,
      phaseStartProgress: startsNudofPhase ? 0.0 : item.phaseStartProgress,
      phaseTargetProgress: startsNudofPhase
          ? (productionType == ProductionType.nudofOnly ? 0.99 : 0.25)
          : item.phaseTargetProgress,
      phaseDurationSeconds: startsNudofPhase ? timing.nudofSeconds : item.phaseDurationSeconds,
    );
  }

  /// Manually advances a single sub-item's New→Brew→Call→Done status one
  /// step forward (figma: the per-item pill in the expanded order panel),
  /// for when automatic production tracking doesn't advance an item on its
  /// own. Brew→Call runs the same real action the equivalent label scan
  /// would have — see [_advanceOneSubItem] for why New→Brew doesn't.
  ///
  /// One-directional only — tapping Done's pill is a no-op, it does NOT
  /// wrap back around to New. Swipe (see [moveOrderToTab]) is the only way
  /// to move an item backward. Wrapping used to be allowed here, but a
  /// Done→New wrap-around (via a fast repeated tap) left a sub-item with a
  /// full real production history sitting in a "New" display state, and
  /// re-advancing THAT into Brew was the actual repro for a red-screen
  /// crash loop the operator hit — the exact throwing statement wasn't
  /// pinned down, but removing the only one-tap path into that state closes
  /// the reported reproduction.
  void cycleItemStatus(String orderNo, int subItemIndex) {
    if (FlowHubIdentity.role == FlowHubRole.follower) {
      _requestSync('cycle_item_status', {
        'orderNo': orderNo,
        'subItemIndex': subItemIndex,
      });
      return;
    }
    final orderIndex = state.orders.indexWhere((o) => o.orderNo == orderNo);
    if (orderIndex == -1) return;
    final order = state.orders[orderIndex];
    if (subItemIndex < 0 || subItemIndex >= order.items.length) return;
    const cycle = [OrderTab.newOrder, OrderTab.brew, OrderTab.call, OrderTab.done];
    final fromTab = order.items[subItemIndex].tab;
    final fromIndex = cycle.indexOf(fromTab);
    if (fromIndex == cycle.length - 1) return; // Done — nothing further to advance to.
    final nextTab = cycle[fromIndex + 1];
    _advanceOneSubItem(order, subItemIndex, fromTab, nextTab);
  }

  /// Moves [order]'s sub-item at [subItemIndex] from [fromTab] to [toTab] —
  /// shared by [moveOrderToTab] (whole-order swipe) and [cycleItemStatus]
  /// (single-item pill tap). A genuine forward step triggers the same real
  /// action the equivalent label scan would have, so a manual correction
  /// (torn/misread label, wrong tab tapped, etc.) ends up in exactly the
  /// state a real scan would have left it in — not just a different-looking
  /// tab:
  /// - New→Brew: display/tab state only via [_subItemForTab] (which already
  ///   starts the Nudof estimated-time gauge for Nudof-only/combo items, same
  ///   as a real label-DETACH would) — deliberately does NOT call
  ///   [_startManufacturing], unlike a real label scan. A real Caye command
  ///   is a physical, hard-to-undo action, and there are already several
  ///   other ways to trigger it for real (reprint the label and scan it
  ///   normally, use the separate QR reader, or operate the Caye machine
  ///   directly) — so this manual move only needs to fix up what the KDS
  ///   screen shows, not fire off the machine itself.
  /// - Brew→Call: the manual field override already matches
  ///   [_handleQrComplete]'s real field-set, so it stays as-is; this only
  ///   adds the real [_autoSendOrderReady] broadcast the pickup table needs
  ///   to draw its guide circle.
  /// Backward moves, and jumps into New/Done, stay a pure operator override
  /// (Done has no real action beyond the fields [_subItemForTab] already
  /// sets — see [_handlePickupComplete]/[_markPickedUp], which set the same
  /// ones; there's also no real-world analog for "un-scanning").
  void _advanceOneSubItem(Order order, int subItemIndex, OrderTab fromTab, OrderTab toTab) {
    _updateSubItemByIndex(order.orderNo, subItemIndex, (s) => _subItemForTab(s, toTab));

    if (toTab == OrderTab.call && toTab.index > fromTab.index) {
      unawaited(this._autoSendOrderReady(order.orderNo, subItemIndex));
    }
  }

  /// Re-stamps [newOrder]'s [Order.stateEnteredAt] to now if its tab
  /// classification changed relative to [oldOrder], so elapsed-time-in-tab
  /// and oldest-first sorting stay accurate across every transition. Also
  /// the single place that detects "this order just newly entered DONE" —
  /// every real (pickup signal) and manual (swipe/button) path to DONE
  /// funnels through here, so this fires exactly once per real completion
  /// regardless of which one it was, logging it to the durable order-history
  /// file (order state itself only ever lives in memory — see
  /// KdsState.initial()). Firing again for the same order (e.g. someone
  /// swipes it back to New and forward to Done a second time) is intentional
  /// — [Order.receivedAt] never changes after creation, so two log lines
  /// sharing the same receivedAt but different completedAt is exactly how a
  /// re-completed order shows up in the history file.
  Order _restampIfTabChanged(Order oldOrder, Order newOrder) {
    if (oldOrder.currentTab == newOrder.currentTab) return newOrder;
    final restamped = newOrder.copyWith(stateEnteredAt: DateTime.now());
    if (restamped.currentTab == OrderTab.done) {
      unawaited(_appendOrderHistory(restamped));
    }
    return restamped;
  }

  /// Updates calibration state from the calibration status stream.
  void _handleCalibrationStatus(String status) {
    final calibrating = status == 'VALIDATION_MODE';
    emit(state.copyWith(isCalibrating: calibrating));
    Log.d('Calibration', 'Status: $status');
  }

  /// Applies [updater] to the sub-item at [subItemIndex] within the order matching [orderNo].
  /// Optionally prepends [extraLog] to the sub-item's log list if not already the latest entry.
  void _updateSubItemByIndex(
    String orderNo,
    int subItemIndex,
    SubItem Function(SubItem) updater, {
    String? extraLog,
  }) {
    final updatedOrders = state.orders.map((o) {
      if (o.orderNo != orderNo) return o;
      final items = List<SubItem>.from(o.items);
      if (subItemIndex < 0 || subItemIndex >= items.length) return o;

      SubItem updated = updater(items[subItemIndex]);
      if (extraLog != null) {
        final logs = List<String>.from(updated.logs);
        if (logs.isEmpty || logs.first != extraLog) logs.insert(0, extraLog);
        updated = updated.copyWith(logs: logs);
      }
      items[subItemIndex] = updated;
      return _restampIfTabChanged(o, o.copyWith(items: items));
    }).toList();
    emit(state.copyWith(orders: updatedOrders));
  }

  /// Sends a cancel command to the Caye machine and advances the manufacturing queue.
  /// 1. Validate that the queue head matches [orderNo]
  /// 2. Send cancel command to the machine
  /// 3. Reset sub-item UI state to idle
  /// 4. Stop accepting machine packets and advance the queue
  void cancelBrewing(String orderNo) {
    if (_manufacturingQueue.isEmpty) return;
    final task = _manufacturingQueue.first;
    if (task.orderNo != orderNo) return;
    unawaited(
      _sendCancelCommand((
        ip: task.machineIp,
        productKey: task.productKey,
        orderNo: task.machineOrderNo,
      )),
    );
    _updateSubItemByIndex(
      orderNo,
      task.subItemIndex,
      (s) => s.copyWith(isExtracting: false, isError: false),
      extraLog: 'Cancelled by user',
    );
    _acceptMachinePackets = false;
    _availabilityTimer?.cancel();
    this._advanceQueue();
  }

  /// Debug-only: enqueues [count] consecutive brew commands directly (not
  /// tied to any real order — the dummy orderNo below never matches
  /// anything in [state.orders], so [_updateSubItemByIndex] silently no-ops
  /// for these) — for stress-testing back-to-back Caye extractions (Caye
  /// Machine Control screen's test button). [productKey] defaults to '2',
  /// the machine's current espresso product code.
  ///
  /// Only the FIRST shot is marked [ManufacturingQueueItem.skipReadyDelay]
  /// (nothing was already in progress before it, so there's no reason to
  /// wait) — every shot after that keeps the normal 2s "place cup" wait
  /// between shots, same as a real brew queue.
  void startConsecutiveShotTest({int count = 10, String productKey = '2'}) {
    if (FlowHubIdentity.role == FlowHubRole.follower) {
      _requestSync('caye_shot_test', {'count': count, 'productKey': productKey});
      return;
    }
    final ip = NetworkConstants.cayeMachineIp;
    final testId = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < count; i++) {
      _manufacturingQueue.add(ManufacturingQueueItem(
        machineIp: ip,
        productKey: productKey,
        machineOrderNo: 'SHOTTEST-$testId.${(i + 1).toString().padLeft(2, '0')}',
        orderNo: _shotTestOrderNo,
        subItemIndex: 0,
        isExtraShot: true,
        skipReadyDelay: i == 0,
      ));
    }
    emit(state.copyWith(
      manufacturingQueueLength: _manufacturingQueue.length,
      shotTestTotal: count,
      shotTestCompleted: 0,
      shotTestStartedAt: DateTime.now(),
      shotTestFinishedAt: null,
    ));
    Log.d('Caye',
        'Shot test: queued $count consecutive brew commands (productKey=$productKey, no ready-delay)');
    if (!_isMachineBusy) {
      _isMachineBusy = true;
      _availabilityTimer?.cancel();
      _availabilityTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
        this._checkNextTaskAvailability();
      });
      this._checkNextTaskAvailability();
    }
  }

  /// Bumps [KdsState.shotTestCompleted] and stamps [KdsState.shotTestFinishedAt]
  /// once the count reaches [KdsState.shotTestTotal] — called from
  /// [_applyProgressToSubItem] whenever a shot-test queue item finishes
  /// (success or error alike), so the Caye Machine Control screen's
  /// elapsed-time/shot-count display can react.
  void _recordShotTestCompletion() {
    final completed = state.shotTestCompleted + 1;
    final done = completed >= state.shotTestTotal;
    emit(state.copyWith(
      shotTestCompleted: completed,
      shotTestFinishedAt: done ? DateTime.now() : null,
    ));
  }

  /// Sends a START_CALIBRATION signal to the pickup table for height-sensor calibration.
  void startCalibration(double height) {
    if (FlowHubIdentity.role == FlowHubRole.follower) {
      _requestSync('calibration_start', {'height': height});
      return;
    }
    _startCalibration(height);
    emit(state.copyWith(isCalibrating: true, calibrationHeight: height.round()));
  }

  /// Resets the calibration state flag.
  void stopCalibration() => emit(state.copyWith(isCalibrating: false));

  /// Manually retries the label printer connection (Device Management
  /// screen's "off" Label Printer row, tapped) instead of waiting on
  /// whatever external event (e.g. powering the printer back on) might let
  /// it recover on its own — there's no automatic retry once the native
  /// side gives up. The printer is physically wired to the leader only, so
  /// a follower forwards the request instead of acting on a printer it was
  /// never connected to in the first place.
  void reconnectPrinter() {
    if (FlowHubIdentity.role == FlowHubRole.follower) {
      _requestSync('reconnect_printer', const {});
      return;
    }
    unawaited(_reconnectPrinter(null));
  }

  /// Manually retries the Caye machine connection (Device Management
  /// screen's "off" Caye Machine row, tapped) — same idea as
  /// [reconnectPrinter]. Caye's socket is lazily opened by whatever command
  /// is sent next (see CayeMachineDataSource._sendPacket), so there's no
  /// dedicated "just reconnect" call — sending the same lightweight
  /// time-sync command the 1-minute heartbeat already uses is enough to
  /// trigger it, with no side effect on the machine itself. Reuses the
  /// existing 'caye_sync' sync type — [_handleFollowerSyncRequest] already
  /// handles it the same way regardless of what triggered it.
  void reconnectCaye() {
    if (FlowHubIdentity.role == FlowHubRole.follower) {
      _requestSync('caye_sync', const {});
      return;
    }
    unawaited(_sendTimeSync(NetworkConstants.cayeMachineIp));
  }

  /// Forces an immediate reload of the Recipe/Menu/Option sheets (hamburger
  /// menu's "Recipe Sync" button) — for applying a just-edited sheet without
  /// waiting for the periodic 2-minute Version Info check.
  Future<void> syncRecipeData() async {
    (await _syncRecipeData(null)).fold(
      (e) => Log.e('KDS', 'Recipe sync failed: ${e.message}'),
      (_) => Log.d('KDS', 'Recipe sync complete'),
    );
  }

  /// Marks a sub-item as cooked and updates its UI state.
  /// 1. Call [_completeCooking] use case
  /// 2. On failure: emit error message, return false
  /// 3. On success: update sub-item to ready state, clear error
  Future<bool> completeCooking(Order order, SubItem subItem) async {
    final result = await _completeCooking((order: order, subItem: subItem));
    return result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        return false;
      },
      (ok) {
        if (!ok) {
          emit(
            state.copyWith(errorMessage: 'Failed to mark cooking as complete.'),
          );
          return false;
        }
        final subItemIndex = order.items.indexOf(subItem);
        if (subItemIndex != -1) {
          _updateSubItemByIndex(
            order.orderNo,
            subItemIndex,
            (s) => s.copyWith(
              status: OrderStatus.ready,
              progress: 1.0,
              currentStage: 'Complete',
            ),
          );
        }
        emit(state.copyWith(errorMessage: null));
        return true;
      },
    );
  }

  /// Looks up the Google Sheet-sourced menu reference data (hot/iced
  /// availability, thumbnail image) for a menu name, or null if not found.
  MenuInfo? menuInfoFor(String menuName) => menuName.isEmpty
      ? null
      : _getMenuInfo(menuName).fold((_) => null, (r) => r);

  /// Direct-viewable recipe illustration URL for [item] — the recipe
  /// popup's image, sourced from the "Recipe List" sheet's Recipe_Image
  /// column instead of a bundled asset. Null if the sheet has no matching
  /// row/value (the popup just shows no illustration in that case).
  String? recipeImageFor(SubItem item) => item.skuNo.isEmpty
      ? null
      : _getRecipeImage((skuNo: item.skuNo, temp: item.temp)).fold((_) => null, (r) => r);

  /// Recipe version string printed on the label (e.g. "0.90.0729.01") — from
  /// the "Recipe List" sheet's Version column. Null if the sheet has no
  /// matching row/value.
  String? recipeVersionFor(SubItem item) => item.skuNo.isEmpty
      ? null
      : _getRecipeVersion((skuNo: item.skuNo, temp: item.temp)).fold((_) => null, (r) => r);

  /// Base recipe ingredient/device labels (Caye + Nudof) for [item] — the
  /// order list's expanded per-item tags show these alongside the
  /// customer's actual added options ([ingredientsFor]).
  List<String> recipeIngredientLabelsFor(SubItem item) => item.skuNo.isEmpty
      ? const []
      : _getRecipeIngredientLabels((skuNo: item.skuNo, temp: item.temp))
          .fold((_) => const [], (r) => r);

  /// The recipe popup's ingredient pills — base recipe amounts combined with
  /// the order's actual selected options (see
  /// [GetRecipePopupIngredientsUseCase]'s doc comment for the combining
  /// rules). Falls back to the menu's plain default recipe (no SKU/options)
  /// for dev test orders with no real per-order data, same fallback
  /// [ingredientsFor] already uses.
  List<MenuIngredient> recipePopupIngredientsFor(SubItem item) {
    if (item.skuNo.isEmpty) return ingredientsFor(item.menuName, item.selectedOptions);
    return _getRecipePopupIngredients((
      skuNo: item.skuNo,
      menuNameEN: item.menuName,
      temp: item.temp,
      selectedOptions: item.selectedOptions,
    )).fold((_) => const [], (r) => r);
  }

  /// The printed label's [OPTION] section — no recipe data, just the
  /// customer's actual added-beyond-default options (see
  /// [GetLabelOptionsUseCase]'s doc comment for the exact format).
  List<MenuIngredient> labelOptionsFor(String menuName, List<SelectedOption> selectedOptions) =>
      menuName.isEmpty
          ? const []
          : _getLabelOptions((menuNameEN: menuName, selectedOptions: selectedOptions))
              .fold((_) => const [], (r) => r);

  /// Resolves ingredients for display (order-row tags, recipe popup, printed
  /// label). When [selectedOptions] is non-empty (a real kiosk order),
  /// resolves only the customer's actual customizations beyond the recipe
  /// default (see [resolveSelectedOptions]'s doc comment); otherwise falls
  /// back to the menu's static default recipe (dev test orders, which have
  /// no real per-order data).
  List<MenuIngredient> ingredientsFor(
    String menuName, [
    List<SelectedOption> selectedOptions = const [],
  ]) {
    if (selectedOptions.isNotEmpty) {
      return _resolveMenuOptions((menuNameEN: menuName, options: selectedOptions))
          .fold((_) => const [], (r) => r);
    }
    return menuName.isEmpty
        ? const []
        : _getMenuIngredients(menuName).fold((_) => const [], (r) => r);
  }

  /// Marks the order as picked up, moving it into the DONE tab.
  /// 1. Call [_completePickup] use case
  /// 2. On failure: emit error message, return false
  /// 3. On success: mark order picked-up in state, clear error
  Future<bool> completePickup(Order order) async {
    final result = await _completePickup(order);
    return result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        return false;
      },
      (ok) {
        if (!ok) {
          emit(
            state.copyWith(errorMessage: 'Failed to mark pickup as complete.'),
          );
          return false;
        }
        final updatedOrders = state.orders.map((o) {
          if (o.orderNo != order.orderNo) return o;
          return _restampIfTabChanged(o, _markPickedUp(o));
        }).toList();
        emit(state.copyWith(orders: updatedOrders, errorMessage: null));
        return true;
      },
    );
  }

  /// Strips any leading letters from [orderNo] for the printed QR only (the
  /// real orderNo — shown as text on the label, used everywhere else —
  /// is untouched). Diagnostic experiment: the physical scanner drops a
  /// fixed number of leading characters from every scan regardless of
  /// content, and order IDs recently gained a leading letter (e.g. "A9528"
  /// vs. the previously all-digit "9528") — testing whether that leading
  /// letter is a factor. [_handleBarcodeScan]/[_handleQrComplete] match
  /// scanned orders against this stripped form too, so real orderNo lookups
  /// still succeed.
  String _qrOrderNo(String orderNo) => orderNo.replaceFirst(RegExp(r'^[A-Za-z]+'), '');

  /// Real Caye pkey + Nudof dispenser string for [item]'s recipe — see
  /// GetRecipeDispenserUseCase; always succeeds (falls back to the sheet's
  /// own safe no-op values), so the Left branch here never actually triggers.
  RecipeDispenser _recipeDispenserFor(SubItem item) => _getRecipeDispenser((
    skuNo: item.skuNo,
    temp: item.temp,
    selectedOptions: item.selectedOptions,
  )).fold((_) => (cayePkey: '0', dispenserData: 'N:0'), (r) => r);

  /// Builds (or reuses the in-flight) print job for one sub-item of [order].
  ManufacturingQueueItem _buildPrintJob(Order order, int index, String totSeq) {
    final seq = (index + 1).toString().padLeft(2, '0');
    return _manufacturingQueue.firstWhere(
      (q) => q.orderNo == order.orderNo && q.subItemIndex == index,
      orElse: () {
        final dispenser = _recipeDispenserFor(order.items[index]);
        final pKey = dispenser.cayePkey;
        return ManufacturingQueueItem(
          machineIp: NetworkConstants.cayeMachineIp,
          productKey: pKey,
          machineOrderNo: '${order.orderNo}.$seq',
          orderNo: order.orderNo,
          subItemIndex: index,
          qrData: '${dispenser.dispenserData}|${_qrOrderNo(order.orderNo)}.$seq.$totSeq,pkey:$pKey',
        );
      },
    );
  }

  /// Enqueues print jobs for every sub-item in [order] and starts the print queue.
  void printOrderLabels(Order order) {
    if (FlowHubIdentity.role == FlowHubRole.follower) {
      _requestSync('print_order', {'orderNo': order.orderNo});
      return;
    }
    final totSeq = order.items.length.toString().padLeft(2, '0');
    for (int i = 0; i < order.items.length; i++) {
      _pendingPrintJobs.add(_buildPrintJob(order, i, totSeq));
    }
    unawaited(this._processPrintQueue());
  }

  /// Enqueues a print job for just one sub-item — the expanded panel's
  /// per-item QR button, as opposed to [printOrderLabels]' whole-order print.
  void printSingleLabel(Order order, int subItemIndex) {
    if (subItemIndex < 0 || subItemIndex >= order.items.length) return;
    if (FlowHubIdentity.role == FlowHubRole.follower) {
      _requestSync('print_single', {
        'orderNo': order.orderNo,
        'subItemIndex': subItemIndex,
      });
      return;
    }
    final totSeq = order.items.length.toString().padLeft(2, '0');
    _pendingPrintJobs.add(_buildPrintJob(order, subItemIndex, totSeq));
    unawaited(this._processPrintQueue());
  }

  /// Cancels all stream subscriptions and releases machine/printer resources.
  /// Called from [KdsMainScreen.dispose] when the screen exits.
  @override
  Future<void> close() async {
    await _connectionSubscription?.cancel();
    await _barcodeScanSubscription?.cancel();
    await _qrCompleteSubscription?.cancel();
    await _pickupCompleteSubscription?.cancel();
    await _kioskOrderSubscription?.cancel();
    await _machineProgressSubscription?.cancel();
    await _printerStatusSubscription?.cancel();
    await _printerConnectionSubscription?.cancel();
    await _cayeConnectionSubscription?.cancel();
    await _calibrationStatusSubscription?.cancel();
    await _leaderUpdateSubscription?.cancel();
    await _followerSyncRequestSubscription?.cancel();
    _availabilityTimer?.cancel();
    _gaugeTickTimer?.cancel();
    _pendingBroadcastTimer?.cancel();
    _disposeMachine(null);
    _disposePrinter(null);
    _disconnectOrderSocket();
    return super.close();
  }
}
