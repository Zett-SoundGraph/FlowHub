import 'package:flowhub/domain/entities/index.dart';

typedef FleetHeartbeatEvent = ({
  String deviceId,
  DateTime timestamp,
  String topic,
  String payload,
  String qos,
  bool retain,
});

abstract class OrderRepository {
  Stream<bool> get connectionStream;
  Stream<({String orderNo, String menuName})> get pickupCompleteStream;
  Stream<String> get calibrationStatusStream;
  Stream<String> get barcodeScanStream;
  /// Raw `beta/qr/complete` scan — see [OrderRepository] callers for how
  /// this is now the single source of truth for "this drink is done"
  /// across every production type.
  Stream<String> get qrCompleteStream;
  Stream<FleetHeartbeatEvent> get fleetHeartbeatStream;
  Stream<Order> get kioskOrderStream;
  Stream<LeaderUpdateMessage> get leaderUpdateStream;
  Stream<FollowerSyncRequest> get followerSyncRequestStream;
  Map<String, DateTime> get fleetLastSeen;

  Future<void> connect();
  void disconnect();
  void sendStartCalibration(double height);
  Future<void> publishLeaderUpdate(LeaderUpdateMessage message);
  Future<void> publishFollowerSync(FollowerSyncRequest request);
  /// Leader-only: broadcasts the lightweight order summary display boards
  /// (Flow Board / Pickup Board) need, on its own dedicated topic.
  Future<void> publishBoardUpdate(BoardUpdateMessage message);
  /// Leader-only: broadcasts the order/waiting counts the kiosk mirrors in
  /// its own bottom bar.
  Future<void> publishKioskUpdate(KioskUpdateMessage message);
  /// Leader-only: broadcasts a Caye 0x30 Fault Report on its own retained topic.
  Future<void> publishCayeFault(CayeFaultMessage message);
  /// Leader-only: broadcasts a Caye 0x31 Query Running Status response on
  /// its own retained topic.
  Future<void> publishCayeStatus(CayeStatusMessage message);
  /// Leader-only: broadcasts a Caye 0x12 Rinsing Event Report on its own
  /// non-retained topic.
  Future<void> publishCayeRinsing(CayeEventMessage message);
  /// Leader-only: broadcasts a Caye 0x03 Cleaning Event Report on its own
  /// non-retained topic.
  Future<void> publishCayeCleaning(CayeEventMessage message);
  /// TEMPORARY — see IMqttDataSource.publishWledPower's doc comment.
  Future<void> publishWledPower(bool on);
  /// TEMPORARY — see IMqttDataSource.publishWledApi's doc comment.
  Future<void> publishWledApi(Map<String, dynamic> body);

  Future<bool> completeCooking(Order order, SubItem subItem);
  Future<bool> completePickup(Order order);
}
