import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/data/sources/local/order_history_data_source.dart';
import 'package:flowhub/domain/entities/order/order.dart';
import 'package:flowhub/domain/repositories/order_history_repository.dart';

@Singleton(as: OrderHistoryRepository)
class OrderHistoryRepositoryImpl implements OrderHistoryRepository {
  final IOrderHistoryDataSource _dataSource;

  OrderHistoryRepositoryImpl(this._dataSource);

  @override
  Future<void> appendCompletedOrder(Order order) => _dataSource.appendCompletedOrder(order);
}
