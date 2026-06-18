import 'package:injectable/injectable.dart' hide Order;
import 'package:kds/data/sources/remote/kds_socket_data_source.dart';
import 'package:kds/domain/entities/index.dart';
import 'package:kds/domain/repositories/order_repository.dart';

@Singleton(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  final IKdsSocketDataSource _dataSource;

  const OrderRepositoryImpl(this._dataSource);

  @override
  Stream<bool> get connectionStream => _dataSource.connectionStream;

  @override
  Future<void> connect() => _dataSource.connect();

  @override
  void disconnect() => _dataSource.dispose();

  @override
  Future<bool> completeCooking(Order order) async {
    try {
      _dataSource.sendOrderReady(order.orderNo, order.menuName);
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
