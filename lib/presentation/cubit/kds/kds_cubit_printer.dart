part of 'kds_cubit.dart';

extension _KdsCubitPrinterExtension on KdsCubit {
  /// Processes one job from the pending print queue and recurses until empty.
  /// 1. Return early if already printing or queue is empty
  /// 2. Resolve menu name, sequence numbers, recipe, and dispenser data for the task
  /// 3. Capture [OrderLabelWidget] to PNG bytes via [ScreenshotController]
  /// 4. Send bytes to [_printLabel] use case and log the result
  /// 5. After completion, process the next queued job if any
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

    final recipe = menuName.isNotEmpty ? _getRecipe(menuName).fold((_) => null, (r) => r) : null;
    final dispenserData = task.qrData.contains('|') ? task.qrData.split('|').first : 'N:0';

    try {
      final Uint8List captured = await _screenshotController.captureFromWidget(
        OrderLabelWidget(
          props: OrderLabelWidgetProps(
            orderNo: task.orderNo,
            sequence: seq,
            totalSequence: totSeq,
            menus: menuName.isNotEmpty ? [menuName] : [],
            qrData: task.qrData,
            recipe: recipe,
            dispenserData: dispenserData,
          ),
        ),
        pixelRatio: 1.0,
        delay: const Duration(milliseconds: 100),
      );
      (await _printLabel(captured)).fold(
        (e) => Log.e('Printer', 'Print failed: ${e.message}'),
        (_) => Log.d('Printer', 'Print complete — ${task.orderNo} $seq/$totSeq'),
      );
    } catch (e) {
      Log.e('Printer', 'Print error: $e');
    } finally {
      _isPrinting = false;
      if (_pendingPrintJobs.isNotEmpty) {
        unawaited(this._processPrintQueue());
      }
    }
  }

}
