/// An order version Flow Manager refused for good (`REJECTED`): the
/// snapshot can never be stored, so that version is not sent again. The
/// order's next version is sent normally.
class OrderSyncRejection {
  const OrderSyncRejection({
    required this.orderNo,
    required this.version,
    required this.error,
  });

  final String orderNo;
  final int version;

  /// Flow Manager's reject reason (e.g. `MISSING_FIELD`); empty when none.
  final String error;

  @override
  String toString() => 'OrderSyncRejection($orderNo v$version $error)';
}
