/// Ack statuses of `pos-order-ack`.
class PosOrderAckStatus {
  PosOrderAckStatus._();

  static const String accepted = 'ACCEPTED';
  static const String duplicate = 'DUPLICATE';
  static const String alreadyCancelled = 'ALREADY_CANCELLED';
  static const String expired = 'EXPIRED';
  static const String rejected = 'REJECTED';
  static const String cancelled = 'CANCELLED';
  static const String notFound = 'NOT_FOUND';
}

/// Error codes of a REJECTED `pos-order-ack`.
class PosOrderAckError {
  PosOrderAckError._();

  static const String unsupportedSchemaVersion = 'UNSUPPORTED_SCHEMA_VERSION';
  static const String storeMismatch = 'STORE_MISMATCH';
  static const String missingField = 'MISSING_FIELD';
  static const String fieldTooLong = 'FIELD_TOO_LONG';
  static const String invalidTimestamp = 'INVALID_TIMESTAMP';
}

/// The Hub's answer to one `pos-order` message.
class PosOrderAck {
  const PosOrderAck({
    required this.status,
    this.orderedAt,
    this.stage,
    this.error,
  });

  final String status;

  /// The Hub's own orderedAt (its receivedAt); required on ACCEPTED and
  /// DUPLICATE, set on a CANCEL ack when known.
  final DateTime? orderedAt;

  /// CANCEL ack only: NEW, BREWING, CALLED or DONE.
  final String? stage;

  /// REJECTED only: an error code.
  final String? error;

  @override
  String toString() => 'PosOrderAck($status'
      '${stage == null ? '' : ', stage=$stage'}'
      '${error == null ? '' : ', error=$error'})';
}
