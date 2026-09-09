part of 'kds_cubit.dart';

extension _KdsCubitBarcodeExtension on KdsCubit {
  /// Parses the pipe-delimited label QR shared by every scan station (order
  /// AND complete alike scan the same printed cup label) —
  /// `dispenserData|orderNo.seq.totSeq,pkey:X` (see order_label_widget.dart).
  /// Returns null if the string doesn't match this format at all.
  ({String orderNo, int? seq, String pKey, String dispenserData})?
  _parseLabelScan(String rawData) {
    final dataToProcess = rawData.trim();
    if (!dataToProcess.contains('|')) return null;

    final parts = dataToProcess.split('|');
    final dispenserData = parts[0];
    final rightPart = parts.length > 1 ? parts[1] : '';
    if (rightPart.isEmpty) return null;

    final rightElements = rightPart.split(',');
    final fullOrderId = rightElements[0];

    final idParts = fullOrderId.split('.');
    final orderNo = idParts[0];
    int? seq;
    if (idParts.length >= 2) {
      seq = (int.tryParse(idParts[1]) ?? 1) - 1;
    }

    String pKey = '';
    for (final el in rightElements) {
      final lower = el.trim().toLowerCase();
      if (lower.startsWith('pkey:')) {
        pKey = el.split(':')[1];
      }
    }

    if (orderNo.isEmpty) return null;
    return (orderNo: orderNo, seq: seq, pKey: pKey, dispenserData: dispenserData);
  }

  /// Parses a raw order-station scan and routes it to [_startManufacturing].
  /// 1. Parse the pipe-delimited label (or Base64 JSON, currently unused)
  /// 2. Validate extracted fields — return early if invalid or order not found
  /// 3. Guard against re-processing an already-extracting sub-item
  /// 4. Delegate to [_startManufacturing] for the target sub-item
  void _handleBarcodeScan(String rawData) {
    Log.d('KDS', 'Barcode received: $rawData');
    try {
      // Base64-encoded JSON scan format is unused — no code generates this format
      // (printed QR labels are always pipe-delimited, see order_label_widget.dart).
      // else {
      //   final decoded = utf8.decode(base64Decode(dataToProcess));
      //   final scanData = jsonDecode(decoded) as Map<String, dynamic>;
      //   orderNo = scanData['orderNo'] as String;
      //   pKey = scanData['items'][0]['pKey'].toString();
      // }
      final parsed = _parseLabelScan(rawData);
      final orderNo = parsed?.orderNo ?? '';
      final targetIndex = parsed?.seq;
      final pKey = parsed?.pKey ?? '';
      final dispenserData = parsed?.dispenserData ?? 'N:0';
      // Extra-shot QR parsing was a temporary addition for continuous-extraction
      // testing and is disabled — shotCount stays 0.
      const shotCount = 0;

      Log.d('KDS', 'Scan parsed — order: $orderNo, pKey: $pKey, seq: $targetIndex, shot: $shotCount, dispenser: $dispenserData');

      if (orderNo.isEmpty || pKey.isEmpty) {
        Log.w('KDS', 'Invalid scan: missing orderNo or pKey');
        return;
      }

      final orderIndex = state.orders.indexWhere(
        (o) => o.orderNo == orderNo || _qrOrderNo(o.orderNo) == orderNo,
      );
      if (orderIndex == -1) {
        Log.w('KDS', 'Order $orderNo not found in list');
        return;
      }

      final order = state.orders[orderIndex];
      final bool isTestOrder = orderNo.startsWith('9999') || orderNo.startsWith('9998');

      if (targetIndex != null && targetIndex >= 0 && targetIndex < order.items.length) {
        final subItem = order.items[targetIndex];
        if (!isTestOrder &&
            (subItem.status == OrderStatus.ready ||
                this._isQueuedForManufacturing(order.orderNo, targetIndex))) {
          Log.w('KDS', 'Item already processing ($orderNo, seq ${targetIndex + 1})');
          return;
        }
        this._startManufacturing(order, targetIndex, pKey, dispenserData: dispenserData, shotCount: shotCount);
      } else {
        for (int i = 0; i < order.items.length; i++) {
          final subItem = order.items[i];
          if (!isTestOrder &&
              (subItem.status == OrderStatus.ready || this._isQueuedForManufacturing(order.orderNo, i))) {
            continue;
          }
          this._startManufacturing(order, i, pKey, dispenserData: dispenserData, shotCount: shotCount);
          break;
        }
      }
    } catch (e) {
      Log.e('KDS', 'Scan parse error: $e');
    }
  }

