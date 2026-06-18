// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/exceptions/common_exception_handler.dart' as _i3;
import '../../data/repositories/order_repository_impl.dart' as _i717;
import '../../data/sources/remote/kds_socket_data_source.dart' as _i919;
import '../../domain/exception/base_exception_handler.dart' as _i543;
import '../../domain/repositories/index.dart' as _i445;
import '../../domain/repositories/order_repository.dart' as _i507;
import '../../domain/usecases/complete_cooking_usecase.dart' as _i110;
import '../../domain/usecases/complete_pickup_usecase.dart' as _i500;
import '../../domain/usecases/connect_order_socket_usecase.dart' as _i6;
import '../../domain/usecases/disconnect_order_socket_usecase.dart' as _i479;
import '../../domain/usecases/observe_order_connection_usecase.dart' as _i628;
import '../../presentation/cubit/kds/kds_cubit.dart' as _i807;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  gh.singleton<_i919.IKdsSocketDataSource>(() => _i919.KdsSocketDataSource());
  gh.factory<_i543.BaseExceptionHandler>(() => _i3.CommonExceptionHandler());
  gh.singleton<_i507.OrderRepository>(
    () => _i717.OrderRepositoryImpl(gh<_i919.IKdsSocketDataSource>()),
  );
  gh.factory<_i6.ConnectOrderSocketUseCase>(
    () => _i6.ConnectOrderSocketUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i479.DisconnectOrderSocketUseCase>(
    () => _i479.DisconnectOrderSocketUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i628.ObserveOrderConnectionUseCase>(
    () => _i628.ObserveOrderConnectionUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i110.CompleteCookingUseCase>(
    () => _i110.CompleteCookingUseCase(gh<_i445.OrderRepository>()),
  );
  gh.factory<_i500.CompletePickupUseCase>(
    () => _i500.CompletePickupUseCase(gh<_i445.OrderRepository>()),
  );
  gh.factory<_i807.KdsCubit>(
    () => _i807.KdsCubit(
      completeCooking: gh<_i110.CompleteCookingUseCase>(),
      completePickup: gh<_i500.CompletePickupUseCase>(),
      connectOrderSocket: gh<_i6.ConnectOrderSocketUseCase>(),
      disconnectOrderSocket: gh<_i479.DisconnectOrderSocketUseCase>(),
      observeOrderConnection: gh<_i628.ObserveOrderConnectionUseCase>(),
    ),
  );
  return getIt;
}
