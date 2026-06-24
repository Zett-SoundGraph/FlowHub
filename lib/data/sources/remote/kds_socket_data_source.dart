import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:kds/domain/entities/index.dart';

abstract interface class IKdsSocketDataSource {
  Stream<bool> get connectionStream;
  Stream<({String orderNo, String menuName})> get pickupCompleteStream;
  Stream<String> get calibrationStatusStream;
  Stream<String> get barcodeScanStream;
  Future<void> connect();
  void sendOrderReady(Order order, SubItem subItem);
  void sendStartCalibration(double height);
  void dispose();
}

@Singleton(as: IKdsSocketDataSource)
class KdsSocketDataSource implements IKdsSocketDataSource {
  static const int _serverPort = 8080;

  HttpServer? _server;
  final List<WebSocket> _allClients = [];

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  final StreamController<({String orderNo, String menuName})>
      _pickupCompleteController =
      StreamController<({String orderNo, String menuName})>.broadcast();
  final StreamController<String> _calibrationStatusController =
      StreamController<String>.broadcast();
  final StreamController<String> _barcodeScanController =
      StreamController<String>.broadcast();

  @override
  Stream<bool> get connectionStream => _connectionController.stream;

  @override
  Stream<({String orderNo, String menuName})> get pickupCompleteStream =>
      _pickupCompleteController.stream;

  @override
  Stream<String> get calibrationStatusStream =>
      _calibrationStatusController.stream;

  @override
  Stream<String> get barcodeScanStream => _barcodeScanController.stream;

  @override
  Future<void> connect() async {
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, _serverPort);
      debugPrint('[WsServer] 서버 시작됨 (포트: $_serverPort)');

      _server!.listen((request) async {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          final socket = await WebSocketTransformer.upgrade(request);
          _handleConnection(
              socket, request.connectionInfo?.remoteAddress.address);
        } else {
          request.response.statusCode = HttpStatus.forbidden;
          request.response.close();
        }
      });
    } catch (e) {
      debugPrint('[WsServer] 서버 시작 에러: $e');
    }
  }

  void _handleConnection(WebSocket socket, String? clientIp) {
    _allClients.add(socket);
    _connectionController.add(true);
    debugPrint(
        '[WsServer] 클라이언트 연결됨 ($clientIp) — 현재 ${_allClients.length}대');

    socket.listen(
      (data) => _handleMessage(data.toString(), socket, clientIp),
      onDone: () {
        _allClients.remove(socket);
        _connectionController.add(_allClients.isNotEmpty);
        debugPrint(
            '[WsServer] 연결 종료됨 ($clientIp) — 현재 ${_allClients.length}대');
      },
      onError: (_) {
        _allClients.remove(socket);
        _connectionController.add(_allClients.isNotEmpty);
      },
    );
  }

  void _handleMessage(String raw, WebSocket sender, String? clientIp) {
    try {
      final Map<String, dynamic> json = jsonDecode(raw);
      final String type = json['type'] ?? json['event_type'] ?? '';

      if (type == 'PICKUP_COMPLETE') {
        _pickupCompleteController.add((
          orderNo: json['orderNo'].toString(),
          menuName: json['menuName']?.toString() ?? '',
        ));
        return;
      }

      if (type == 'VALIDATION_MODE' || type == 'CALIB_EXIT') {
        _calibrationStatusController.add(type);
        return;
      }

      if (type == 'BARCODE_SCAN') {
        final barcode = json['barcode']?.toString() ?? '';
        debugPrint('[WsServer] BARCODE_SCAN 수신: $barcode (from $clientIp)');
        if (barcode.isNotEmpty) _barcodeScanController.add(barcode);
        return;
      }

      _broadcastExcept(raw, sender);
    } catch (e) {
      debugPrint('[WsServer] 메시지 처리 에러: $e');
    }
  }

  void _broadcastExcept(String message, WebSocket sender) {
    for (final client in List.from(_allClients)) {
      if (client == sender) continue;
      if (client.readyState == WebSocket.open) client.add(message);
    }
  }

  void _broadcast(String message) {
    for (final client in List.from(_allClients)) {
      if (client.readyState == WebSocket.open) client.add(message);
    }
  }

  @override
  void sendOrderReady(Order order, SubItem subItem) {
    _broadcast(jsonEncode({
      'type': 'ORDER_READY',
      'orderNo': order.orderNo,
      'menuName': subItem.menuName,
      'drinkCount': order.drinkCount,
      'foodCount': order.foodCount,
      'bottleCount': order.bottleCount,
      'nickname': order.nickname ?? '',
      'totalRequired': order.totalCups,
      'timestamp': DateTime.now().toIso8601String(),
    }));
    debugPrint('[WsServer] ORDER_READY 브로드캐스트: ${order.orderNo} (${subItem.menuName})');
  }

  @override
  void sendStartCalibration(double height) {
    _broadcast(jsonEncode({
      'type': 'START_CALIBRATION',
      'height': height,
      'timestamp': DateTime.now().toIso8601String(),
    }));
  }

  @override
  void dispose() {
    _server?.close();
    for (final client in List.from(_allClients)) {
      try {
        client.close();
      } catch (_) {}
    }
    _allClients.clear();
    _connectionController.close();
    _pickupCompleteController.close();
    _calibrationStatusController.close();
    _barcodeScanController.close();
    debugPrint('[WsServer] 서버 종료됨');
  }
}
