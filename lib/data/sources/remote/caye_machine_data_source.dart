import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/core/utils/log.dart';
import 'package:flowhub/data/sources/local/caye_key_data_source.dart';
import 'package:flowhub/domain/entities/index.dart';

abstract interface class ICayeMachineDataSource {
  Stream<ExtractionProgress> get progressStream;
  Stream<bool> get connectionStream;
  /// Current connection state as of the last connect/disconnect — unlike
  /// [connectionStream] (a broadcast stream, which only replays FUTURE
  /// transitions), this lets a freshly-created listener learn the state
  /// immediately without waiting for the next transition, which may never
  /// come if the connection was already established before it subscribed.
  bool get isConnected;

  Future<void> sendMakeCommand(String ip, String productKey, String orderNo);
  Future<void> sendCancelCommand(String ip, String productKey, String orderNo);
  Future<void> sendCheckAvailability(String ip, String productKey);
  Future<void> sendTimeSyncCommand(String ip);

  Future<void> sendRinsingCommand(String ip);
  Future<void> sendCleaningCommand(String ip, {int mode = 0});
  Future<void> sendQueryStatus(String ip);
  /// Queries the machine's brew history between [startTs] and [endTs]
  /// (Unix ms) — the machine responds with up to 100 of the most recent
  /// matching records as a 0x35 packet (`{"beverageList": [...]}`), which
  /// arrives via [progressStream] like any other machine response. Per the
  /// confirmed protocol spec, the body must NOT be empty — a start/end pair
  /// is required on every call.
  Future<void> sendExtractionHistory(String ip, {required int startTs, required int endTs});

  /// Persists [key] as the AES key used to encrypt/decrypt every packet sent
  /// to the Caye machine, replacing whatever was in effect — survives an app
  /// restart (see [ICayeKeyDataSource]). Each physical Caye unit uses its
  /// own key, so this is what the Caye Machine Control screen's Save button
  /// applies after swapping to a different physical machine.
  Future<void> setApiKey(String key);
  /// The AES key currently in effect — whatever was last saved via
  /// [setApiKey] (this session or a previous one), or the built-in default
  /// if none ever was.
  Future<String> get currentApiKey;

  void dispose();
}

@Singleton(as: ICayeMachineDataSource)
class CayeMachineDataSource implements ICayeMachineDataSource {
  static const String _tag = 'Caye';
  // Built-in fallback — used until an operator saves a real key via the
  // Caye Machine Control screen (see setApiKey), or forever if this unit
  // never needs one. Different physical Caye machines use different keys,
  // so this is only ever correct for whichever unit it happened to be
  // copied from.
  static const String _defaultHexKey = '7F7AD4F84BA40571506D798374932711';

  final ICayeKeyDataSource _keyDataSource;

  String _hexKey = _defaultHexKey;
  // Completes once the persisted key (if any) has been loaded from disk —
  // read by [currentApiKey] so a caller displaying "the current key" (e.g.
  // the Caye Machine Control screen, on open) waits for the real saved
  // value instead of racing it and briefly showing the built-in default.
  late final Future<void> _keyLoaded;

  CayeMachineDataSource(this._keyDataSource) {
    _keyLoaded = _loadSavedKey();
  }

  Future<void> _loadSavedKey() async {
    final saved = await _keyDataSource.readKey();
    if (saved != null && saved.isNotEmpty) {
      _hexKey = saved;
      Log.d(_tag, 'Loaded saved Caye API key');
    }
  }

  @override
  Future<void> setApiKey(String key) async {
    _hexKey = key;
    await _keyDataSource.saveKey(key);
    Log.d(_tag, 'Caye API key updated and saved');
  }

  @override
  Future<String> get currentApiKey async {
    await _keyLoaded;
    return _hexKey;
  }

  Socket? _socket;
  // Self-rescheduling chain, not a Timer.periodic tied to any one
  // connection — see _startHeartbeat's doc comment for why.
  Timer? _heartbeatChainTimer;
  String? _heartbeatIp;
  bool _isConnected = false;
  // Tracks an in-flight lazy-connect so two _sendPacket calls arriving
  // back-to-back while _socket is briefly null (e.g. right after a
  // disconnect) share the SAME connection attempt instead of each
  // independently racing to open their own — see _ensureConnected.
  Future<void>? _connectingFuture;

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  final StreamController<ExtractionProgress> _progressController =
      StreamController<ExtractionProgress>.broadcast();

