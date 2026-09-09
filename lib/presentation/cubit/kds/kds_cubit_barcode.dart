part of 'kds_cubit.dart';

extension _KdsCubitBarcodeExtension on KdsCubit {
  /// Parses a raw barcode string and routes it to [_startManufacturing].
  /// 1. Detect pipe-delimited format (dispenser|orderNo.seq,pkey:X) or Base64 JSON
  /// 2. Extract orderNo, pKey, targetIndex, shotCount, dispenserData
  /// 3. Validate extracted fields — return early if invalid or order not found
  /// 4. Guard against re-processing an already-extracting sub-item
  /// 5. Resolve dispenser data from CSV recipe if not present in scan
  /// 6. Delegate to [_startManufacturing] for the target sub-item
  void _handleBarcodeScan(String rawData) {
    Log.d('KDS', 'Barcode received: $rawData');
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
            }
            // Extra-shot QR parsing was a temporary addition for continuous-extraction
            // testing and is disabled — shotCount stays 0.
            // else if (lower.startsWith('shot:')) {
            //   shotCount = int.tryParse(el.split(':')[1]) ?? 0;
            // }
          }
        }
      }
      // Base64-encoded JSON scan format is unused — no code generates this format
      // (printed QR labels are always pipe-delimited, see order_label_widget.dart).
      // else {
      //   final decoded = utf8.decode(base64Decode(dataToProcess));
      //   final scanData = jsonDecode(decoded) as Map<String, dynamic>;
      //   orderNo = scanData['orderNo'] as String;
      //   pKey = scanData['items'][0]['pKey'].toString();
      // }

      Log.d('KDS', 'Scan parsed — order: $orderNo, pKey: $pKey, seq: $targetIndex, shot: $shotCount, dispenser: $dispenserData');

      if (orderNo.isEmpty || pKey.isEmpty) {
        Log.w('KDS', 'Invalid scan: missing orderNo or pKey');
        return;
      }

      final orderIndex = state.orders.indexWhere((o) => o.orderNo == orderNo);
      if (orderIndex == -1) {
        Log.w('KDS', 'Order $orderNo not found in list');
        return;
      }

      final order = state.orders[orderIndex];
      final bool isTestOrder = orderNo.startsWith('9999') || orderNo.startsWith('9998');

      // Falls back to CSV recipe dispenser data when the scan contains N:0.
      String resolveDispenser(int itemIndex) {
        if (dispenserData != 'N:0') return dispenserData;
        final menuName = itemIndex < order.items.length ? order.items[itemIndex].menuName : '';
        final recipe = menuName.isNotEmpty ? _getRecipe(menuName).fold((_) => null, (r) => r) : null;
        final fallback = recipe?.dispenserData ?? 'N:0';
        if (fallback != 'N:0') Log.d('KDS', 'Dispenser fallback: $menuName → $fallback');
        return fallback;
      }

      if (targetIndex != null && targetIndex >= 0 && targetIndex < order.items.length) {
        final subItem = order.items[targetIndex];
        if (!isTestOrder && (subItem.status == OrderStatus.ready || subItem.isExtracting)) {
          Log.w('KDS', 'Item already processing ($orderNo, seq ${targetIndex + 1})');
          return;
        }
        this._startManufacturing(order, targetIndex, pKey, dispenserData: resolveDispenser(targetIndex), shotCount: shotCount);
      } else {
        for (int i = 0; i < order.items.length; i++) {
          final subItem = order.items[i];
          if (!isTestOrder && (subItem.status == OrderStatus.ready || subItem.isExtracting)) continue;
          this._startManufacturing(order, i, pKey, dispenserData: resolveDispenser(i), shotCount: shotCount);
          break;
        }
      }
    } catch (e) {
      Log.e('KDS', 'Scan parse error: $e');
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
    const String machineIp = NetworkConstants.cayeMachineIp;
    final String seq = (subItemIndex + 1).toString().padLeft(2, '0');
    final String totSeq = order.items.length.toString().padLeft(2, '0');
    final String machineOrderNo = '${order.orderNo}.$seq';
    final String qrData = '$dispenserData|${order.orderNo}.$seq.$totSeq,pkey:$pKey';

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
