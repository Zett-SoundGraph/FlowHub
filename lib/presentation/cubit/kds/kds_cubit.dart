import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:kds/core/constants/network.dart';
import 'package:kds/core/utils/log.dart';
import 'package:kds/domain/entities/index.dart';
import 'package:kds/domain/enums/order_status.dart';
import 'package:kds/domain/usecases/check_machine_availability_usecase.dart';
import 'package:kds/domain/usecases/complete_cooking_usecase.dart';
import 'package:kds/domain/usecases/complete_pickup_usecase.dart';
import 'package:kds/domain/usecases/connect_order_socket_usecase.dart';
import 'package:kds/domain/usecases/disconnect_order_socket_usecase.dart';
import 'package:kds/domain/usecases/dispose_machine_usecase.dart';
import 'package:kds/domain/usecases/dispose_printer_usecase.dart';
import 'package:kds/domain/usecases/get_recipe_usecase.dart';
import 'package:kds/domain/usecases/observe_barcode_scan_usecase.dart';
import 'package:kds/domain/usecases/observe_calibration_status_usecase.dart';
import 'package:kds/domain/usecases/observe_machine_progress_usecase.dart';
import 'package:kds/domain/usecases/observe_order_connection_usecase.dart';
import 'package:kds/domain/usecases/observe_pickup_complete_usecase.dart';
import 'package:kds/domain/usecases/observe_printer_status_usecase.dart';
import 'package:kds/domain/usecases/print_label_usecase.dart';
import 'package:kds/domain/usecases/send_cancel_command_usecase.dart';
import 'package:kds/domain/usecases/send_make_command_usecase.dart';
import 'package:kds/domain/usecases/start_calibration_usecase.dart';
import 'package:kds/presentation/widgets/order_label_widget.dart';
import 'package:screenshot/screenshot.dart';

import 'kds_state.dart';

part 'kds_cubit_barcode.dart';
part 'kds_cubit_manufacturing.dart';
part 'kds_cubit_printer.dart';

@injectable
class KdsCubit extends Cubit<KdsState> {
  final CompleteCookingUseCase _completeCooking;
  final CompletePickupUseCase _completePickup;
  final ConnectOrderSocketUseCase _connectOrderSocket;
  final DisconnectOrderSocketUseCase _disconnectOrderSocket;
  final ObserveOrderConnectionUseCase _observeOrderConnection;
  final ObserveBarcodeScanUseCase _observeBarcodeScan;
  final ObservePickupCompleteUseCase _observePickupComplete;
  final ObserveMachineProgressUseCase _observeMachineProgress;
  final CheckMachineAvailabilityUseCase _checkMachineAvailability;
  final SendMakeCommandUseCase _sendMakeCommand;
  final SendCancelCommandUseCase _sendCancelCommand;
  final ObservePrinterStatusUseCase _observePrinterStatus;
  final PrintLabelUseCase _printLabel;
  final StartCalibrationUseCase _startCalibration;
  final GetRecipeUseCase _getRecipe;
  final ObserveCalibrationStatusUseCase _observeCalibrationStatus;
  final DisposeMachineUseCase _disposeMachine;
  final DisposePrinterUseCase _disposePrinter;

  final ScreenshotController _screenshotController = ScreenshotController();

  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<String>? _barcodeScanSubscription;
  StreamSubscription<({String orderNo, String menuName})>? _pickupCompleteSubscription;
  StreamSubscription<ExtractionProgress>? _machineProgressSubscription;
  StreamSubscription<bool>? _printerStatusSubscription;
  StreamSubscription<String>? _calibrationStatusSubscription;

  final List<ManufacturingQueueItem> _manufacturingQueue = [];
  bool _isMachineBusy = false;
  bool _acceptMachinePackets = false;
  bool _isWaitingForCleanStart = false;
  bool _isRetrying = false;
  Timer? _availabilityTimer;

  final List<ManufacturingQueueItem> _pendingPrintJobs = [];
  bool _isPrinting = false;

  KdsCubit({
    required CompleteCookingUseCase completeCooking,
    required CompletePickupUseCase completePickup,
    required ConnectOrderSocketUseCase connectOrderSocket,
    required DisconnectOrderSocketUseCase disconnectOrderSocket,
    required ObserveOrderConnectionUseCase observeOrderConnection,
    required ObserveBarcodeScanUseCase observeBarcodeScan,
    required ObservePickupCompleteUseCase observePickupComplete,
    required ObserveMachineProgressUseCase observeMachineProgress,
    required CheckMachineAvailabilityUseCase checkMachineAvailability,
    required SendMakeCommandUseCase sendMakeCommand,
    required SendCancelCommandUseCase sendCancelCommand,
    required ObservePrinterStatusUseCase observePrinterStatus,
    required PrintLabelUseCase printLabel,
    required StartCalibrationUseCase startCalibration,
    required GetRecipeUseCase getRecipe,
    required ObserveCalibrationStatusUseCase observeCalibrationStatus,
    required DisposeMachineUseCase disposeMachine,
    required DisposePrinterUseCase disposePrinter,
  })  : _completeCooking = completeCooking,
        _completePickup = completePickup,
        _connectOrderSocket = connectOrderSocket,
        _disconnectOrderSocket = disconnectOrderSocket,
        _observeOrderConnection = observeOrderConnection,
        _observeBarcodeScan = observeBarcodeScan,
        _observePickupComplete = observePickupComplete,
        _observeMachineProgress = observeMachineProgress,
        _checkMachineAvailability = checkMachineAvailability,
        _sendMakeCommand = sendMakeCommand,
        _sendCancelCommand = sendCancelCommand,
        _observePrinterStatus = observePrinterStatus,
        _printLabel = printLabel,
        _startCalibration = startCalibration,
        _getRecipe = getRecipe,
        _observeCalibrationStatus = observeCalibrationStatus,
        _disposeMachine = disposeMachine,
        _disposePrinter = disposePrinter,
        super(KdsState.initial()) {
    _init();
  }

