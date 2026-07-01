import 'package:injectable/injectable.dart' hide Order;
// import 'package:kds/data/sources/remote/kds_barcode_scan_data_source.dart'; // replaced by WebSocket-based approach
import 'package:kds/data/sources/remote/kds_socket_data_source.dart';
import 'package:kds/domain/entities/index.dart';
import 'package:kds/domain/repositories/order_repository.dart';

@Singleton(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  final IKdsSocketDataSource _socketDataSource;
  // final IBarcodeScanDataSource _barcodeScanDataSource; // replaced by WebSocket-based approach

  const OrderRepositoryImpl(this._socketDataSource);

  @override
  Stream<bool> get connectionStream => _socketDataSource.connectionStream;

  @override
  Stream<({String orderNo, String menuName})> get pickupCompleteStream =>
      _socketDataSource.pickupCompleteStream;

  @override
  Stream<String> get calibrationStatusStream =>
      _socketDataSource.calibrationStatusStream;

  @override
  Stream<String> get barcodeScanStream => _socketDataSource.barcodeScanStream;

  @override
  Future<void> connect() => _socketDataSource.connect();

  @override
  void sendStartCalibration(double height) =>
      _socketDataSource.sendStartCalibration(height);

  @override
  void disconnect() {
    _socketDataSource.dispose();
    // _barcodeScanDataSource.dispose(); // replaced by WebSocket-based approach
  }

  @override
  Future<bool> completeCooking(Order order, SubItem subItem) async {
    try {
      _socketDataSource.sendOrderReady(order, subItem);
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
