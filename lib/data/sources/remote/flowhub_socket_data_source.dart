import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/core/utils/log.dart';

abstract interface class IFlowHubSocketDataSource {
  Stream<bool> get connectionStream;
  // PICKUP_COMPLETE now arrives via MQTT (see IMqttDataSource.pickupCompleteStream)
  // Stream<({String orderNo, String menuName})> get pickupCompleteStream;
  // BARCODE_SCAN now arrives via MQTT (see IMqttDataSource.barcodeScanStream)
  // Stream<String> get barcodeScanStream;
  // VALIDATION_MODE/CALIB_EXIT now arrive via MQTT (see
  // IMqttDataSource.calibrationStatusStream)
  // Stream<String> get calibrationStatusStream;
  Future<void> connect();
  // ORDER_READY/START_CALIBRATION now go out via MQTT (see
  // IMqttDataSource.publishOrderReady/publishStartCalibration)
  // void sendOrderReady(Order order, SubItem subItem);
  // void sendStartCalibration(double height);
  void dispose();
}

@Singleton(as: IFlowHubSocketDataSource)
class FlowHubSocketDataSource implements IFlowHubSocketDataSource {
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
  // Superseded by MqttDataSource._barcodeScanController
  // final StreamController<String> _barcodeScanController =
  //     StreamController<String>.broadcast();
  // Superseded by MqttDataSource._calibrationStatusController
  // final StreamController<String> _calibrationStatusController =
  //     StreamController<String>.broadcast();

  @override
  Stream<bool> get connectionStream => _connectionController.stream;

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
  /// Every case that used to switch on 'type'/'event_type' here (PICKUP_
  /// COMPLETE, BARCODE_SCAN, VALIDATION_MODE/CALIB_EXIT) has since moved to
  /// MQTT — see the comments below for where each landed. What's left after
  /// decoding just validates it's real JSON before [_broadcastExcept]ing it
  /// unchanged. In practice today that's ORDER_READY/START_CALIBRATION
  /// (Flutter→Flutter, unrelated to the Pi/ToF migration — no MQTT
  /// equivalent yet) and the Raspberry Pi's own object_update — the Pi
  /// dual-publishes that one over MQTT (beta/tof/objects) AND this socket
  /// as a transition safety net (see PiMqttManager), so it's still expected
  /// here; flowhub just no longer filters/inspects it (that moved to the Pi's
  /// own send path — see filterInvalidDiameterObjects in VizDepthFrame.cpp).
  void _handleMessage(String raw, WebSocket sender, String? clientIp) {
    try {
      jsonDecode(raw);

      // PICKUP_COMPLETE now arrives via MQTT (beta/pickuptable/pickup)
      // if (type == 'PICKUP_COMPLETE') {
      //   _pickupCompleteController.add((
      //     orderNo: json['orderNo'].toString(),
      //     menuName: json['menuName']?.toString() ?? '',
      //   ));
      //   return;
      // }

      // VALIDATION_MODE/CALIB_EXIT now arrive via MQTT
      // (beta/pickuptable/calibration_status)
      // if (type == 'VALIDATION_MODE' || type == 'CALIB_EXIT') {
      //   _calibrationStatusController.add(type);
      //   return;
      // }

      // BARCODE_SCAN now arrives via MQTT (beta/qr/order)
      // if (type == 'BARCODE_SCAN') {
      //   final barcode = json['barcode']?.toString() ?? '';
      //   Log.d(_tag, 'BARCODE_SCAN received: $barcode (from $clientIp)');
      //   if (barcode.isNotEmpty) _barcodeScanController.add(barcode);
      //   return;
      // }

      _broadcastExcept(raw, sender);
    } catch (e) {
      Log.e(_tag, 'Message handling error: $e');
    }
  }

  /// Sends [message] to all connected clients except [sender].
  void _broadcastExcept(String message, WebSocket sender) {
    for (final client in List.from(_allClients)) {
      if (client == sender) continue;
      if (client.readyState == WebSocket.open) client.add(message);
    }
  }

  // ORDER_READY/START_CALIBRATION now go out via MQTT
  // (IMqttDataSource.publishOrderReady/publishStartCalibration) — this was
  // their only caller, so _broadcast (as opposed to _broadcastExcept, which
  // is still used for everything else on this socket) has no more use.
  // void _broadcast(String message) {
  //   for (final client in List.from(_allClients)) {
  //     if (client.readyState == WebSocket.open) client.add(message);
  //   }
  // }

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
    Log.d(_tag, 'Server closed');
  }
}
