import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart' hide Order;
import 'package:kds/core/utils/log.dart';
import 'package:kds/domain/entities/index.dart';

abstract interface class IKdsSocketDataSource {
  Stream<bool> get connectionStream;
  // PICKUP_COMPLETE now arrives via MQTT (see IMqttDataSource.pickupCompleteStream)
  // Stream<({String orderNo, String menuName})> get pickupCompleteStream;
  Stream<String> get calibrationStatusStream;
  // BARCODE_SCAN now arrives via MQTT (see IMqttDataSource.barcodeScanStream)
  // Stream<String> get barcodeScanStream;
  Future<void> connect();
  void sendOrderReady(Order order, SubItem subItem);
  void sendStartCalibration(double height);
  void dispose();
}

@Singleton(as: IKdsSocketDataSource)
class KdsSocketDataSource implements IKdsSocketDataSource {
  static const _tag = 'WsServer';
  static const int _serverPort = 8080;

  HttpServer? _server;
  final List<WebSocket> _allClients = [];

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  // Superseded by MqttDataSource._pickupCompleteController
  // final StreamController<({String orderNo, String menuName})>
  //     _pickupCompleteController =
  //     StreamController<({String orderNo, String menuName})>.broadcast();
  final StreamController<String> _calibrationStatusController =
      StreamController<String>.broadcast();
  // Superseded by MqttDataSource._barcodeScanController
  // final StreamController<String> _barcodeScanController =
  //     StreamController<String>.broadcast();

  @override
  Stream<bool> get connectionStream => _connectionController.stream;

  @override
  Stream<String> get calibrationStatusStream =>
      _calibrationStatusController.stream;

