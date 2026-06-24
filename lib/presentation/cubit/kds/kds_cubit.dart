import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:kds/core/constants/network.dart';
import 'package:kds/domain/entities/index.dart';
import 'package:kds/domain/enums/order_status.dart';
import 'package:kds/domain/usecases/check_machine_availability_usecase.dart';
import 'package:kds/domain/usecases/complete_cooking_usecase.dart';
import 'package:kds/domain/usecases/complete_pickup_usecase.dart';
import 'package:kds/domain/usecases/connect_order_socket_usecase.dart';
import 'package:kds/domain/usecases/disconnect_order_socket_usecase.dart';
import 'package:kds/domain/usecases/dispose_machine_usecase.dart';
import 'package:kds/domain/usecases/dispose_printer_usecase.dart';
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
import 'package:kds/domain/usecases/get_recipe_usecase.dart';
import 'package:kds/presentation/widgets/order_label_widget.dart';
import 'package:screenshot/screenshot.dart';

import 'kds_state.dart';

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

  // ── 제조 큐 상태 (내부 뮤터블 필드 — KdsState 밖) ──────────────────────────
  final List<ManufacturingQueueItem> _manufacturingQueue = [];
  bool _isMachineBusy = false;
  bool _acceptMachinePackets = false;
  bool _isWaitingForCleanStart = false;
  bool _isRetrying = false;
  Timer? _availabilityTimer;

  // ── 프린터 큐 상태 ───────────────────────────────────────────────────────────
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

  void _init() {
    _connectionSubscription = _observeOrderConnection().listen((connected) {
      emit(state.copyWith(isConnected: connected));
    });
    _barcodeScanSubscription = _observeBarcodeScan().listen(_handleBarcodeScan);
    _pickupCompleteSubscription =
        _observePickupComplete().listen(_handlePickupComplete);
    _machineProgressSubscription =
        _observeMachineProgress().listen(_handleMachineProgress);
    _printerStatusSubscription =
        _observePrinterStatus().listen(_handlePrinterStatus);
    _calibrationStatusSubscription =
        _observeCalibrationStatus().listen(_handleCalibrationStatus);
    unawaited(_connectOrderSocket());
  }

  // ── 바코드 스캔 처리 ──────────────────────────────────────────────────────────

  void _handleBarcodeScan(String rawData) {
    debugPrint('📡 [바코드 수신] RAW: $rawData');
    try {
      String dataToProcess = rawData.trim();
      String orderNo = '';
      String pKey = '';
      String dispenserData = 'N:0';
      int? targetIndex;
      int shotCount = 0;

      if (dataToProcess.contains('|')) {
        final parts = dataToProcess.split('|');
        dispenserData = parts[0];
        final rightPart = parts.length > 1 ? parts[1] : '';

        if (rightPart.isNotEmpty) {
          final rightElements = rightPart.split(',');
          final fullOrderId = rightElements[0];

          final idParts = fullOrderId.split('.');
          orderNo = idParts[0];
          if (idParts.length >= 2) {
            targetIndex = (int.tryParse(idParts[1]) ?? 1) - 1;
          }

          for (final el in rightElements) {
            final lower = el.trim().toLowerCase();
            if (lower.startsWith('pkey:')) {
              pKey = el.split(':')[1];
            } else if (lower.startsWith('shot:')) {
              shotCount = int.tryParse(el.split(':')[1]) ?? 0;
            }
          }
        }
      } else {
        final decoded = utf8.decode(base64Decode(dataToProcess));
        final scanData = jsonDecode(decoded) as Map<String, dynamic>;
        orderNo = scanData['orderNo'] as String;
        pKey = scanData['items'][0]['pKey'].toString();
      }

      debugPrint('🎯 스캔 → 주문: $orderNo, pKey: $pKey, seq: $targetIndex, shot: $shotCount, dispenser: $dispenserData');

      if (orderNo.isEmpty || pKey.isEmpty) {
        debugPrint('⚠️ QR에 유효한 주문번호 또는 pKey가 없습니다.');
        return;
      }

      final orderIndex = state.orders.indexWhere((o) => o.orderNo == orderNo);
      if (orderIndex == -1) {
        debugPrint('⚠️ $orderNo번 주문을 목록에서 찾을 수 없습니다.');
        return;
      }

      final order = state.orders[orderIndex];
      final bool isTestOrder = orderNo.startsWith('9999') || orderNo.startsWith('9998');

      // 바코드 디스펜서가 N:0이면 CSV recipe fallback 사용
      String resolveDispenser(int itemIndex) {
        if (dispenserData != 'N:0') return dispenserData;
        final menuName = itemIndex < order.items.length ? order.items[itemIndex].menuName : '';
        final recipe = menuName.isNotEmpty ? _getRecipe(menuName) : null;
        final fallback = recipe?.dispenserData ?? 'N:0';
        if (fallback != 'N:0') debugPrint('🔄 디스펜서 fallback: $menuName → $fallback');
        return fallback;
      }

      if (targetIndex != null && targetIndex >= 0 && targetIndex < order.items.length) {
        final subItem = order.items[targetIndex];
        if (!isTestOrder && (subItem.status == OrderStatus.ready || subItem.isExtracting)) {
          debugPrint('🛡️ 이미 처리 중인 잔입니다 ($orderNo, seq ${targetIndex + 1})');
          return;
        }
        _startManufacturing(order, targetIndex, pKey, dispenserData: resolveDispenser(targetIndex), shotCount: shotCount);
      } else {
        for (int i = 0; i < order.items.length; i++) {
          final subItem = order.items[i];
          if (!isTestOrder && (subItem.status == OrderStatus.ready || subItem.isExtracting)) continue;
          _startManufacturing(order, i, pKey, dispenserData: resolveDispenser(i), shotCount: shotCount);
          break;
        }
      }
    } catch (e) {
      debugPrint('❌ 스캔 파싱 에러: $e');
    }
  }

  // ── 제조 큐 관리 ──────────────────────────────────────────────────────────────

  void _startManufacturing(
    Order order,
    int subItemIndex,
    String pKey, {
    String dispenserData = 'N:0',
    int shotCount = 0,
  }) {
    const String machineIp = NetworkConstants.cayeMachineIp;
    final String seq = (subItemIndex + 1).toString().padLeft(2, '0');
    final String totSeq = order.items.length.toString().padLeft(2, '0');
    final String machineOrderNo = '${order.orderNo}.$seq';
    final String qrData = '$dispenserData|${order.orderNo}.$seq.$totSeq,pkey:$pKey';

    // SubItem 상태를 '대기 중'으로 업데이트
    _updateSubItemByIndex(
      order.orderNo,
      subItemIndex,
      (s) => s.copyWith(
        isExtracting: true,
        progress: 0.0,
        isError: false,
        errorCode: null,
        status: OrderStatus.pending,
        currentStage: 'Pending',
        logs: ['⏳ Added to brewing queue... (pKey: $pKey${shotCount > 0 ? ' + $shotCount shot(s)' : ''})'],
      ),
    );

    _manufacturingQueue.add(ManufacturingQueueItem(
      machineIp: machineIp,
      productKey: pKey,
      machineOrderNo: machineOrderNo,
      orderNo: order.orderNo,
      subItemIndex: subItemIndex,
      qrData: qrData,
    ));

    for (int s = 0; s < shotCount; s++) {
      _manufacturingQueue.add(ManufacturingQueueItem(
        machineIp: machineIp,
        productKey: '1', // 에스프레소 pKey
        machineOrderNo: machineOrderNo,
        orderNo: order.orderNo,
        subItemIndex: subItemIndex,
        isExtraShot: true,
        qrData: qrData,
      ));
    }

    emit(state.copyWith(manufacturingQueueLength: _manufacturingQueue.length));

    if (!_isMachineBusy) {
      _isMachineBusy = true;
      _availabilityTimer?.cancel();
      _availabilityTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
        _checkNextTaskAvailability();
      });
      _checkNextTaskAvailability();
    }
  }

  void _checkNextTaskAvailability() {
    if (_manufacturingQueue.isEmpty) {
      _availabilityTimer?.cancel();
      _isMachineBusy = false;
      return;
    }
    final task = _manufacturingQueue.first;
    _updateSubItemByIndex(
      task.orderNo,
      task.subItemIndex,
      (s) => s.copyWith(currentStage: 'Checking machine status...'),
    );
    _checkMachineAvailability(task.machineIp, task.productKey);
  }

  void _processNextInQueue() {
    if (_manufacturingQueue.isEmpty) {
      _isMachineBusy = false;
      return;
    }
    _isMachineBusy = true;
    final task = _manufacturingQueue.first;
    _updateSubItemByIndex(
      task.orderNo,
      task.subItemIndex,
      (s) => s.copyWith(isExtracting: true),
      extraLog: '🚀 Brewing command sent (${task.machineOrderNo})',
    );
    _sendMakeCommand(task.machineIp, task.productKey, task.machineOrderNo);
  }

  void _advanceQueue() {
    if (_manufacturingQueue.isNotEmpty) _manufacturingQueue.removeAt(0);
    emit(state.copyWith(manufacturingQueueLength: _manufacturingQueue.length));

    if (_manufacturingQueue.isNotEmpty) {
      _availabilityTimer?.cancel();
      _availabilityTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
        _checkNextTaskAvailability();
      });
      _checkNextTaskAvailability();
    } else {
      _isMachineBusy = false;
    }
  }

  // ── 머신 진행 이벤트 처리 ─────────────────────────────────────────────────────

  void _handleMachineProgress(ExtractionProgress progress) {
    final data = progress.data;

    // 0x23 — 가용성 확인 응답
    if (progress.code == 0x23) {
      final int bevStatus = (data['beverageStatus'] as num?)?.toInt() ?? -1;
      if (bevStatus == 1 && (_availabilityTimer?.isActive == true)) {
        debugPrint('[Caye] 🟢 기기 준비 완료. 2초 후 제조 명령 전송');
        _availabilityTimer?.cancel();
        _availabilityTimer = null;

        if (_manufacturingQueue.isNotEmpty) {
          _updateSubItemByIndex(
            _manufacturingQueue.first.orderNo,
            _manufacturingQueue.first.subItemIndex,
            (s) => s.copyWith(currentStage: '준비 완료! 컵을 놓아주세요 (2초)'),
          );
        }
        Future.delayed(const Duration(seconds: 2), () {
          if (_manufacturingQueue.isNotEmpty) {
            _acceptMachinePackets = false;
            _processNextInQueue();
          }
        });
      } else {
        debugPrint('[Caye] 🔴 기기 바쁨 (beverageStatus: $bevStatus)');
      }
      return;
    }

    // 0x20 — 제조 명령 응답 (수락/거절)
    if (progress.code == 0x20) {
      if (data['result'] == 0) {
        if (!_isRetrying) {
          _isRetrying = true;
          Future.delayed(const Duration(milliseconds: 500), () {
            _isRetrying = false;
            if (_manufacturingQueue.isNotEmpty) {
              final task = _manufacturingQueue.first;
              _sendMakeCommand(task.machineIp, task.productKey, task.machineOrderNo);
            }
          });
        }
      } else if (data['result'] == 1) {
        _isRetrying = false;
        _acceptMachinePackets = true;
        _isWaitingForCleanStart = true;
      }
      return;
    }

    // 0x24 / 0x22 — 실시간 진행 / 완료
    if (_manufacturingQueue.isEmpty || !_acceptMachinePackets) return;

    // 이전 음료 잔여 패킷 방어
    if (_isWaitingForCleanStart) {
      if (progress.code == 0x24) {
        final double t = ((data['extractTime'] as num?) ?? 0).toDouble();
        final double p = ((data['powderWeight'] as num?) ?? 0).toDouble();
        if (t > 2.0 || p > 10.0) return;
        _isWaitingForCleanStart = false;
      } else if (progress.code == 0x22) {
        final int status = (data['status'] as num?)?.toInt() ?? 0;
        if (status == 6 || status == 99 || status == 3) return;
        if (status == 1) _isWaitingForCleanStart = false;
      }
    }

    _applyProgressToSubItem(_manufacturingQueue.first, progress);
  }

  void _applyProgressToSubItem(ManufacturingQueueItem task, ExtractionProgress progress) {
    final data = progress.data;

    if (progress.code == 0x24) {
      final double t = ((data['extractTime'] as num?) ?? 0).toDouble();
      final double tTarget = ((data['targetExtractTime'] as num?) ?? 1).toDouble();
      final double p = ((data['powderWeight'] as num?) ?? 0).toDouble();
      final double pTarget = ((data['targetPowderWeight'] as num?) ?? 1).toDouble();

      if (t > 0) {
        final double prog = (0.3 + (t / tTarget) * 0.65).clamp(0.0, 0.99);
        _updateSubItemByIndex(task.orderNo, task.subItemIndex,
            (s) => s.copyWith(progress: prog, currentStage: 'Extracting Espresso...'),
            extraLog: '💧 ${data['coffeeWaterQuantity']}ml / 🌡️ ${data['boilerTemp']}°C');
      } else if (p > 0) {
        final double prog = ((p / pTarget) * 0.3).clamp(0.0, 0.3);
        _updateSubItemByIndex(task.orderNo, task.subItemIndex,
            (s) => s.copyWith(progress: prog, currentStage: 'Grinding Beans...'),
            extraLog: '🫘 Grinding: ${p}g');
      } else {
        _updateSubItemByIndex(task.orderNo, task.subItemIndex,
            (s) => s.copyWith(progress: 0.05, currentStage: 'Dispensing Water...'),
            extraLog: '💧 Dispensing Water...');
      }
      return;
    }

    if (progress.code == 0x22) {
      final int status = (data['status'] as num?)?.toInt() ?? 0;

      if (status == 3) {
        // 완료
        _acceptMachinePackets = false;
        if (!task.isExtraShot) {
          _updateSubItemByIndex(task.orderNo, task.subItemIndex,
              (s) => s.copyWith(
                status: OrderStatus.ready,
                progress: 1.0,
                isExtracting: false,
                currentStage: '✅ Complete',
              ),
              extraLog: '✅ Brewing Complete');
          // 픽업 테이블로 ORDER_READY 자동 전송
          _autoSendOrderReady(task);
        } else {
          _updateSubItemByIndex(task.orderNo, task.subItemIndex,
              (s) => s.copyWith(isExtracting: false),
              extraLog: '✅ Extra Shot Complete');
        }
        _advanceQueue();
        return;
      }

      if (status == 99 || status == 6) {
        // 에러
        _acceptMachinePackets = false;
        final dynamic errRaw = data['errorCode'];
        final String? errorCode = (errRaw is List && errRaw.isNotEmpty)
            ? errRaw.join(', ')
            : errRaw?.toString();
        _updateSubItemByIndex(task.orderNo, task.subItemIndex,
            (s) => s.copyWith(isError: true, isExtracting: false, errorCode: errorCode),
            extraLog: '❌ Error: $errorCode');
        _advanceQueue();
        return;
      }

      _updateSubItemByIndex(task.orderNo, task.subItemIndex,
          (s) => s.copyWith(isExtracting: status == 1));
    }
  }

  // 브루 완료 시 픽업 테이블로 ORDER_READY 자동 전송
  Future<void> _autoSendOrderReady(ManufacturingQueueItem task) async {
    final orderIndex = state.orders.indexWhere((o) => o.orderNo == task.orderNo);
    if (orderIndex == -1) return;
    final order = state.orders[orderIndex];
    if (task.subItemIndex >= order.items.length) return;
    final subItem = order.items[task.subItemIndex];
    await _completeCooking((order: order, subItem: subItem));
    // 라벨 인쇄는 수동 인쇄 버튼(printOrderLabels)에서만 수행 — 완료 시 재인쇄 없음
  }

  // ── 프린터 상태 + 인쇄 큐 ────────────────────────────────────────────────────

  void _handlePrinterStatus(bool attached) {
    emit(state.copyWith(isLabelAttached: attached));
  }

  void _handleCalibrationStatus(String status) {
    emit(state.copyWith(isCalibrating: true));
    debugPrint('[Calibration] 상태: $status');
  }

  Future<void> _processPrintQueue() async {
    if (_isPrinting || _pendingPrintJobs.isEmpty) return;

    _isPrinting = true;
    final task = _pendingPrintJobs.removeAt(0);

    final orderIndex = state.orders.indexWhere((o) => o.orderNo == task.orderNo);
    final menuName = orderIndex != -1 && task.subItemIndex < state.orders[orderIndex].items.length
        ? state.orders[orderIndex].items[task.subItemIndex].menuName
        : '';

    final String seq = (task.subItemIndex + 1).toString().padLeft(2, '0');
    final String totSeq = orderIndex != -1
        ? state.orders[orderIndex].items.length.toString().padLeft(2, '0')
        : '01';

    final recipe = menuName.isNotEmpty ? _getRecipe(menuName) : null;
    final dispenserData = task.qrData.contains('|') ? task.qrData.split('|').first : 'N:0';

    try {
      final Uint8List captured = await _screenshotController.captureFromWidget(
        OrderLabelWidget(
          orderNo: task.orderNo,
          sequence: seq,
          totalSequence: totSeq,
          menus: menuName.isNotEmpty ? [menuName] : [],
          qrData: task.qrData,
          recipe: recipe,
          dispenserData: dispenserData,
        ),
        pixelRatio: 1.0,
        delay: const Duration(milliseconds: 100),
      );
      await _printLabel(captured);
      debugPrint('[Printer] ✅ 인쇄 완료 — ${task.orderNo}번 $seq/$totSeq');
    } catch (e) {
      debugPrint('[Printer] ❌ 인쇄 실패: $e');
    } finally {
      _isPrinting = false;
      // 남은 잡이 있으면 계속 처리
      if (_pendingPrintJobs.isNotEmpty) {
        _processPrintQueue();
      }
    }
  }

  // ── 상태 업데이트 헬퍼 ───────────────────────────────────────────────────────

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

  // ── 소켓/픽업 이벤트 ──────────────────────────────────────────────────────────

  void _handlePickupComplete(({String orderNo, String menuName}) event) {
    final updatedOrders =
        state.orders.where((o) => o.orderNo != event.orderNo).toList();
    emit(state.copyWith(orders: updatedOrders));
    debugPrint('✅ 픽업 완료 — ${event.orderNo}번 제거');
  }

  // ── 공개 메서드 ──────────────────────────────────────────────────────────────

  void cancelBrewing(String orderNo) {
    if (_manufacturingQueue.isEmpty) return;
    final task = _manufacturingQueue.first;
    if (task.orderNo != orderNo) return;
    unawaited(_sendCancelCommand(task.machineIp, task.productKey, task.machineOrderNo));
    _updateSubItemByIndex(
      orderNo,
      task.subItemIndex,
      (s) => s.copyWith(isExtracting: false, isError: false),
      extraLog: '🛑 Cancelled by user',
    );
    _manufacturingQueue.removeAt(0);
    emit(state.copyWith(manufacturingQueueLength: _manufacturingQueue.length));
    _isMachineBusy = false;
    _availabilityTimer?.cancel();
  }

  void startCalibration(double height) {
    _startCalibration(height);
    emit(state.copyWith(isCalibrating: true));
  }

  void stopCalibration() => emit(state.copyWith(isCalibrating: false));

  // 주문카드의 수동 인쇄 버튼: 해당 주문의 모든 SubItem을 인쇄 큐에 추가
  void printOrderLabels(Order order) {
    final totSeq = order.items.length.toString().padLeft(2, '0');
    for (int i = 0; i < order.items.length; i++) {
      final seq = (i + 1).toString().padLeft(2, '0');

      // 이미 제조 큐에 있는 잡이면 그대로 사용 (qrData에 dispenser 이미 포함됨)
      final existingJob = _manufacturingQueue.firstWhere(
        (q) => q.orderNo == order.orderNo && q.subItemIndex == i,
        orElse: () {
          final menuName = order.items[i].menuName;
          final recipe = menuName.isNotEmpty ? _getRecipe(menuName) : null;
          final pKey = recipe?.productKey ?? '0';
          // 메뉴별 디스펜서 데이터: CSV column[11] 파싱값 사용 (예: Banana_Syrup:20)
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
    _processPrintQueue();
  }

  Future<bool> completeCooking(Order order, SubItem subItem) async {
    final result = await _completeCooking((order: order, subItem: subItem));
    return result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        return false;
      },
      (ok) {
        if (!ok) {
          emit(state.copyWith(errorMessage: '제조 완료 처리에 실패했습니다.'));
          return false;
        }
        final subItemIndex = order.items.indexOf(subItem);
        if (subItemIndex != -1) {
          _updateSubItemByIndex(order.orderNo, subItemIndex,
              (s) => s.copyWith(status: OrderStatus.ready, progress: 1.0, currentStage: '✅ Complete'));
        }
        emit(state.copyWith(errorMessage: null));
        return true;
      },
    );
  }

  Future<bool> completePickup(Order order) async {
    final result = await _completePickup(order);
    return result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        return false;
      },
      (ok) {
        if (!ok) {
          emit(state.copyWith(errorMessage: '픽업 완료 처리에 실패했습니다.'));
          return false;
        }
        final updatedOrders =
            state.orders.where((o) => o.orderNo != order.orderNo).toList();
        emit(state.copyWith(orders: updatedOrders, errorMessage: null));
        return true;
      },
    );
  }

  @override
  Future<void> close() async {
    await _connectionSubscription?.cancel();
    await _barcodeScanSubscription?.cancel();
    await _pickupCompleteSubscription?.cancel();
    await _machineProgressSubscription?.cancel();
    await _printerStatusSubscription?.cancel();
    await _calibrationStatusSubscription?.cancel();
    _availabilityTimer?.cancel();
    _disposeMachine();
    _disposePrinter();
    _disconnectOrderSocket();
    return super.close();
  }
}
