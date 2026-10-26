import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/data/sources/remote/app_control_data_source.dart';
import 'package:flowhub/domain/repositories/app_control_repository.dart';

@Singleton(as: AppControlRepository)
class AppControlRepositoryImpl implements AppControlRepository {
  final IAppControlDataSource _dataSource;

  AppControlRepositoryImpl(this._dataSource);

  @override
  Future<void> restartApp() => _dataSource.restartApp();
}