  @override
  Stream<ExtractionProgress> get progressStream => _progressController.stream;

  @override
  Stream<bool> get connectionStream => _connectionController.stream;

  @override
  bool get isConnected => _isConnected;

  /// Encrypts a function code + body map into AES-CBC bytes with an 8-byte timestamp prefix.
  /// 1. Build 8-byte big-endian timestamp
  /// 2. Concatenate timestamp with JSON-encoded body (or timestamp only if body is empty)
  /// 3. Encrypt using AES-128-CBC with zero IV and PKCS7 padding
  Uint8List _encryptPayload(int functionCode, Map<String, dynamic> body) {
    final key = enc.Key.fromBase16(_hexKey);
    final iv = enc.IV(Uint8List(16));
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));

    final ByteData tsData = ByteData(8);
    tsData.setUint64(0, DateTime.now().millisecondsSinceEpoch, Endian.big);
    final Uint8List tsBytes = tsData.buffer.asUint8List();

    final List<int> payload = body.isEmpty
        ? tsBytes.toList()
        : [...tsBytes, ...utf8.encode(jsonEncode(body))];

    return encrypter.encryptBytes(payload, iv: iv).bytes;
  }

  /// Decrypts an AES-CBC encrypted payload and returns the JSON string after the 8-byte timestamp.
  /// Returns null if decryption fails or the decrypted length is too short to contain JSON.
  String? _decryptPayload(Uint8List encryptedData) {
    try {
      final key = enc.Key.fromBase16(_hexKey);
      final iv = enc.IV(Uint8List(16));
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));
      final decrypted = encrypter.decryptBytes(enc.Encrypted(encryptedData), iv: iv);
      if (decrypted.length <= 8) return null;
      return utf8.decode(decrypted.sublist(8));
    } catch (e) {
      Log.e(_tag, 'Decryption failed: $e');
      return null;
    }
  }

  /// Computes an XOR checksum over all bytes in [data].
  int _checksum(Uint8List data) {
    int cs = 0;
    for (final b in data) { cs ^= b; }
    return cs & 0xFF;
  }

  /// Opens a TCP connection to [ip]:31255 if not already connected, then sends a framed packet.
  /// 1. Connect socket on first call and start a heartbeat timer
  /// 2. Encrypt [body] with [functionCode] using [_encryptPayload]
  /// 3. Build packet: [0xCC, 0xAA, funcCode, 0x01, 0x01, lenHi, lenLo, ...encrypted, checksum, 0xFF, 0xEE]
  /// 4. Write packet bytes to the socket
  Future<void> _sendPacket(String ip, int functionCode, Map<String, dynamic> body) async {
    const int port = 31255;
    try {
      if (_socket == null) {
        await _ensureConnected(ip, port);
      }

      final Uint8List encrypted = _encryptPayload(functionCode, body);
      final builder = BytesBuilder()
        ..add([0xCC, 0xAA])
        ..addByte(functionCode)
        ..addByte(0x01)
        ..addByte(0x01)
        ..add(Uint8List(2)..buffer.asByteData().setUint16(0, encrypted.length, Endian.big))
        ..add(encrypted)
        ..addByte(_checksum(encrypted))
        ..add([0xFF, 0xEE]);

      _socket!.add(builder.toBytes());
      Log.d(_tag, '[Sent] 0x${functionCode.toRadixString(16)} | $body');
    } catch (e) {
      Log.e(_tag, 'Send error: $e');
      _handleDisconnect();
    }
  }

  /// Opens the TCP connection if one isn't already in flight — without this
  /// guard, two calls to [_sendPacket] arriving back-to-back while [_socket]
  /// is briefly null (e.g. right after a disconnect) would each
  /// independently see it as null and race to open their OWN separate TCP
  /// connection. That double-connect was seen in practice under the shot-
  /// test button's back-to-back polling (no gap between shots for a
  /// disconnect/reconnect to settle before the next send), and is exactly
  /// the kind of thing that can trip an embedded TCP stack into tearing one
  /// of the two connections back down.
  Future<void> _ensureConnected(String ip, int port) {
    final inFlight = _connectingFuture;
    if (inFlight != null) return inFlight;

    final future = () async {
      Log.d(_tag, 'Connecting to $ip:$port');
      _socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
      _isConnected = true;
      _connectionController.add(true);
      _socket!.listen(
        _handleIncoming,
        onDone: _handleDisconnect,
        onError: (_) => _handleDisconnect(),
      );
      _startHeartbeat(ip);
    }();
    _connectingFuture = future;
    return future.whenComplete(() => _connectingFuture = null);
  }

  /// Parses all Caye packets in a single TCP segment and emits [ExtractionProgress] for each.
  /// TCP may bundle multiple packets into one segment, so loop until the buffer is consumed.
  /// 1. Check remaining bytes cover the minimum packet size (10 bytes header + tail)
  /// 2. Validate magic header bytes [0xCC, 0xAA]; break on mismatch (malformed or incomplete)
  /// 3. Read dataLength and compute full packet boundary; break if buffer is incomplete
  /// 4. Decrypt and decode JSON body
  /// 5. Emit [ExtractionProgress] for known function codes (0x20, 0x22, 0x23, 0x24, 0x35)
  /// 6. Advance offset by full packet size and repeat
  void _handleIncoming(Uint8List data) {
    int offset = 0;
    while (offset < data.length) {
      if (data.length - offset < 10) break;
      if (data[offset] != 0xCC || data[offset + 1] != 0xAA) break;

      final int functionCode = data[offset + 2];
      final int dataLength =
          ByteData.sublistView(data, offset + 5, offset + 7).getUint16(0, Endian.big);
      final int packetEnd = offset + 7 + dataLength + 3;
      if (packetEnd > data.length) break;

      final Uint8List encryptedBody = data.sublist(offset + 7, offset + 7 + dataLength);
      final String? json = _decryptPayload(encryptedBody);

      if (json != null) {
        // Not an unconditional cast — a response can decrypt to valid JSON
        // that still isn't an object (seen live: sending the experimental
        // 0x40/restart code got back a payload that decoded to `null`,
        // which crashed the whole app here before this guard existed).
        // Whatever function code is misunderstood/malformed still gets
        // logged instead of taking down the app.
        final decodedRaw = jsonDecode(json);
        if (decodedRaw is! Map<String, dynamic>) {
          Log.w(_tag,
              '[Received] 0x${functionCode.toRadixString(16)} | non-object JSON, ignoring: $json');
        } else {
          final decoded = decodedRaw;
          if (const {0x20, 0x22, 0x23, 0x24, 0x35, 0x03, 0x12, 0x30, 0x31}
              .contains(functionCode)) {
            _progressController.add(ExtractionProgress(code: functionCode, data: decoded));
          }
          if (functionCode == 0x12) {
            Log.i(_tag, '[Rinsing Event Report] 0x12 | $json');
            // On failure only — flat errorCode string array, no per-code
            // status (see CayeFaultCode's class doc comment for why this
            // shape needs describe(), not describeEntry()).
            final errorCode = decoded['errorCode'];
            if (errorCode is List) {
              for (final code in errorCode) {
                Log.i(_tag, '[Rinsing Event Report] 0x12 fault: ${CayeFaultCode.describe(code.toString())}');
              }
            }
          } else if (functionCode == 0x03) {
            Log.i(_tag, '[Cleaning Event Report] 0x03 | $json');
          } else if (functionCode == 0x30) {
            final errors = decoded['errors'];
            if (errors is List) {
              for (final entry in errors) {
                if (entry is Map<String, dynamic>) {
                  final code = entry['code']?.toString() ?? '?';
                  final status = (entry['status'] as num?)?.toInt();
                  Log.i(_tag, '[Fault Report] 0x30 | ${CayeFaultCode.describeEntry(code, status)}');
                }
              }
            }
          } else if (functionCode == 0x31) {
            // Raw dump only, like 0x12/0x03 originally — the protocol doc
            // describes what this carries (cleaning/rinsing wait-or-progress
            // state, fault presence + list, overall brew-availability) but
            // not the actual JSON key names, so this needs a live response
            // first before it can be parsed/formatted the way 0x30 now is.
            Log.i(_tag, '[Query Running Status] 0x31 | $json');
          }
          Log.long(_tag, '[Received] 0x${functionCode.toRadixString(16)} | $json');
        }
      }

      offset = packetEnd;
    }
  }

  /// Keeps the coffee machine's session alive by resending a time-sync
  /// (0x00) command roughly every 60s, matching the protocol's own documented
  /// rule: the machine actively disconnects if it goes 3 minutes without one.
  /// Also syncs once immediately on every fresh (re)connect — waiting for the
  /// next scheduled tick would otherwise leave up to a full 60s gap before
  /// the machine's clock gets refreshed, and that gap matters for anything
  /// timestamp-sensitive sent right after a (re)connect: the replay-defense
  /// header on every packet gets rejected if FlowHub's and the machine's clocks
  /// drift past ~1 minute apart, and a 0x35 extraction-history query is
  /// filtered by the MACHINE's own (possibly stale) clock, not the caller's.
  ///
  /// This is a self-rescheduling chain (each send schedules the next one 60s
  /// later), not a Timer.periodic owned by one connection — and unlike the
  /// connection-scoped timer this replaces, [_handleDisconnect] does NOT
  /// cancel it. A dropped connection used to silently kill the only thing
  /// that could ever resend 0x00 again: nothing would revive it until some
  /// unrelated command (a brew, a manual reconnect tap) happened to come in
  /// on its own, which could leave the Device Management "off" indicator
  /// stuck indefinitely during a quiet stretch with no orders. Now the chain
  /// outlives any single connection — it keeps trying every 60s forever, and
  /// each attempt reconnects on its own (via [_sendPacket]'s
  /// `_socket == null` check) if the machine had dropped the session.
  void _startHeartbeat(String ip) {
    _heartbeatIp = ip;
    unawaited(sendTimeSyncCommand(ip));
    _heartbeatChainTimer ??= Timer(const Duration(seconds: 60), _sendScheduledHeartbeat);
  }

  void _sendScheduledHeartbeat() {
    final ip = _heartbeatIp;
    if (ip != null) {
      unawaited(sendTimeSyncCommand(ip));
    }
    _heartbeatChainTimer = Timer(const Duration(seconds: 60), _sendScheduledHeartbeat);
  }

  /// Destroys the TCP socket and emits disconnected state. Does NOT touch
  /// [_heartbeatChainTimer] — see its owning method's doc comment for why
  /// that has to keep running across a drop instead of dying with it.
  void _handleDisconnect() {
    _socket?.destroy();
    _socket = null;
    _isConnected = false;
    _connectionController.add(false);
    Log.d(_tag, 'Connection closed');
  }

  @override
  Future<void> sendTimeSyncCommand(String ip) => _sendPacket(ip, 0x00, {});

  @override
  Future<void> sendMakeCommand(String ip, String productKey, String orderNo) =>
      _sendPacket(ip, 0x20, {
        'func': 1,
        'params': {'productKey': productKey, 'orderNo': orderNo},
      });

  @override
  Future<void> sendCancelCommand(String ip, String productKey, String orderNo) =>
      _sendPacket(ip, 0x20, {
        'func': 0,
        'params': {'productKey': productKey, 'orderNo': orderNo},
      });

  @override
  Future<void> sendCheckAvailability(String ip, String productKey) =>
      _sendPacket(ip, 0x23, {'productKey': productKey});

  @override
  Future<void> sendRinsingCommand(String ip) => _sendPacket(ip, 0x10, {});

  @override
  Future<void> sendCleaningCommand(String ip, {int mode = 0}) =>
      _sendPacket(ip, 0x01, {'mode': mode});

  @override
  Future<void> sendQueryStatus(String ip) => _sendPacket(ip, 0x31, {});

  @override
  Future<void> sendExtractionHistory(String ip, {required int startTs, required int endTs}) =>
      _sendPacket(ip, 0x35, {'startTs': startTs, 'endTs': endTs});

  /// Closes the socket connection, stops the heartbeat chain for good, and
  /// closes all stream controllers.
  @override
  void dispose() {
    _heartbeatChainTimer?.cancel();
    _handleDisconnect();
    _progressController.close();
    _connectionController.close();
  }
}