  /// Parses a raw complete-station scan and marks that specific sub-item
  /// ready (Call-eligible). This — not Caye's own 0x22 completion signal —
  /// is now the single source of truth for "this drink is actually done"
  /// across every production type (Caye-only, Nudof-only, and combo alike),
  /// since it's the only signal that exists for all three. See
  /// [_applyProgressToSubItem]'s status==3 branch for what Caye's own
  /// signal still does instead (queue bookkeeping only).
  void _handleQrComplete(String rawData) {
    Log.d('KDS', 'Complete scan received: $rawData');
    try {
      final parsed = _parseLabelScan(rawData);
      if (parsed == null || parsed.seq == null) {
        Log.w('KDS', 'Invalid complete scan: missing orderNo or seq');
        return;
      }
      final scannedOrderNo = parsed.orderNo;
      final targetIndex = parsed.seq!;

      final orderIndex = state.orders.indexWhere(
        (o) => o.orderNo == scannedOrderNo || _qrOrderNo(o.orderNo) == scannedOrderNo,
      );
      if (orderIndex == -1) {
        Log.w('KDS', 'Complete scan: order $scannedOrderNo not found');
        return;
      }
      final order = state.orders[orderIndex];
      if (targetIndex < 0 || targetIndex >= order.items.length) {
        Log.w('KDS', 'Complete scan: seq ${targetIndex + 1} out of range for ${order.orderNo}');
        return;
      }

      _updateSubItemByIndex(
        order.orderNo,
        targetIndex,
        (s) => s.copyWith(
          status: OrderStatus.ready,
          progress: 1.0,
          isExtracting: false,
          currentStage: 'Complete',
          // Stop the estimated-time gauge timer — otherwise the next tick
          // would recompute from the (now stale) phase fields and drag this
          // back down below 1.0 (see _tickGaugePhases).
          phaseStartedAt: null,
        ),
        extraLog: 'Complete QR scanned',
      );
      unawaited(this._autoSendOrderReady(order.orderNo, targetIndex));
    } catch (e) {
      Log.e('KDS', 'Complete scan parse error: $e');
    }
  }

  /// Enqueues a brew task (and optional extra shots) and starts the availability check loop.
  /// 1. Build machineOrderNo, qrData, and update sub-item UI to Pending
  /// 2. Push the main task onto [_manufacturingQueue]
  /// 3. Push extra-shot tasks for each additional shot
  /// 4. Emit updated queue length
  /// 5. If machine is idle, start the periodic availability check timer
  void _startManufacturing(
    Order order,
    int subItemIndex,
    String pKey, {
    String dispenserData = 'N:0',
    int shotCount = 0,
  }) {
    final String machineIp = NetworkConstants.cayeMachineIp;
    final String seq = (subItemIndex + 1).toString().padLeft(2, '0');
    final String totSeq = order.items.length.toString().padLeft(2, '0');
    final String machineOrderNo = '${order.orderNo}.$seq';
    final String qrData = '$dispenserData|${_qrOrderNo(order.orderNo)}.$seq.$totSeq,pkey:$pKey';

    // This scan is the Nudof→Caye handoff for a combo item — Nudof's
    // estimated-time phase (started at label-DETACH) ends here, snapping to
    // exactly 0.25 as the floor the Caye phase's own estimated-time gauge
    // will start from once the real 0x22 status=1 signal arrives (see
    // _applyProgressToSubItem) — that phase isn't started here since the
    // machine may still be busy with another queued item. Caye-only items
    // never ran a Nudof phase, so their floor is just the default 0.0.
    final isCombo = subItemIndex >= 0 &&
        subItemIndex < order.items.length &&
        _recipeTimingFor(order.items[subItemIndex]).productionType == ProductionType.combo;

    _updateSubItemByIndex(
      order.orderNo,
      subItemIndex,
      (s) => s.copyWith(
        isExtracting: true,
        progress: isCombo ? 0.25 : 0.0,
        isError: false,
        errorCode: null,
        status: OrderStatus.pending,
        currentStage: 'Pending',
        phaseStartedAt: null,
        phaseStartProgress: isCombo ? 0.25 : s.phaseStartProgress,
        logs: ['Added to brewing queue (pKey: $pKey${shotCount > 0 ? ' + $shotCount shot(s)' : ''})'],
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
        productKey: '1',
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
        this._checkNextTaskAvailability();
      });
      this._checkNextTaskAvailability();
    }
  }
}
