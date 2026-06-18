import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';

abstract interface class IKdsSocketDataSource {
  Stream<bool> get connectionStream;
  Future<void> connect();
  void sendOrderReady(String orderNo, String menuName);
  void dispose();
}

@Singleton(as: IKdsSocketDataSource)
class KdsSocketDataSource implements IKdsSocketDataSource {
  static const String _serverIp = '192.168.10.192';
  static const int _serverPort = 8080;

  WebSocket? _socket;
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  @override
  Stream<bool> get connectionStream => _connectionController.stream;

  @override
  Future<void> connect() async {
    try {
      const wsUrl = 'ws://$_serverIp:$_serverPort';
      _socket =
          await WebSocket.connect(wsUrl).timeout(const Duration(seconds: 5));
      _connectionController.add(true);
      _socket!.listen(
        (_) {},
        onDone: _handleDisconnect,
        onError: (_) => _handleDisconnect(),
      );
    } catch (_) {
      _connectionController.add(false);
    }
  }

  @override
  void sendOrderReady(String orderNo, String menuName) {
    if (_socket != null && _socket!.readyState == WebSocket.open) {
      _socket!.add(jsonEncode({
        'type': 'ORDER_READY',
        'orderNo': orderNo,
        'menuName': menuName,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    }
  }

  void _handleDisconnect() {
    _socket?.close();
    _socket = null;
    _connectionController.add(false);
  }

  @override
  void dispose() {
    _socket?.close();
    _connectionController.close();
  }
}
