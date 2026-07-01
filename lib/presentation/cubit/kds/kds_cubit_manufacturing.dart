part of 'kds_cubit.dart';

extension _KdsCubitManufacturingExtension on KdsCubit {
  /// Polls the Caye machine for availability before sending a brew command.
  /// 1. Return early and mark machine idle if queue is empty
  /// 2. Update sub-item stage to 'Checking machine status...'
  /// 3. Send availability check command to the machine
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
    unawaited(_checkMachineAvailability((ip: task.machineIp, productKey: task.productKey)));
  }

  /// Sends the brew make command for the first item in the manufacturing queue.
  /// 1. Return early and mark machine idle if queue is empty
  /// 2. Update sub-item UI to extracting state with a log entry
  /// 3. Send make command to the Caye machine
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
      extraLog: 'Brewing command sent (${task.machineOrderNo})',
    );
    unawaited(_sendMakeCommand((ip: task.machineIp, productKey: task.productKey, orderNo: task.machineOrderNo)));
  }

  /// Removes the completed head of the queue and starts processing the next item.
  /// 1. Remove the first queue item
  /// 2. Emit the updated queue length
  /// 3. If items remain: restart the availability timer for the next task
  /// 4. If queue is empty: mark machine as idle
  void _advanceQueue() {
    if (_manufacturingQueue.isNotEmpty) _manufacturingQueue.removeAt(0);
    emit(state.copyWith(manufacturingQueueLength: _manufacturingQueue.length));

    if (_manufacturingQueue.isNotEmpty) {
      _availabilityTimer?.cancel();
      _availabilityTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
        this._checkNextTaskAvailability();
      });
      this._checkNextTaskAvailability();
    } else {
      _isMachineBusy = false;
    }
  }

  /// Routes Caye machine progress packets to the appropriate handler.
  /// 1. 0x23 (availability check response): if machine ready, delay 2s then send brew command
  /// 2. 0x20 (make command response): handle accept (result=1) or retry (result=0)
  /// 3. 0x24 / 0x22 (progress / completion): guard stale packets, then apply to sub-item
  void _handleMachineProgress(ExtractionProgress progress) {
    final data = progress.data;

    if (progress.code == 0x23) {
      final int bevStatus = (data['beverageStatus'] as num?)?.toInt() ?? -1;
      if (bevStatus == 1 && (_availabilityTimer?.isActive == true)) {
        Log.d('Caye', 'Machine ready — sending brew command in 2s');
        _availabilityTimer?.cancel();
        _availabilityTimer = null;

        if (_manufacturingQueue.isNotEmpty) {
          _updateSubItemByIndex(
            _manufacturingQueue.first.orderNo,
            _manufacturingQueue.first.subItemIndex,
            (s) => s.copyWith(currentStage: 'Ready — place cup (2s)'),
          );
        }
        Future.delayed(const Duration(seconds: 2), () {
          if (_manufacturingQueue.isNotEmpty) {
            _acceptMachinePackets = false;
            this._processNextInQueue();
          }
        });
      } else {
        Log.d('Caye', 'Machine busy (beverageStatus: $bevStatus)');
      }
      return;
    }

    if (progress.code == 0x20) {
      if (data['result'] == 0) {
        if (!_isRetrying) {
          _isRetrying = true;
          Future.delayed(const Duration(milliseconds: 500), () {
            _isRetrying = false;
            if (_manufacturingQueue.isNotEmpty) {
              final task = _manufacturingQueue.first;
              unawaited(_sendMakeCommand((ip: task.machineIp, productKey: task.productKey, orderNo: task.machineOrderNo)));
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

    if (_manufacturingQueue.isEmpty || !_acceptMachinePackets) return;

    // Discard stale packets from the previous brew until a clean start is detected.
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

    this._applyProgressToSubItem(_manufacturingQueue.first, progress);
  }

  /// Translates a raw progress packet into sub-item UI state updates.
  /// 1. 0x24 (realtime progress): map extractTime or powderWeight to a [0, 0.99] progress value
  /// 2. 0x22 status=3 (complete): mark sub-item ready, trigger order-ready broadcast
  /// 3. 0x22 status=99/6 (error): mark sub-item as errored with error code
  /// 4. 0x22 status=1 (started): mark sub-item as extracting
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
            extraLog: '${data['coffeeWaterQuantity']}ml / ${data['boilerTemp']}°C');
      } else if (p > 0) {
        final double prog = ((p / pTarget) * 0.3).clamp(0.0, 0.3);
        _updateSubItemByIndex(task.orderNo, task.subItemIndex,
            (s) => s.copyWith(progress: prog, currentStage: 'Grinding Beans...'),
            extraLog: 'Grinding: ${p}g');
      } else {
        _updateSubItemByIndex(task.orderNo, task.subItemIndex,
            (s) => s.copyWith(progress: 0.05, currentStage: 'Dispensing Water...'),
            extraLog: 'Dispensing Water...');
      }
      return;
    }

    if (progress.code == 0x22) {
      final int status = (data['status'] as num?)?.toInt() ?? 0;

      if (status == 3) {
        _acceptMachinePackets = false;
        if (!task.isExtraShot) {
          _updateSubItemByIndex(task.orderNo, task.subItemIndex,
              (s) => s.copyWith(
                status: OrderStatus.ready,
                progress: 1.0,
                isExtracting: false,
                currentStage: 'Complete',
              ),
              extraLog: 'Brewing complete');
          unawaited(this._autoSendOrderReady(task));
        } else {
          _updateSubItemByIndex(task.orderNo, task.subItemIndex,
              (s) => s.copyWith(isExtracting: false),
              extraLog: 'Extra shot complete');
        }
        this._advanceQueue();
        return;
      }

      if (status == 99 || status == 6) {
        _acceptMachinePackets = false;
        final dynamic errRaw = data['errorCode'];
        final String? errorCode = (errRaw is List && errRaw.isNotEmpty)
            ? errRaw.join(', ')
            : errRaw?.toString();
        _updateSubItemByIndex(task.orderNo, task.subItemIndex,
            (s) => s.copyWith(isError: true, isExtracting: false, errorCode: errorCode),
            extraLog: 'Error: $errorCode');
        this._advanceQueue();
        return;
      }

      _updateSubItemByIndex(task.orderNo, task.subItemIndex,
          (s) => s.copyWith(isExtracting: status == 1));
    }
  }

  /// Broadcasts ORDER_READY to the pickup table when a brew completes.
  /// 1. Look up the order and sub-item from current state
  /// 2. Call [_completeCooking] use case
  /// 3. Log any failure — the queue has already advanced, so no retry
  Future<void> _autoSendOrderReady(ManufacturingQueueItem task) async {
    final orderIndex = state.orders.indexWhere((o) => o.orderNo == task.orderNo);
    if (orderIndex == -1) return;
    final order = state.orders[orderIndex];
    if (task.subItemIndex >= order.items.length) return;
    final subItem = order.items[task.subItemIndex];
    (await _completeCooking((order: order, subItem: subItem))).fold(
      (e) => Log.e('KDS', 'Auto order-ready failed for ${task.orderNo}: ${e.message}'),
      (_) {},
    );
  }
}
