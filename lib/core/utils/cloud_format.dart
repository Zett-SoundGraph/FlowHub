import 'dart:math';

/// Formatting helpers shared by the Flow Cloud MQTT payloads.
class CloudFormat {
  CloudFormat._();

  static final Random _random = Random.secure();

  /// Local time with its UTC offset and exactly 3 millisecond digits,
  /// truncated (e.g. `2026-08-28T08:17:36.118+09:00`) — the format every
  /// Flow Cloud timestamp field requires.
  static String timestamp(DateTime time) {
    final DateTime local = time.toLocal();
    final Duration offset = local.timeZoneOffset;
    final String sign = offset.isNegative ? '-' : '+';
    final int minutes = offset.inMinutes.abs();
    return '${_pad(local.year, 4)}-${_pad(local.month)}-${_pad(local.day)}'
        'T${_pad(local.hour)}:${_pad(local.minute)}:${_pad(local.second)}'
        '.${_pad(local.millisecond, 3)}'
        '$sign${_pad(minutes ~/ 60)}:${_pad(minutes % 60)}';
  }

  /// Nullable variant of [timestamp]: `null` stays `null` (never `""`).
  static String? timestampOrNull(DateTime? time) =>
      time == null ? null : timestamp(time);

  /// Random RFC 4122 version 4 UUID (e.g. `6f1c2e9a-7b1d-4c55-9f3e-2a8d1c0b7e41`).
  static String uuidV4() {
    final List<int> bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final String hex =
        bytes.map((int b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  static String _pad(int value, [int width = 2]) =>
      value.toString().padLeft(width, '0');
}