  /// Binds an HTTP server and upgrades incoming WebSocket connections.
  /// 1. Bind [HttpServer] to all IPv4 interfaces on [_serverPort]
  /// 2. Upgrade valid WebSocket upgrade requests via [_handleConnection]
  /// 3. Reject non-upgrade requests with 403 Forbidden
  @override
  Future<void> connect() async {
    try {
      _server = await HttpServer.bind(InternetAddress.anyIPv4, _serverPort);
      Log.d(_tag, 'Server started on port $_serverPort');

      _server!.listen((request) async {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          final socket = await WebSocketTransformer.upgrade(request);
          _handleConnection(socket, request.connectionInfo?.remoteAddress.address);
        } else {
          request.response.statusCode = HttpStatus.forbidden;
          request.response.close();
        }
      });
    } catch (e) {
      Log.e(_tag, 'Server start error: $e');
    }
  }

  /// Registers a new WebSocket client and sets up message/done/error handlers.
  /// 1. Add [socket] to [_allClients] and emit connection=true
  /// 2. Route incoming messages to [_handleMessage]
  /// 3. On done: remove client, re-evaluate connection state
  void _handleConnection(WebSocket socket, String? clientIp) {
    _allClients.add(socket);
    _connectionController.add(true);
    Log.d(_tag, 'Client connected ($clientIp) — total: ${_allClients.length}');

    socket.listen(
      (data) => _handleMessage(data.toString(), socket, clientIp),
      onDone: () {
        _allClients.remove(socket);
        _connectionController.add(_allClients.isNotEmpty);
        Log.d(_tag, 'Client disconnected ($clientIp) — total: ${_allClients.length}');
      },
      onError: (_) {
        _allClients.remove(socket);
        _connectionController.add(_allClients.isNotEmpty);
      },
    );
  }

  /// Parses a raw JSON message and dispatches to the appropriate stream.
  /// 1. Decode JSON and extract 'type' / 'event_type' field
  /// 2. VALIDATION_MODE / CALIB_EXIT → [_calibrationStatusController]
  /// 3. object_update → [_handleObjectUpdate] for filtering
  /// 4. All other messages → [_broadcastExcept]
  void _handleMessage(String raw, WebSocket sender, String? clientIp) {
    try {
      final Map<String, dynamic> json = jsonDecode(raw);
      final String type = json['type'] ?? json['event_type'] ?? '';

      // PICKUP_COMPLETE now arrives via MQTT (beta/pickuptable/pickup)
      // if (type == 'PICKUP_COMPLETE') {
      //   _pickupCompleteController.add((
      //     orderNo: json['orderNo'].toString(),
      //     menuName: json['menuName']?.toString() ?? '',
      //   ));
      //   return;
      // }

      if (type == 'VALIDATION_MODE' || type == 'CALIB_EXIT') {
        _calibrationStatusController.add(type);
        return;
      }

      // BARCODE_SCAN now arrives via MQTT (beta/qr/order)
      // if (type == 'BARCODE_SCAN') {
      //   final barcode = json['barcode']?.toString() ?? '';
      //   Log.d(_tag, 'BARCODE_SCAN received: $barcode (from $clientIp)');
      //   if (barcode.isNotEmpty) _barcodeScanController.add(barcode);
      //   return;
      // }

      if (type == 'object_update') {
        _handleObjectUpdate(json, raw, sender);
        return;
      }

      _broadcastExcept(raw, sender);
    } catch (e) {
      Log.e(_tag, 'Message handling error: $e');
    }
  }

  /// Filters out invalid objects from an object_update message before broadcast.
  /// 1. Reject objects with diameter == 0 or >= 350mm
  /// 2. If all objects are valid, broadcast the original message unchanged
  /// 3. Otherwise re-encode the filtered object list and broadcast
  void _handleObjectUpdate(
      Map<String, dynamic> json, String raw, WebSocket sender) {
    final objects = json['objects'] as List<dynamic>? ?? [];
    final baseZ = json['base_z'];

    final validObjects = <dynamic>[];
    for (final obj in objects) {
      final id = obj['object_id'];
      final diameter = (obj['size']?['diameter'] as num?)?.toDouble() ?? 0;
      final w = obj['size']?['width'];
      final h = obj['size']?['height'];
      final x = (obj['position']?['x'] as num?)?.toStringAsFixed(1);
      final y = (obj['position']?['y'] as num?)?.toStringAsFixed(1);
      final z = obj['z_value'];

      if (diameter == 0.0 || diameter >= 350.0) {
        Log.d('object_update', 'id=$id → diameter=${diameter.toStringAsFixed(1)}mm filtered out');
        continue;
      }

      Log.d(
        'object_update',
        'id=$id, diameter=${diameter.toStringAsFixed(1)}mm, '
        'w=${w}px h=${h}px, pos=($x,$y), z=$z, base_z=$baseZ',
      );
      validObjects.add(obj);
    }

    if (validObjects.length == objects.length) {
      _broadcastExcept(raw, sender);
      return;
    }

    final modified = Map<String, dynamic>.from(json)
      ..['objects'] = validObjects;
    _broadcastExcept(jsonEncode(modified), sender);
  }

  /// Sends [message] to all connected clients except [sender].
  void _broadcastExcept(String message, WebSocket sender) {
    for (final client in List.from(_allClients)) {
      if (client == sender) continue;
      if (client.readyState == WebSocket.open) client.add(message);
    }
  }

  /// Sends [message] to all connected clients.
  void _broadcast(String message) {
    for (final client in List.from(_allClients)) {
      if (client.readyState == WebSocket.open) client.add(message);
    }
  }

  /// Broadcasts an ORDER_READY event to all connected pickup table clients.
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
    Log.d(_tag, 'ORDER_READY broadcast: ${order.orderNo} (${subItem.menuName})');
  }

  /// Broadcasts a START_CALIBRATION event with [height] to all connected clients.
  /// The pickup table handles this event to trigger height-sensor calibration.
  @override
  void sendStartCalibration(double height) {
    _broadcast(jsonEncode({
      'type': 'START_CALIBRATION',
      'height': height,
      'timestamp': DateTime.now().toIso8601String(),
    }));
  }

  /// Closes the HTTP server and all active WebSocket connections.
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
    _calibrationStatusController.close();
    Log.d(_tag, 'Server closed');
  }
}
