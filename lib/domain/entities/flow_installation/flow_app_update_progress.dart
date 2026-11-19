/// One progress report of a Flow App update, published by the device's
/// FlowUpdater to `/flow/store/{storeId}/return` (MQ-2).
class FlowAppUpdateProgress {
  const FlowAppUpdateProgress({
    required this.deviceId,
    required this.requestId,
    required this.seq,
    required this.state,
    this.progress,
    this.attempt,
    this.maxAttempts,
    this.reason,
    this.waitReason,
    this.fromVersion,
    this.targetVersion,
    this.installedVersion,
    this.rolledBack,
    this.occurredAt,
  });

  final String deviceId;
  final String requestId;

  /// Report order; a retry goes from INSTALLING back to DOWNLOADING, so the
  /// latest report is the one with the highest seq.
  final int seq;

  /// RECEIVED | WAITING | DOWNLOADING | INSTALLING | COMPLETED | FAILED
  final String state;

  /// 0-100, while DOWNLOADING.
  final int? progress;
  final int? attempt;
  final int? maxAttempts;

  /// Why the request failed, or why the previous attempt did.
  final String? reason;

  /// Why it waits (e.g. `SERVING_ORDER`: the app is busy with orders).
  final String? waitReason;
  final String? fromVersion;
  final String? targetVersion;

  /// On COMPLETED and FAILED: what is installed now.
  final String? installedVersion;

  /// The last attempt put the previous version back.
  final bool? rolledBack;
  final DateTime? occurredAt;

  /// COMPLETED or FAILED: no more reports follow for this request.
  bool get isFinal => state == 'COMPLETED' || state == 'FAILED';
}
