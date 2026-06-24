import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:injectable/injectable.dart' hide Order;
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

  void _log(String message) {
    if (message.length > 800) {
      for (int s = 0; s < message.length; s += 800) {
        log('[Caye] ${message.substring(s, (s + 800).clamp(0, message.length))}');
      }
    } else {
      log('[Caye] $message');
    }
  }

  Uint8List _encryptPayload(int functionCode, Map<String, dynamic> body) {
    final key = enc.Key.fromBase16(_hexKey);
    final iv = enc.IV(Uint8List(16)); // zero IV (CBC)
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));

    final ByteData tsData = ByteData(8);
    tsData.setUint64(0, DateTime.now().millisecondsSinceEpoch, Endian.big);
    final Uint8List tsBytes = tsData.buffer.asUint8List();

    final List<int> payload = body.isEmpty
        ? tsBytes.toList()
        : [...tsBytes, ...utf8.encode(jsonEncode(body))];

    return encrypter.encryptBytes(payload, iv: iv).bytes;
  }

  String? _decryptPayload(Uint8List encryptedData) {
    try {
      final key = enc.Key.fromBase16(_hexKey);
      final iv = enc.IV(Uint8List(16));
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));
      final decrypted = encrypter.decryptBytes(enc.Encrypted(encryptedData), iv: iv);
      if (decrypted.length <= 8) return null;
      return utf8.decode(decrypted.sublist(8));
    } catch (e) {
      _log('❌ 복호화 실패: $e');
      return null;
    }
  }

  int _checksum(Uint8List data) {
    int cs = 0;
    for (final b in data) { cs ^= b; }
    return cs & 0xFF;
  }

  Future<void> _sendPacket(String ip, int functionCode, Map<String, dynamic> body) async {
    const int port = 31255;
    try {
      if (_socket == null) {
        _log('🌐 접속 시도 ($ip:$port)');
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
      _log('📡 [Sent] 0x${functionCode.toRadixString(16)} | $body');
    } catch (e) {
      _log('❌ 전송 에러: $e');
      _handleDisconnect();
    }
  }

  void _handleIncoming(Uint8List data) {
    if (data.length < 13) return;
    final int functionCode = data[2];
    final int dataLength = ByteData.sublistView(data, 5, 7).getUint16(0, Endian.big);
    final Uint8List encryptedBody = data.sublist(7, 7 + dataLength);
    final String? json = _decryptPayload(encryptedBody);

    if (json != null) {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      if (const {0x20, 0x22, 0x23, 0x24, 0x35}.contains(functionCode)) {
        _progressController.add(ExtractionProgress(functionCode, decoded));
      }
      _log('📥 [Decrypted] 0x${functionCode.toRadixString(16)} | $json');
    }
  }

  void _startHeartbeat(String ip) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      sendTimeSyncCommand(ip);
    });
  }

  void _handleDisconnect() {
    _socket?.destroy();
    _socket = null;
    _heartbeatTimer?.cancel();
    _connectionController.add(false);
    _log('🔌 연결 종료');
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

  @override
  void dispose() {
    _handleDisconnect();
    _progressController.close();
    _connectionController.close();
  }
}
