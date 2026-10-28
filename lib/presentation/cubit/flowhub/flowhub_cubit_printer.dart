part of 'flowhub_cubit.dart';

extension _FlowHubCubitPrinterExtension on FlowHubCubit {
  /// Processes one job from the pending print queue. Does NOT recurse to the
  /// next job on its own — the printer only holds one label at a time, so
  /// the next job is only printed once [FlowHubCubit._handlePrinterStatus] sees
  /// this one physically peeled off (DETACHED). Printing ahead of that would
  /// let a single peel promote more than one sub-item to BREW, since the
  /// next label would already be sitting in [_awaitingDetachQueue] before
  /// the operator ever touched it.
  /// 1. Return early if already printing, queue is empty, or a previously
  ///    printed label is still awaiting its DETACHED signal — the printer
  ///    only holds one label at a time, so starting the next print before
  ///    the current one is physically removed would let two jobs sit in
  ///    [_awaitingDetachQueue] at once with nothing but print order to tell
  ///    them apart.
  /// 2. Resolve menu name, sequence numbers, recipe, and dispenser data for the task
  /// 3. Capture [OrderLabelWidget] to PNG bytes via [ScreenshotController]
  /// 4. Send bytes to [_printLabel] use case and log the result
  Future<void> _processPrintQueue() async {
    if (_isPrinting || _pendingPrintJobs.isEmpty || _awaitingDetachQueue.isNotEmpty) {
      return;
    }

    _isPrinting = true;
    final task = _pendingPrintJobs.removeAt(0);

    final orderIndex = state.orders.indexWhere((o) => o.orderNo == task.orderNo);
    final subItem = orderIndex != -1 && task.subItemIndex < state.orders[orderIndex].items.length
        ? state.orders[orderIndex].items[task.subItemIndex]
        : null;
    final menuName = subItem?.menuName ?? '';

    final String seq = (task.subItemIndex + 1).toString().padLeft(2, '0');
    final String totSeq = orderIndex != -1
        ? state.orders[orderIndex].items.length.toString().padLeft(2, '0')
        : '01';

    // The label never prints recipe data (unlike the order-list tags/recipe
    // popup) — just the customer's actual added-beyond-default options, in
    // "{name} {volume}g[ x{count}]" form (see GetLabelOptionsUseCase).
    final ingredients = labelOptionsFor(menuName, subItem?.selectedOptions ?? const []);

    try {
      final Uint8List captured = await _screenshotController.captureFromWidget(
        OrderLabelWidget(
          props: OrderLabelWidgetProps(
            orderNo: task.orderNo,
            sequence: seq,
            totalSequence: totSeq,
            menus: menuName.isNotEmpty ? [menuName] : [],
            qrData: task.qrData,
            ingredients: ingredients,
            version: subItem != null ? recipeVersionFor(subItem) ?? '' : '',
            temp: subItem?.temp ?? '',
          ),
        ),
        pixelRatio: 1.0,
        delay: const Duration(milliseconds: 100),
      );
      (await _printLabel(captured)).fold(
        (e) => Log.e('Printer', 'Print failed: ${e.message}'),
        (_) {
          _awaitingDetachQueue.add((
            orderNo: task.orderNo,
            subItemIndex: task.subItemIndex,
            sawAttached: false,
          ));
          // Queue is capped at length 1 by the gate above, so this print is
          // always the 0→1 transition — tell native to start forwarding
          // every poll tick until this job's DETACHED is resolved.
          unawaited(_setAwaitingDetach(true));
          Log.d('Printer', 'Print complete — ${task.orderNo} $seq/$totSeq');
        },
      );
    } catch (e) {
      Log.e('Printer', 'Print error: $e');
    } finally {
      _isPrinting = false;
    }
  }

}
