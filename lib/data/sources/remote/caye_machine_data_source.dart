import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:injectable/injectable.dart' hide Order;
import 'package:kds/core/utils/log.dart';
import 'package:kds/domain/entities/index.dart';

abstract interface class ICayeMachineDataSource {
  Stream<ExtractionProgress> get progressStream;
  Stream<bool> get connectionStream;

  Future<void> sendMakeCommand(String ip, String productKey, String orderNo);
  Future<void> sendCancelCommand(String ip, String productKey, String orderNo);
  Future<void> sendCheckAvailability(String ip, String productKey);
  Future<void> sendTimeSyncCommand(String ip);

  Future<void> sendRinsingCommand(String ip);
  Future<void> sendCleaningCommand(String ip, {int mode = 0});
  Future<void> sendQueryStatus(String ip);
  Future<void> sendTodayExtractionHistory(String ip);

  void dispose();
}

@Singleton(as: ICayeMachineDataSource)
class CayeMachineDataSource implements ICayeMachineDataSource {
  static const String _tag = 'Caye';
  static const String _hexKey = '734B09645723794F14B817BB6218D14E';

  Socket? _socket;
  Timer? _heartbeatTimer;

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  final StreamController<ExtractionProgress> _progressController =
      StreamController<ExtractionProgress>.broadcast();

  @override
  Stream<ExtractionProgress> get progressStream => _progressController.stream;

  @override
  Stream<bool> get connectionStream => _connectionController.stream;

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
        Log.d(_tag, 'Connecting to $ip:$port');
        _socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
        _connectionController.add(true);
        _socket!.listen(
          _handleIncoming,
          onDone: _handleDisconnect,
          onError: (_) => _handleDisconnect(),
        );
        _startHeartbeat(ip);
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
        final decoded = jsonDecode(json) as Map<String, dynamic>;
        if (const {0x20, 0x22, 0x23, 0x24, 0x35}.contains(functionCode)) {
          _progressController.add(ExtractionProgress(code: functionCode, data: decoded));
        }
        Log.long(_tag, '[Received] 0x${functionCode.toRadixString(16)} | $json');
      }

      offset = packetEnd;
    }
  }

  /// Starts a 1-minute periodic timer that sends a time-sync command to keep the connection alive.
  void _startHeartbeat(String ip) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      sendTimeSyncCommand(ip);
    });
  }

  /// Destroys the TCP socket, cancels the heartbeat, and emits disconnected state.
  void _handleDisconnect() {
    _socket?.destroy();
    _socket = null;
    _heartbeatTimer?.cancel();
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
  Future<void> sendTodayExtractionHistory(String ip) =>
      _sendPacket(ip, 0x35, {});

  /// Closes the socket connection and all stream controllers.
  @override
  void dispose() {
    _handleDisconnect();
    _progressController.close();
    _connectionController.close();
  }
}
