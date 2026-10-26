import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Durable, append-only record of every order-lifecycle MQTT message (kiosk
/// order → ... → pickup complete, plus the board/kiosk/leader sync broadcasts
/// that carry order state) — deliberately NOT device status/heartbeat/
/// liveness traffic (nudof, WLED, Caye fault/status, system heartbeat), which
/// is excluded at each call site in [MqttDataSource] instead of here, so the
/// included/excluded topic list stays visible right next to the code that
/// actually publishes/receives each one.
///
/// Built so this file alone can answer "what happened, in what order, with
/// what payload" for one specific order — e.g. for the Message Hub team's
/// request to see a full Kiosk→PickupTable order-flow trace with real
/// payloads. Once Flow Manager (cloud) ingestion exists, forwarding each
/// record there is a one-line addition inside [_write] — no call site that
/// calls [log] needs to change for that.
///
/// Mirrors pickup_table's DiagLogger: daily file, external storage (so it's
/// adb-pullable without root — internal storage via
/// getApplicationDocumentsDirectory needs root/run-as), write-chain
/// serialization (a bare writeAsString(mode: append) under concurrent calls
/// can interleave bytes mid-line), 7-day retention.
class MqttOrderAuditLogger {
  MqttOrderAuditLogger._();

  static Directory? _dir;
  static String? _lastDate;
  static const int _retentionDays = 7;
  static final RegExp _logFilePattern =
      RegExp(r'^mqtt_order_audit_(\d{4})-(\d{2})-(\d{2})\.jsonl$');

  static Future<void> init() async {
    try {
      _dir = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      await _cleanupOldLogs();
    } catch (_) {
      _dir = null;
    }
  }

  static String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Future<void> _cleanupOldLogs() async {
    final dir = _dir;
    if (dir == null) return;
    try {
      final cutoff =
          DateTime.now().subtract(const Duration(days: _retentionDays));
      for (final entry in dir.listSync()) {
        if (entry is! File) continue;
        final name = entry.uri.pathSegments.last;
        final match = _logFilePattern.firstMatch(name);
        if (match == null) continue;
        final fileDate = DateTime(
          int.parse(match.group(1)!),
          int.parse(match.group(2)!),
          int.parse(match.group(3)!),
        );
        if (fileDate.isBefore(cutoff)) {
          await entry.delete();
        }
      }
    } catch (_) {
      // Cleanup failure is non-fatal — retried next time the date rolls over.
    }
  }

  // Serializes all writes so concurrent publish/receive calls (common — e.g.
  // an incoming kiosk order can trigger a leader+board+kiosk update publish
  // in the same tick) never interleave bytes within the file. See
  // pickup_table's DiagLogger for the real corruption bug this pattern fixes.
  static Future<void> _writeChain = Future<void>.value();

  // leader/update + board/update + kiosk/update re-fire on EVERY FlowHubState
  // emit — including a brewing item's progress bar ticking every ~0.5s (see
  // FlowHubCubit._broadcastLeaderUpdate's doc comment: "every single state
  // change... gets synced automatically"). The real-time MQTT publish needs
  // that — followers/boards must track progress smoothly — but the audit
  // log doesn't: a human reading it back for one order's flow doesn't need a
  // new line every 0.5s just because progress inched from 0.248 to 0.249.
  // So only the FILE WRITE is throttled to "did anything meaningfully
  // change", keyed per topic; the actual publish/receive call that triggered
  // [log] already happened before this and is never delayed or skipped.
  static final Map<String, String> _lastFingerprintByTopic = {};

  /// Strips fields that change on every call without reflecting a real state
  /// change (eventId, version — both just a fresh timestamp-derived counter
  /// each publish) and rounds every double to 2 decimals (progress is a
  /// 0.0–1.0 fraction, so this is a 1% granularity) so animation-smoothing
  /// ticks collapse to "unchanged" until progress actually moves a visible
  /// amount.
  static Object? _normalizeForDedup(Object? value) {
    if (value is Map) {
      return <String, Object?>{
        for (final entry in value.entries)
          if (entry.key != 'eventId' && entry.key != 'version')
            entry.key.toString(): _normalizeForDedup(entry.value),
      };
    }
    if (value is List) {
      return value.map(_normalizeForDedup).toList();
    }
    if (value is double) {
      return (value * 100).round() / 100;
    }
    return value;
  }

  /// [direction] is 'in' (received) or 'out' (published by this device).
  /// [orderNo] is recorded exactly as that topic's own payload expresses it
  /// (full letter-prefixed/sub-item-suffixed form, e.g. "K1042" or
  /// "K1042.01") — never normalized/stripped, since the channel prefix and
  /// the sub-item suffix are both meaningful on their own. Pass null when a
  /// message genuinely isn't about one single order (e.g. a full-state sync
  /// broadcast covering every order at once).
  static Future<void> log({
    required String topic,
    required String direction,
    String? orderNo,
    required Object? payload,
  }) {
    final next =
        _writeChain.then((_) => _write(topic, direction, orderNo, payload));
    _writeChain = next;
    return next;
  }

  static Future<void> _write(
    String topic,
    String direction,
    String? orderNo,
    Object? payload,
  ) async {
    final dir = _dir;
    if (dir == null) return;
    try {
      final fingerprint = jsonEncode(_normalizeForDedup(payload));
      if (_lastFingerprintByTopic[topic] == fingerprint) {
        return; // Nothing meaningfully different from the last line written for this topic.
      }
      _lastFingerprintByTopic[topic] = fingerprint;

      final today = _dateStr(DateTime.now());
      if (_lastDate != today) {
        _lastDate = today;
        await _cleanupOldLogs(); // Once per day (on date rollover), not every write.
      }
      final file = File('${dir.path}/mqtt_order_audit_$today.jsonl');
      final record = <String, Object?>{
        'timestamp': DateTime.now().toIso8601String(),
        'direction': direction,
        'topic': topic,
        'orderNo': orderNo,
        'payload': payload,
      };
      await file.writeAsString(
        '${jsonEncode(record)}\n',
        mode: FileMode.append,
        flush: true,
      );

      // TODO(cloud): once Flow Manager ingestion exists, forward `record`
      // here too — e.g. `await _cloudSender?.send(record);`. No call site
      // of [log] needs to change for that.
    } catch (_) {
      // Audit logging failure must never affect the real MQTT flow.
    }
  }
}
