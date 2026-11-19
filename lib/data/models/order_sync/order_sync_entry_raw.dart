/// Order sync state of one order, kept on disk by the order sync outbox.
class OrderSyncEntryRaw {
  OrderSyncEntryRaw({
    required this.orderNo,
    required this.orderedAt,
    required this.version,
    required this.syncedVersion,
    required this.digest,
    required this.order,
    required this.updatedAt,
  });

  factory OrderSyncEntryRaw.fromJson(Map<String, dynamic> json) =>
      OrderSyncEntryRaw(
        orderNo: json['orderNo'] as String? ?? '',
        orderedAt: json['orderedAt'] as String? ?? '',
        version: (json['version'] as num?)?.toInt() ?? 0,
        syncedVersion: (json['syncedVersion'] as num?)?.toInt() ?? 0,
        digest: json['digest'] as String? ?? '',
        order: (json['order'] as Map<String, dynamic>?) ?? <String, dynamic>{},
        updatedAt:
            DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );

  final String orderNo;

  /// The order's `orderedAt`, fixed at its first version: a changed value
  /// would create a second order in the cloud.
  final String orderedAt;

  /// Latest version recorded; starts at 1, +1 on every change, never resets.
  int version;

  /// Highest version the cloud acked (UPDATED or ALREADY_CURRENT).
  int syncedVersion;

  /// The order snapshot as JSON text, used to detect a change.
  String digest;

  /// The `order` object of the latest version.
  Map<String, dynamic> order;

  /// When [version] last changed.
  DateTime updatedAt;

  /// Whether [version] still waits for the cloud's ack.
  bool get isPending => version > syncedVersion;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'orderNo': orderNo,
    'orderedAt': orderedAt,
    'version': version,
    'syncedVersion': syncedVersion,
    'digest': digest,
    'order': order,
    'updatedAt': updatedAt.toIso8601String(),
  };
}
