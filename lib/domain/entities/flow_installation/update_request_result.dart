/// FlowManager's answer for one device of an update request
/// (`POST /api/v2/rest/store/version/update`).
class UpdateRequestResult {
  const UpdateRequestResult({
    required this.deviceId,
    required this.deviceName,
    required this.result,
    required this.targetVersion,
    required this.message,
  });

  final String deviceId;
  final String deviceName;

  /// QUEUED (sent to the device) | SKIPPED | REJECTED
  final String result;
  final String targetVersion;

  /// FlowManager's reason, mainly for SKIPPED / REJECTED.
  final String message;

  bool get isQueued => result == 'QUEUED';
}
