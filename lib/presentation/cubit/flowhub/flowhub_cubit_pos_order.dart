part of 'flowhub_cubit.dart';

/// POS (Smaregi) orders from Flow Cloud (`pos-order` / `pos-order-ack`),
/// leader only. Messages are handled one at a time against the live orders,
/// and every ack goes out only after the change it reports is saved.
extension _FlowHubCubitPosOrderExtension on FlowHubCubit {
  /// Queues [message] behind the one being handled, so two copies of the
  /// same order can never both pass the duplicate check.
  void _handlePosOrder(PosOrderMessage message) {
    _posOrderQueue = _posOrderQueue
        .then((_) => _processPosOrder(message))
        .catchError((Object e) => Log.e('FlowHub', 'pos-order failed: $e'));
  }

  /// 1. Decides against the local order with the same orderNo (see
  ///    [DecidePosOrderUseCase]).
  /// 2. Applies the decision (create / cancel / tombstone) and saves it.
  /// 3. Acks. A failed decision sends no ack: the cloud resends.
  Future<void> _processPosOrder(PosOrderMessage message) async {
    if (isClosed) {
      return;
    }
    final Either<BaseException, PosOrderDecision> result =
        await _decidePosOrder((
          message: message,
          existing: _orderByNo(message.orderNo),
        ));
    final PosOrderDecision? decision = result.fold((BaseException e) {
      Log.e('FlowHub', 'pos-order ${message.orderNo} not decided: ${e.message}');
      return null;
    }, (PosOrderDecision d) => d);
    if (decision == null || isClosed) {
      return;
    }
    final PosOrderAck ack = switch (decision) {
      PosOrderAnswer(:final PosOrderAck ack) => ack,
      PosOrderCreate(:final Order order) => await _createPosOrder(order),
      PosOrderCancel(:final Order order) =>
        await _cancelPosOrder(order, message),
      PosOrderTombstone(:final DateTime cancelledAt) =>
        await _storePosOrderTombstone(message.orderNo, cancelledAt),
    };
    await _posOrders.ack(message, ack);
  }

  /// Creates the order like a kiosk order, then answers ACCEPTED.
  /// 1. receivedAt = now: this is the Hub's orderedAt (never orderTime).
  /// 2. One guidance-light color per cup; the POS menu names are kept (shown
  ///    on KDS as given).
  /// 3. Adds it to NEW, saves the live orders before acking, prints labels.
  Future<PosOrderAck> _createPosOrder(Order order) async {
    final DateTime now = DateTime.now();
    final Order created = order.copyWith(
      receivedAt: now,
      stateEnteredAt: now,
      items: order.items
          .map((SubItem item) => item.copyWith(ledColorHex: DrinkLedColors.next()))
          .toList(),
    );
    emit(state.copyWith(orders: <Order>[...state.orders, created]));
    await _persistLiveOrdersNow();
    printOrderLabels(created);
    Log.i(
      'FlowHub',
      'POS order ${created.orderNo} (${created.displayNo}) created: '
      '${created.items.length} item(s), '
      '${created.items.where((SubItem i) => i.manual).length} manual',
    );
    return PosOrderAck(status: PosOrderAckStatus.accepted, orderedAt: now);
  }

  /// Cancels [order], then answers CANCELLED with the stage it was in.
  /// 1. Sets cancelledAt / cancelledBy from the message (now when absent).
  /// 2. Drops its labels not printed yet and its cups still waiting in the
  ///    Caye queue (the cup being sent now, at the head, is left alone).
  /// 3. Saves; a cup already brewing or done raises the "cancelled at POS"
  ///    alert for staff.
  Future<PosOrderAck> _cancelPosOrder(
    Order order,
    PosOrderMessage message,
  ) async {
    final String stage = switch (order.currentTab) {
      OrderTab.newOrder => 'NEW',
      OrderTab.brew => 'BREWING',
      OrderTab.call => 'CALLED',
      OrderTab.done => 'DONE',
    };
    final Order cancelled = order.copyWith(
      cancelledAt: message.cancelledAt ?? DateTime.now(),
      cancelledBy: message.cancelledBy,
    );
    _pendingPrintJobs.removeWhere(
      (ManufacturingQueueItem job) => job.orderNo == order.orderNo,
    );
    for (int i = _manufacturingQueue.length - 1; i > 0; i--) {
      if (_manufacturingQueue[i].orderNo == order.orderNo) {
        _manufacturingQueue.removeAt(i);
      }
    }
    emit(state.copyWith(
      orders: state.orders
          .map((Order o) => o.orderNo == order.orderNo ? cancelled : o)
          .toList(),
      manufacturingQueueLength: _manufacturingQueue.length,
    ));
    await _persistLiveOrdersNow();
    Log.i('FlowHub', 'POS order ${order.orderNo} cancelled at stage $stage');
    if (stage != 'NEW') {
      _posCancelAlertController.add(
        'Order ${cancelled.displayName} was cancelled at the POS '
        '($stage) — check the cups already made.',
      );
    }
    return PosOrderAck(
      status: PosOrderAckStatus.cancelled,
      orderedAt: order.receivedAt,
      stage: stage,
    );
  }

  /// No such order yet: the CANCEL overtook its NEW. Stores a tombstone so
  /// the late NEW answers ALREADY_CANCELLED, then answers NOT_FOUND.
  Future<PosOrderAck> _storePosOrderTombstone(
    String orderNo,
    DateTime cancelledAt,
  ) async {
    await _posOrders.addTombstone(orderNo, cancelledAt);
    return const PosOrderAck(status: PosOrderAckStatus.notFound);
  }

  /// Saves the live orders now (not debounced) and records them for order
  /// sync: a pos-order ack may only report a change that survives a crash.
  Future<void> _persistLiveOrdersNow() async {
    _persistOrdersTimer?.cancel();
    final List<Order> orders = state.orders;
    await _saveLiveOrdersSnapshot(orders);
    _recordOrdersForSync(orders);
  }
}
