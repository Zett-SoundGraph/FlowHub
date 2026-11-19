import 'dart:async';

import 'package:flowhub/core/utils/log.dart';
import 'package:flowhub/data/sources/remote/cloud_mqtt_data_source.dart';
import 'package:flowhub/data/sources/remote/flow_manager_api_data_source.dart';
import 'package:flowhub/domain/entities/flow_installation/flow_app_update_progress.dart';
import 'package:flowhub/domain/entities/flow_installation/store_device.dart';
import 'package:flowhub/domain/entities/flow_installation/update_request_result.dart';
import 'package:flowhub/domain/repositories/flow_installation_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: FlowInstallationRepository)
class FlowInstallationRepositoryImpl implements FlowInstallationRepository {
  /// Lives as long as the app (lazy singleton): subscribes
  /// [_versionTopic] once and never cancels its listeners.
  FlowInstallationRepositoryImpl(this._api, this._mqtt) {
    _mqtt.subscribe(_versionTopic);
    _mqtt.messages
        .where((CloudMqttMessage m) => m.topic == _versionTopic)
        .listen((CloudMqttMessage m) {
          Log.i(_tag, 'Available versions: ${_versionSummary(m.json)}');
          _versionNotices.add(null);
        });
    _mqtt.connectionStream
        .where((bool connected) => connected)
        .listen((_) => _versionNotices.add(null));
  }

  static const String _tag = 'FlowInstallation';

  /// FlowManager's available Flow App versions (retained, global).
  static const String _versionTopic = 'flow/system/version';

  final IFlowManagerApiDataSource _api;
  final ICloudMqttDataSource _mqtt;
  final StreamController<void> _versionNotices =
      StreamController<void>.broadcast();

  @override
  Stream<void> get versionNotices => _versionNotices.stream;

  @override
  Future<StoreDevices> getStoreDevices(String storeId) async {
    final Map<String, dynamic> data = await _api.getDeviceState(storeId);
    final List<Object?> devices = (data['devices'] as List<Object?>?) ?? <Object?>[];
    return StoreDevices(
      pending: (data['pending'] as num?)?.toInt() ?? 0,
      devices: <StoreDevice>[
        for (final Object? item in devices)
          if (item is Map<String, dynamic>) _toDevice(item),
      ],
    );
  }

  @override
  Future<List<UpdateRequestResult>> requestUpdates(
    List<String> deviceIds,
  ) async {
    final Map<String, dynamic> data = await _api.requestUpdate(deviceIds);
    Log.i(
      _tag,
      'Update request: queued=${data['queued']} skipped=${data['skipped']} '
      'rejected=${data['rejected']}',
    );
    final List<Object?> results = (data['results'] as List<Object?>?) ?? <Object?>[];
    return <UpdateRequestResult>[
      for (final Object? item in results)
        if (item is Map<String, dynamic>)
          UpdateRequestResult(
            deviceId: _str(item['deviceId']),
            deviceName: _str(item['deviceName']),
            result: _str(item['result']),
            targetVersion: _str(item['targetVersion']),
            message: _str(item['message']),
          ),
    ];
  }

  /// 1. Subscribes `/flow/store/{storeId}/return` (leading slash, as
  ///    FlowUpdater publishes it).
  /// 2. Keeps only update reports (commandCode 100) and maps their `data`.
  @override
  Stream<FlowAppUpdateProgress> watchProgress(String storeId) {
    final String topic = '/flow/store/$storeId/return';
    _mqtt.subscribe(topic);
    return _mqtt.messages
        .where((CloudMqttMessage m) => m.topic == topic)
        .map((CloudMqttMessage m) => _toProgress(m.json))
        .where((FlowAppUpdateProgress? p) => p != null)
        .cast<FlowAppUpdateProgress>();
  }

  StoreDevice _toDevice(Map<String, dynamic> json) => StoreDevice(
    deviceId: _str(json['deviceId']),
    deviceName: _str(json['deviceName']),
    appType: _str(json['appType']),
    deviceStatus: _str(json['deviceStatus']),
    currentVersion: _str(json['currentVersion']),
    latestVersionId: (json['latestVersionId'] as num?)?.toInt(),
    latestVersion: _str(json['latestVersion']),
    releaseNote: _str(json['releaseNote']),
    updateAvailable: json['updateAvailable'] == true,
    updateStatus: _str(json['updateStatus']),
  );

  /// The MQ-2 envelope: `{requestId, commandCode: 100, data: {...}}`.
  /// Returns `null` for anything else on the topic.
  FlowAppUpdateProgress? _toProgress(Map<String, dynamic> json) {
    final Object? data = json['data'];
    if (data is! Map<String, dynamic>) return null;
    if (json['commandCode']?.toString() != '100') return null;
    final String deviceId = _str(data['deviceId']);
    final String state = _str(data['state']);
    if (deviceId.isEmpty || state.isEmpty) return null;
    return FlowAppUpdateProgress(
      deviceId: deviceId,
      requestId: _str(json['requestId']),
      seq: (data['seq'] as num?)?.toInt() ?? 0,
      state: state,
      progress: (data['progress'] as num?)?.toInt(),
      attempt: (data['attempt'] as num?)?.toInt(),
      maxAttempts: (data['maxAttempts'] as num?)?.toInt(),
      reason: data['reason'] as String?,
      waitReason: data['waitReason'] as String?,
      fromVersion: data['fromVersion'] as String?,
      targetVersion: data['targetVersion'] as String?,
      installedVersion: data['installedVersion'] as String?,
      rolledBack: data['rolledBack'] as bool?,
      occurredAt: DateTime.tryParse(_str(data['occurredAt']))?.toLocal(),
    );
  }

  /// `flowHub 0.33.261113.26111309, ...` for the apps that have a version
  /// (`{}` means none).
  static String _versionSummary(Map<String, dynamic> json) {
    final List<String> apps = <String>[
      for (final MapEntry<String, dynamic> e in json.entries)
        if (e.value is Map && (e.value as Map)['version'] != null)
          '${e.key} ${(e.value as Map)['version']}',
    ];
    return apps.isEmpty ? 'none' : apps.join(', ');
  }

  static String _str(Object? value) => value?.toString() ?? '';
}
