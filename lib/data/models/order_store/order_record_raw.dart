/// One row of the local `orders` table. An order is one row per orderNo
/// and orderedAt: kiosk numbers restart every day, so the same orderNo on
/// another day is another order (Flow Manager tells them apart the same
/// way).
class OrderRecordRaw {
  const OrderRecordRaw({
    this.id,
    required this.orderNo,
    required this.orderJson,
    required this.syncJson,
    required this.orderedAt,
    required this.version,
    required this.syncedVersion,
    required this.rejectedVersion,
    required this.updatedAt,
    required this.live,
  });

  factory OrderRecordRaw.fromRow(Map<String, Object?> row) => OrderRecordRaw(
    id: row['id'] as int?,
    orderNo: row['order_no'] as String? ?? '',
    orderJson: row['order_json'] as String? ?? '',
    syncJson: row['sync_json'] as String? ?? '',
    orderedAt: row['ordered_at'] as String? ?? '',
    version: row['version'] as int? ?? 0,
    syncedVersion: row['synced_version'] as int? ?? 0,
    rejectedVersion: row['rejected_version'] as int? ?? 0,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      row['updated_at'] as int? ?? 0,
    ),
    live: (row['live'] as int? ?? 0) == 1,
  );

  /// Row ID; null for an order not stored yet.
  final int? id;

  final String orderNo;

  /// The whole local order (`Order.toJson`), used to restore the board.
  final String orderJson;

  /// The `order` object of the sync message, as JSON text. Also how a
  /// change is detected: a different text means a new version.
  final String syncJson;

  /// The order's `orderedAt`, fixed at its first version: a changed value
  /// would create a second order in the cloud.
  final String orderedAt;

  /// Latest version; starts at 1, +1 on every change, never resets.
  final int version;

  /// Highest version Flow Manager acked (UPDATED or ALREADY_CURRENT).
  final int syncedVersion;

  /// Highest version Flow Manager rejected for good.
  final int rejectedVersion;

  /// When [version] last changed.
  final DateTime updatedAt;

  /// Whether the order is on the board now.
  final bool live;

  /// Whether [version] still waits for Flow Manager.
  bool get isPending => version > syncedVersion && version > rejectedVersion;

  /// The row's columns ([id] only when set).
  Map<String, Object?> toRow() => <String, Object?>{
    if (id != null) 'id': id,
    'order_no': orderNo,
    'order_json': orderJson,
    'sync_json': syncJson,
    'ordered_at': orderedAt,
    'version': version,
    'synced_version': syncedVersion,
    'rejected_version': rejectedVersion,
    'updated_at': updatedAt.millisecondsSinceEpoch,
    'live': live ? 1 : 0,
  };
}
