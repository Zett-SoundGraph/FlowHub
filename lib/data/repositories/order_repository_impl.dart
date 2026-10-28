import 'package:injectable/injectable.dart' hide Order;
// import 'package:flowhub/data/sources/remote/flowhub_barcode_scan_data_source.dart'; // replaced by WebSocket-based approach
import 'package:flowhub/data/sources/remote/flowhub_socket_data_source.dart';
import 'package:flowhub/data/sources/remote/mqtt_data_source.dart';
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/enums/index.dart';
import 'package:flowhub/domain/repositories/order_repository.dart';

@Singleton(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  final IFlowHubSocketDataSource _socketDataSource;
  final IMqttDataSource _mqttDataSource;
  // final IBarcodeScanDataSource _barcodeScanDataSource; // replaced by WebSocket-based approach

  const OrderRepositoryImpl(this._socketDataSource, this._mqttDataSource);

  @override
  Stream<bool> get connectionStream => _socketDataSource.connectionStream;

  @override
  Stream<({String orderNo, String menuName})> get pickupCompleteStream =>
      _mqttDataSource.pickupCompleteStream;

  @override
  Stream<String> get calibrationStatusStream =>
      _mqttDataSource.calibrationStatusStream;

  @override
  Stream<String> get barcodeScanStream => _mqttDataSource.barcodeScanStream;

  @override
  Stream<String> get qrCompleteStream => _mqttDataSource.qrCompleteStream;

  @override
  Stream<FleetHeartbeatEvent> get fleetHeartbeatStream =>
      _mqttDataSource.fleetHeartbeatStream;

  @override
  Stream<Order> get kioskOrderStream => _mqttDataSource.kioskOrderStream;

  @override
  Stream<LeaderUpdateMessage> get leaderUpdateStream =>
      _mqttDataSource.leaderUpdateStream;

  @override
  Stream<FollowerSyncRequest> get followerSyncRequestStream =>
      _mqttDataSource.followerSyncRequestStream;

  @override
  Map<String, DateTime> get fleetLastSeen => _mqttDataSource.fleetLastSeen;

  @override
  Future<void> connect() async {
    await _socketDataSource.connect();
    await _mqttDataSource.connect();
  }

  @override
  void sendStartCalibration(
    double height, {
    required String displayModel,
    required double edgeMarginMm,
    double? displayWidthMm,
    double? displayHeightMm,
  }) =>
      _mqttDataSource.publishStartCalibration(
        height,
        displayModel: displayModel,
        edgeMarginMm: edgeMarginMm,
        displayWidthMm: displayWidthMm,
        displayHeightMm: displayHeightMm,
      );

  @override
  Future<void> sendPickupTableTheme(PickupTableThemeSelection selection) =>
      _mqttDataSource.publishPickupTableTheme(selection);

  @override
  Future<void> resetPickupTableTheme() => _mqttDataSource.publishPickupTableThemeReset();

  @override
  Future<void> createPickupTableTestOrders() => _mqttDataSource.publishCreateTestOrders();

  @override
  Future<void> clearPickupTableTestOrders() => _mqttDataSource.publishClearTestOrders();

  @override
  Future<void> publishLeaderUpdate(LeaderUpdateMessage message) =>
      _mqttDataSource.publishLeaderUpdate(message);

  @override
  Future<void> publishFollowerSync(FollowerSyncRequest request) =>
      _mqttDataSource.publishFollowerSync(request);

  @override
  Future<void> publishBoardUpdate(BoardUpdateMessage message) =>
      _mqttDataSource.publishBoardUpdate(message);

  @override
  Future<void> publishKioskUpdate(KioskUpdateMessage message) =>
      _mqttDataSource.publishKioskUpdate(message);

  @override
  Future<void> publishCayeFault(CayeFaultMessage message) =>
      _mqttDataSource.publishCayeFault(message);

  @override
  Future<void> publishCayeStatus(CayeStatusMessage message) =>
      _mqttDataSource.publishCayeStatus(message);

  @override
  Future<void> publishCayeRinsing(CayeEventMessage message) =>
      _mqttDataSource.publishCayeRinsing(message);

  @override
  Future<void> publishCayeCleaning(CayeEventMessage message) =>
      _mqttDataSource.publishCayeCleaning(message);

  @override
  Future<void> publishWledApi(WledDevice device, Map<String, dynamic> body) =>
      _mqttDataSource.publishWledApi(device, body);

  @override
  Stream<({WledDevice device, bool online})> get wledOnlineStream =>
      _mqttDataSource.wledOnlineStream;

  @override
  Map<WledDevice, bool> get wledOnlineByDevice =>
      _mqttDataSource.wledOnlineByDevice;

  @override
  void disconnect() {
    _socketDataSource.dispose();
    _mqttDataSource.dispose();
    // _barcodeScanDataSource.dispose(); // replaced by WebSocket-based approach
  }

  @override
  Future<bool> completeCooking(Order order, SubItem subItem) async {
    try {
      await _mqttDataSource.publishOrderReady(order, subItem);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> completePickup(Order order) async {
    return true;
  }
}
