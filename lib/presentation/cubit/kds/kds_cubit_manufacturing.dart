part of 'kds_cubit.dart';

extension _KdsCubitManufacturingExtension on KdsCubit {
  /// Whether [orderNo]'s sub-item at [subItemIndex] is already sitting in the
  /// Caye queue (brewing now, or waiting behind another item) — the correct
  /// "already processing" signal for a fresh order-station scan. NOT the
  /// same as `isExtracting`, which the label-DETACH handler already sets
  /// the moment the printer releases the label — well before the operator
  /// has scanned it at all — so checking that instead would (and did) block
  /// every order-scan from ever calling [_startManufacturing].
  bool _isQueuedForManufacturing(String orderNo, int subItemIndex) => _manufacturingQueue
      .any((q) => q.orderNo == orderNo && q.subItemIndex == subItemIndex);

  /// Polls the Caye machine for availability before sending a brew command.
  /// 1. Return early and mark machine idle if queue is empty
  /// 2. Update sub-item stage to 'Checking machine status...'
  /// 3. Send availability check (0x23), then — only once that send has
  ///    finished — general running-status query (0x31): 0x23 answers "can
  ///    THIS recipe be made right now", 0x31 answers "what's the machine's
  ///    overall state" (see _sendQueryStatus's doc comment). Sequenced
  ///    rather than fired together — two near-simultaneous writes were
  ///    observed to trip the machine into closing the TCP connection under
  ///    the shot-test button's back-to-back 1s polling (no gap between
  ///    shots to let the machine catch up); sequencing removes that overlap
  ///    without adding any artificial wait. 0x31 is additionally skipped
  ///    entirely for shot-test items — it's observational only, never
  ///    required to progress the queue, so dropping it halves the request
  ///    rate during the test for free.
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
    unawaited(
      _checkMachineAvailability((ip: task.machineIp, productKey: task.productKey)).then((_) {
        if (task.orderNo != _shotTestOrderNo) {
          unawaited(_sendQueryStatus(task.machineIp));
        }
      }),
    );
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
      // Bottom-bar PB.BB.0003 trigger — the actual make command being sent
      // to the machine, not just this task reaching the head of the
      // software queue (which may have happened well before this, if the
      // machine was busy with an earlier item).
      (s) => s.copyWith(isExtracting: true, stage: ProductionStage.cayeCommandSent),
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
  /// 1. 0x30/0x31/0x12/0x03 (fault/status/rinsing/cleaning): publish to MQTT
  ///    unconditionally — these are machine-level events independent of
  ///    whether a brew task happens to be queued, unlike 0x22/0x24 below.
  /// 2. 0x23 (availability check response): if machine ready, delay 2s then send brew command
  ///    (delay skipped for items marked skipReadyDelay — see [startConsecutiveShotTest])
  /// 3. 0x20 (make command response): handle accept (result=1) or retry (result=0)
  /// 4. 0x24 / 0x22 (progress / completion): guard stale packets, then apply to sub-item
  void _handleMachineProgress(ExtractionProgress progress) {
    final data = progress.data;

    if (progress.code == 0x30) {
      _publishCayeFaultReport(data);
      return;
    }
    if (progress.code == 0x31) {
      _publishCayeStatusSnapshot(data);
      return;
    }
    if (progress.code == 0x12) {
      _publishCayeRinsingEvent(data);
      return;
    }
    if (progress.code == 0x03) {
      _publishCayeCleaningEvent(data);
      return;
    }

    if (progress.code == 0x23) {
      final int bevStatus = (data['beverageStatus'] as num?)?.toInt() ?? -1;
      if (bevStatus == 1 && (_availabilityTimer?.isActive == true)) {
        _availabilityTimer?.cancel();
        _availabilityTimer = null;

        // The consecutive-shot test button marks its queue items
        // skipReadyDelay — no real cup is being placed between shots, so
        // there's nothing to wait for (see ManufacturingQueueItem.skipReadyDelay).
        final skipDelay =
            _manufacturingQueue.isNotEmpty && _manufacturingQueue.first.skipReadyDelay;

        if (_manufacturingQueue.isNotEmpty && !skipDelay) {
          _updateSubItemByIndex(
            _manufacturingQueue.first.orderNo,
            _manufacturingQueue.first.subItemIndex,
            (s) => s.copyWith(currentStage: 'Ready — place cup (2s)'),
          );
        }

        if (skipDelay) {
          Log.d('Caye', 'Machine ready — sending brew command immediately (ready-delay skipped)');
          if (_manufacturingQueue.isNotEmpty) {
            _acceptMachinePackets = false;
            this._processNextInQueue();
          }
        } else {
          Log.d('Caye', 'Machine ready — sending brew command in 2s');
          Future.delayed(const Duration(seconds: 2), () {
            if (_manufacturingQueue.isNotEmpty) {
              _acceptMachinePackets = false;
              this._processNextInQueue();
            }
          });
        }
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
  /// 1. 0x24 (realtime telemetry): espresso-only (extractTime/powderWeight are 0 for
  ///    any other Caye recipe), so this is display-text-only now — NOT the progress
  ///    driver, since a non-espresso recipe would otherwise sit at 0 until Caye's
  ///    completion signal, then jump straight to 100%. The actual gauge for every
  ///    Caye recipe (espresso or not) is the same estimated-time phase engine Nudof
  ///    uses (see _tickGaugePhases), started below on the real 0x22 status=1 signal.
  /// 2. 0x22 status=1 (started): starts the Caye phase's estimated-time gauge —
  ///    guarded so a repeated status=1 ping mid-brew doesn't restart the timer
  /// 3. 0x22 status=3 (brewing physically done): snaps progress to 0.99 immediately
  ///    (don't wait for the estimate to catch up if the real brew finished early),
  ///    stops the phase timer — final 1.0 is still only set by the complete-QR scan
  /// 4. 0x22 status=99/6 (error): mark sub-item as errored, stop the phase timer
  void _applyProgressToSubItem(ManufacturingQueueItem task, ExtractionProgress progress) {
    final data = progress.data;

    if (progress.code == 0x24) {
      final double t = ((data['extractTime'] as num?) ?? 0).toDouble();
      final double p = ((data['powderWeight'] as num?) ?? 0).toDouble();

      String stage;
      String extraLog;
      if (t > 0) {
        stage = 'Extracting Espresso...';
        extraLog = '${data['coffeeWaterQuantity']}ml / ${data['boilerTemp']}°C';
      } else if (p > 0) {
        stage = 'Grinding Beans...';
        extraLog = 'Grinding: ${p}g';
      } else {
        stage = 'Dispensing Water...';
        extraLog = 'Dispensing Water...';
      }
      _updateSubItemByIndex(task.orderNo, task.subItemIndex,
          (s) => s.copyWith(currentStage: stage), extraLog: extraLog);
      return;
    }

    if (progress.code == 0x22) {
      final int status = (data['status'] as num?)?.toInt() ?? 0;

      if (status == 3) {
        _acceptMachinePackets = false;
        if (!task.isExtraShot) {
          // Caye's own completion signal no longer marks the sub-item ready
          // by itself — it only means the machine physically finished, not
          // "confirmed done and ready for the customer." That's decided by
          // the complete-QR scan instead (_handleQrComplete in
          // kds_cubit_barcode.dart), which is the single source of truth
          // for ready/Call across every production type (Caye-only,
          // Nudof-only, and combo alike — only the QR scan exists for all
          // three). isExtracting deliberately stays true here so the gauge
          // keeps reading "still brewing" until that scan actually happens.
          _updateSubItemByIndex(task.orderNo, task.subItemIndex,
              (s) => s.copyWith(
                    currentStage: 'Brewing complete — awaiting scan',
                    progress: 0.99,
                    phaseStartedAt: null,
                    stage: ProductionStage.cayeComplete,
                  ),
              extraLog: 'Brewing complete — awaiting scan');
        } else {
          _updateSubItemByIndex(task.orderNo, task.subItemIndex,
              (s) => s.copyWith(isExtracting: false, phaseStartedAt: null),
              extraLog: 'Extra shot complete');
        }
        if (task.orderNo == _shotTestOrderNo) this._recordShotTestCompletion();
        this._advanceQueue();
        return;
      }

      if (status == 99 || status == 6) {
        _acceptMachinePackets = false;
        // Flat errorCode string array, no per-code status — same shape
        // 0x12 (Rinsing Event) uses on failure (see CayeFaultCode's class
        // doc comment); the packet's own `status` above already describes
        // THIS operation's outcome, not each code's individual state.
        final dynamic errRaw = data['errorCode'];
        final String? errorCode = (errRaw is List && errRaw.isNotEmpty)
            ? errRaw.map((c) => CayeFaultCode.describe(c.toString())).join(', ')
            : errRaw != null
                ? CayeFaultCode.describe(errRaw.toString())
                : null;
        _updateSubItemByIndex(task.orderNo, task.subItemIndex,
            (s) => s.copyWith(
                  isError: true,
                  isExtracting: false,
                  errorCode: errorCode,
                  phaseStartedAt: null,
                  stage: ProductionStage.cayeFailed,
                ),
            extraLog: 'Error: $errorCode');
        if (task.orderNo == _shotTestOrderNo) this._recordShotTestCompletion();
        this._advanceQueue();
        return;
      }

      _updateSubItemByIndex(task.orderNo, task.subItemIndex, (s) {
        if (status != 1 || s.phaseStartedAt != null) {
          return s.copyWith(isExtracting: status == 1);
        }
        // Real start signal confirmed — begin the Caye phase's estimated-time
        // gauge from whatever floor this item already has (0.0 for Caye-only,
        // 0.25 for a combo item whose Nudof phase already handed off).
        final timing = _recipeTimingFor(s);
        return s.copyWith(
          isExtracting: true,
          phaseStartedAt: DateTime.now(),
          phaseTargetProgress: 0.99,
          phaseDurationSeconds: timing.cayeSeconds,
          // Bottom-bar PB.BB.0004 trigger — the real 0x22 status=1 signal.
          stage: ProductionStage.cayeExtracting,
        );
      });
    }
  }

  /// Publishes a 0x30 Fault Report to `beta/flowhub/caye/fault` — each entry
  /// pre-formatted via [CayeFaultCode.describeEntry] so a subscriber never
  /// needs its own copy of the E/S/W lookup table. No-op if `errors` is
  /// missing/empty/malformed.
  void _publishCayeFaultReport(Map<String, dynamic> data) {
    final errorsRaw = data['errors'];
    if (errorsRaw is! List) return;
    final entries = errorsRaw.whereType<Map<String, dynamic>>().map((entry) {
      final code = entry['code']?.toString() ?? '';
      final status = (entry['status'] as num?)?.toInt() ?? 0;
      return CayeFaultEntry(
        code: code,
        status: status,
        summary: CayeFaultCode.describeEntry(code, status),
      );
    }).toList();
    if (entries.isEmpty) return;
    final version = _nextLeaderUpdateVersion();
    unawaited(_publishCayeFault(CayeFaultMessage(
      eventId: '${NetworkConstants.mqttDeviceId}-caye-fault-$version',
      version: version,
      errors: entries,
    )));
  }

  /// Publishes a 0x31 Query Running Status response to
  /// `beta/flowhub/caye/status` — raw passthrough since the real field shape
  /// isn't confirmed yet (see CayeMachineDataSource._handleIncoming's 0x31
  /// branch); once it is, this can be tightened into real typed fields.
  void _publishCayeStatusSnapshot(Map<String, dynamic> data) {
    final version = _nextLeaderUpdateVersion();
    unawaited(_publishCayeStatus(CayeStatusMessage(
      eventId: '${NetworkConstants.mqttDeviceId}-caye-status-$version',
      version: version,
      data: data,
    )));
  }

  /// Publishes a 0x12 Rinsing Event Report to `beta/flowhub/caye/rinsing`.
  void _publishCayeRinsingEvent(Map<String, dynamic> data) {
    unawaited(_publishCayeRinsing(_toCayeEventMessage('rinsing', data)));
  }

  /// Publishes a 0x03 Cleaning Event Report to `beta/flowhub/caye/cleaning`.
  void _publishCayeCleaningEvent(Map<String, dynamic> data) {
    unawaited(_publishCayeCleaning(_toCayeEventMessage('cleaning', data)));
  }

  /// Shared shape builder for 0x12/0x03 — both carry the same
  /// {status, errorCode[]} fields on the wire (see CayeMachineDataSource).
  CayeEventMessage _toCayeEventMessage(String kind, Map<String, dynamic> data) {
    final status = (data['status'] as num?)?.toInt() ?? 0;
    final errorCodeRaw = data['errorCode'];
    final faults = errorCodeRaw is List
        ? errorCodeRaw.map((c) => CayeFaultCode.describe(c.toString())).toList()
        : <String>[];
    final version = _nextLeaderUpdateVersion();
    return CayeEventMessage(
      eventId: '${NetworkConstants.mqttDeviceId}-caye-$kind-$version',
      version: version,
      status: status,
      faults: faults,
    );
  }

  /// Broadcasts ORDER_READY to the pickup table when a drink is confirmed
  /// complete (now via [_handleQrComplete], not Caye's own signal).
  /// 1. Look up the order and sub-item from current state
  /// 2. Call [_completeCooking] use case
  /// 3. Log any failure
  Future<void> _autoSendOrderReady(String orderNo, int subItemIndex) async {
    final orderIndex = state.orders.indexWhere((o) => o.orderNo == orderNo);
    if (orderIndex == -1) return;
    final order = state.orders[orderIndex];
    if (subItemIndex >= order.items.length) return;
    final subItem = order.items[subItemIndex];
    (await _completeCooking((order: order, subItem: subItem))).fold(
      (e) => Log.e('KDS', 'Auto order-ready failed for $orderNo: ${e.message}'),
      (_) {},
    );
  }
}
