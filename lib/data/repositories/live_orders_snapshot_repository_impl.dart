import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/data/sources/local/live_orders_snapshot_data_source.dart';
import 'package:flowhub/domain/entities/order/order.dart';
import 'package:flowhub/domain/repositories/live_orders_snapshot_repository.dart';

@Singleton(as: LiveOrdersSnapshotRepository)
class LiveOrdersSnapshotRepositoryImpl implements LiveOrdersSnapshotRepository {
  final ILiveOrdersSnapshotDataSource _dataSource;

  LiveOrdersSnapshotRepositoryImpl(this._dataSource);

  @override
  Future<void> save(List<Order> orders) => _dataSource.save(orders);

  @override
  Future<List<Order>> load() => _dataSource.load();

  @override
  Future<void> clear() => _dataSource.clear();
}