  /// Subscribes to all domain streams and initiates the order socket connection.
  /// 1. Observe order socket connection state
  /// 2. Observe barcode scan events → [_handleBarcodeScan]
  /// 3. Observe pickup complete events → [_handlePickupComplete]
  /// 4. Observe Caye machine progress → [_handleMachineProgress]
  /// 5. Observe printer status → [_handlePrinterStatus]
  /// 6. Observe calibration status → [_handleCalibrationStatus]
  /// 7. Connect to the order socket
  void _init() {
    _connectionSubscription = _observeOrderConnection().listen((connected) {
      emit(state.copyWith(isConnected: connected));
    });
    _barcodeScanSubscription = _observeBarcodeScan().listen(this._handleBarcodeScan);
    _pickupCompleteSubscription = _observePickupComplete().listen(_handlePickupComplete);
    _machineProgressSubscription = _observeMachineProgress().listen(this._handleMachineProgress);
    _printerStatusSubscription = _observePrinterStatus().listen(_handlePrinterStatus);
    _calibrationStatusSubscription = _observeCalibrationStatus().listen(_handleCalibrationStatus);
    unawaited(_connectOrderSocket());
  }

  /// Removes the completed order from the list when pickup is confirmed.
  void _handlePickupComplete(({String orderNo, String menuName}) event) {
    final updatedOrders =
        state.orders.where((o) => o.orderNo != event.orderNo).toList();
    emit(state.copyWith(orders: updatedOrders));
    Log.d('KDS', 'Pickup complete — order ${event.orderNo} removed');
  }

  /// Updates label-attached state from the printer status stream.
  void _handlePrinterStatus(bool attached) {
    emit(state.copyWith(isLabelAttached: attached));
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
      return o.copyWith(items: items);
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
    unawaited(_sendCancelCommand((ip: task.machineIp, productKey: task.productKey, orderNo: task.machineOrderNo)));
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

  /// Sends a START_CALIBRATION signal to the pickup table for height-sensor calibration.
  void startCalibration(double height) {
    _startCalibration(height);
    emit(state.copyWith(isCalibrating: true));
  }

  /// Resets the calibration state flag.
  void stopCalibration() => emit(state.copyWith(isCalibrating: false));

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
          emit(state.copyWith(errorMessage: 'Failed to mark cooking as complete.'));
          return false;
        }
        final subItemIndex = order.items.indexOf(subItem);
        if (subItemIndex != -1) {
          _updateSubItemByIndex(order.orderNo, subItemIndex,
              (s) => s.copyWith(status: OrderStatus.ready, progress: 1.0, currentStage: 'Complete'));
        }
        emit(state.copyWith(errorMessage: null));
        return true;
      },
    );
  }

  /// Marks the order as picked up and removes it from the order list.
  /// 1. Call [_completePickup] use case
  /// 2. On failure: emit error message, return false
  /// 3. On success: remove order from state, clear error
  Future<bool> completePickup(Order order) async {
    final result = await _completePickup(order);
    return result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        return false;
      },
      (ok) {
        if (!ok) {
          emit(state.copyWith(errorMessage: 'Failed to mark pickup as complete.'));
          return false;
        }
        final updatedOrders =
            state.orders.where((o) => o.orderNo != order.orderNo).toList();
        emit(state.copyWith(orders: updatedOrders, errorMessage: null));
        return true;
      },
    );
  }

  /// Enqueues print jobs for every sub-item in [order] and starts the print queue.
  /// 1. For each sub-item, find the existing manufacturing queue entry if available
  /// 2. Fall back to building a new [ManufacturingQueueItem] with recipe-derived data
  /// 3. Add to [_pendingPrintJobs] and trigger [_processPrintQueue]
  void printOrderLabels(Order order) {
    final totSeq = order.items.length.toString().padLeft(2, '0');
    for (int i = 0; i < order.items.length; i++) {
      final seq = (i + 1).toString().padLeft(2, '0');
      final existingJob = _manufacturingQueue.firstWhere(
        (q) => q.orderNo == order.orderNo && q.subItemIndex == i,
        orElse: () {
          final menuName = order.items[i].menuName;
          final recipe = menuName.isNotEmpty ? _getRecipe(menuName).fold((_) => null, (r) => r) : null;
          final pKey = recipe?.productKey ?? '0';
          final dispenser = recipe?.dispenserData ?? 'N:0';
          return ManufacturingQueueItem(
            machineIp: NetworkConstants.cayeMachineIp,
            productKey: pKey,
            machineOrderNo: '${order.orderNo}.$seq',
            orderNo: order.orderNo,
            subItemIndex: i,
            qrData: '$dispenser|${order.orderNo}.$seq.$totSeq,pkey:$pKey',
          );
        },
      );
      _pendingPrintJobs.add(existingJob);
    }
    unawaited(this._processPrintQueue());
  }

  /// Cancels all stream subscriptions and releases machine/printer resources.
  /// Called from [KdsMainScreen.dispose] when the screen exits.
  @override
  Future<void> close() async {
    await _connectionSubscription?.cancel();
    await _barcodeScanSubscription?.cancel();
    await _pickupCompleteSubscription?.cancel();
    await _machineProgressSubscription?.cancel();
    await _printerStatusSubscription?.cancel();
    await _calibrationStatusSubscription?.cancel();
    _availabilityTimer?.cancel();
    _disposeMachine(null);
    _disposePrinter(null);
    _disconnectOrderSocket();
    return super.close();
  }
}
