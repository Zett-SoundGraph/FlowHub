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
import '../../data/repositories/machine_repository_impl.dart' as _i1003;
import '../../data/repositories/order_repository_impl.dart' as _i717;
import '../../data/repositories/printer_repository_impl.dart' as _i514;
import '../../data/repositories/recipe_repository_impl.dart' as _i869;
import '../../data/sources/local/recipe_data_source.dart' as _i489;
import '../../data/sources/remote/caye_machine_data_source.dart' as _i422;
import '../../data/sources/remote/kds_barcode_scan_data_source.dart' as _i792;
import '../../data/sources/remote/kds_socket_data_source.dart' as _i919;
import '../../data/sources/remote/mqtt_data_source.dart' as _i126;
import '../../data/sources/remote/printer_data_source.dart' as _i656;
import '../../domain/exception/base_exception_handler.dart' as _i543;
import '../../domain/repositories/index.dart' as _i445;
import '../../domain/repositories/machine_repository.dart' as _i958;
import '../../domain/repositories/order_repository.dart' as _i507;
import '../../domain/repositories/printer_repository.dart' as _i115;
import '../../domain/repositories/recipe_repository.dart' as _i197;
import '../../domain/usecases/check_machine_availability_usecase.dart' as _i893;
import '../../domain/usecases/complete_cooking_usecase.dart' as _i110;
import '../../domain/usecases/complete_pickup_usecase.dart' as _i500;
import '../../domain/usecases/connect_order_socket_usecase.dart' as _i6;
import '../../domain/usecases/disconnect_order_socket_usecase.dart' as _i479;
import '../../domain/usecases/dispose_machine_usecase.dart' as _i135;
import '../../domain/usecases/dispose_printer_usecase.dart' as _i517;
import '../../domain/usecases/get_fleet_snapshot_usecase.dart' as _i26;
import '../../domain/usecases/get_recipe_usecase.dart' as _i510;
import '../../domain/usecases/observe_barcode_scan_usecase.dart' as _i174;
import '../../domain/usecases/observe_calibration_status_usecase.dart' as _i5;
import '../../domain/usecases/observe_fleet_heartbeats_usecase.dart' as _i398;
import '../../domain/usecases/observe_machine_connection_usecase.dart' as _i847;
import '../../domain/usecases/observe_machine_progress_usecase.dart' as _i804;
import '../../domain/usecases/observe_order_connection_usecase.dart' as _i628;
import '../../domain/usecases/observe_pickup_complete_usecase.dart' as _i640;
import '../../domain/usecases/observe_printer_status_usecase.dart' as _i328;
import '../../domain/usecases/print_label_usecase.dart' as _i413;
import '../../domain/usecases/send_cancel_command_usecase.dart' as _i622;
import '../../domain/usecases/send_cleaning_command_usecase.dart' as _i682;
import '../../domain/usecases/send_make_command_usecase.dart' as _i1052;
import '../../domain/usecases/send_query_status_usecase.dart' as _i460;
import '../../domain/usecases/send_rinsing_command_usecase.dart' as _i68;
import '../../domain/usecases/send_time_sync_usecase.dart' as _i627;
import '../../domain/usecases/send_today_extraction_history_usecase.dart'
    as _i281;
import '../../domain/usecases/start_calibration_usecase.dart' as _i583;
import '../../presentation/cubit/caye/caye_management_cubit.dart' as _i776;
import '../../presentation/cubit/fleet_monitor/fleet_monitor_cubit.dart'
    as _i102;
import '../../presentation/cubit/kds/kds_cubit.dart' as _i807;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  gh.singleton<_i919.IKdsSocketDataSource>(() => _i919.KdsSocketDataSource());
  gh.singleton<_i126.IMqttDataSource>(() => _i126.MqttDataSource());
  gh.factory<_i543.BaseExceptionHandler>(() => _i3.CommonExceptionHandler());
  gh.singleton<_i422.ICayeMachineDataSource>(
    () => _i422.CayeMachineDataSource(),
  );
  gh.singleton<_i958.MachineRepository>(
    () => _i1003.MachineRepositoryImpl(gh<_i422.ICayeMachineDataSource>()),
  );
  gh.singleton<_i656.IPrinterDataSource>(() => _i656.PrinterDataSource());
  gh.singleton<_i792.IBarcodeScanDataSource>(
    () => _i792.KdsBarcodeScanDataSource(),
  );
  gh.singleton<_i489.IRecipeDataSource>(() => _i489.RecipeDataSource());
  gh.factory<_i804.ObserveMachineProgressUseCase>(
    () => _i804.ObserveMachineProgressUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i893.CheckMachineAvailabilityUseCase>(
    () => _i893.CheckMachineAvailabilityUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i135.DisposeMachineUseCase>(
    () => _i135.DisposeMachineUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i847.ObserveMachineConnectionUseCase>(
    () => _i847.ObserveMachineConnectionUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i622.SendCancelCommandUseCase>(
    () => _i622.SendCancelCommandUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i682.SendCleaningCommandUseCase>(
    () => _i682.SendCleaningCommandUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i1052.SendMakeCommandUseCase>(
    () => _i1052.SendMakeCommandUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i460.SendQueryStatusUseCase>(
    () => _i460.SendQueryStatusUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i68.SendRinsingCommandUseCase>(
    () => _i68.SendRinsingCommandUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i627.SendTimeSyncUseCase>(
    () => _i627.SendTimeSyncUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i281.SendTodayExtractionHistoryUseCase>(
    () =>
        _i281.SendTodayExtractionHistoryUseCase(gh<_i958.MachineRepository>()),
  );
  gh.singleton<_i115.PrinterRepository>(
    () => _i514.PrinterRepositoryImpl(gh<_i656.IPrinterDataSource>()),
  );
  gh.singleton<_i507.OrderRepository>(
    () => _i717.OrderRepositoryImpl(
      gh<_i919.IKdsSocketDataSource>(),
      gh<_i126.IMqttDataSource>(),
    ),
  );
  gh.singleton<_i197.RecipeRepository>(
    () => _i869.RecipeRepositoryImpl(gh<_i489.IRecipeDataSource>()),
  );
  gh.factory<_i174.ObserveBarcodeScanUseCase>(
    () => _i174.ObserveBarcodeScanUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i5.ObserveCalibrationStatusUseCase>(
    () => _i5.ObserveCalibrationStatusUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i398.ObserveFleetHeartbeatsUseCase>(
    () => _i398.ObserveFleetHeartbeatsUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i640.ObservePickupCompleteUseCase>(
    () => _i640.ObservePickupCompleteUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i110.CompleteCookingUseCase>(
    () => _i110.CompleteCookingUseCase(gh<_i445.OrderRepository>()),
  );
  gh.factory<_i500.CompletePickupUseCase>(
    () => _i500.CompletePickupUseCase(gh<_i445.OrderRepository>()),
  );
  gh.factory<_i517.DisposePrinterUseCase>(
    () => _i517.DisposePrinterUseCase(gh<_i115.PrinterRepository>()),
  );
  gh.factory<_i413.PrintLabelUseCase>(
    () => _i413.PrintLabelUseCase(gh<_i115.PrinterRepository>()),
  );
  gh.factory<_i328.ObservePrinterStatusUseCase>(
    () => _i328.ObservePrinterStatusUseCase(gh<_i115.PrinterRepository>()),
  );
  gh.factory<_i776.CayeManagementCubit>(
    () => _i776.CayeManagementCubit(
      observeMachineConnection: gh<_i847.ObserveMachineConnectionUseCase>(),
      sendCancelCommand: gh<_i622.SendCancelCommandUseCase>(),
      sendRinsingCommand: gh<_i68.SendRinsingCommandUseCase>(),
      sendCleaningCommand: gh<_i682.SendCleaningCommandUseCase>(),
      sendQueryStatus: gh<_i460.SendQueryStatusUseCase>(),
      sendTimeSync: gh<_i627.SendTimeSyncUseCase>(),
      sendTodayExtractionHistory: gh<_i281.SendTodayExtractionHistoryUseCase>(),
    ),
  );
  gh.factory<_i510.GetRecipeUseCase>(
    () => _i510.GetRecipeUseCase(gh<_i197.RecipeRepository>()),
  );
  gh.factory<_i6.ConnectOrderSocketUseCase>(
    () => _i6.ConnectOrderSocketUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i479.DisconnectOrderSocketUseCase>(
    () => _i479.DisconnectOrderSocketUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i26.GetFleetSnapshotUseCase>(
    () => _i26.GetFleetSnapshotUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i628.ObserveOrderConnectionUseCase>(
    () => _i628.ObserveOrderConnectionUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i583.StartCalibrationUseCase>(
    () => _i583.StartCalibrationUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i807.KdsCubit>(
    () => _i807.KdsCubit(
      completeCooking: gh<_i110.CompleteCookingUseCase>(),
      completePickup: gh<_i500.CompletePickupUseCase>(),
      connectOrderSocket: gh<_i6.ConnectOrderSocketUseCase>(),
      disconnectOrderSocket: gh<_i479.DisconnectOrderSocketUseCase>(),
      observeOrderConnection: gh<_i628.ObserveOrderConnectionUseCase>(),
      observeBarcodeScan: gh<_i174.ObserveBarcodeScanUseCase>(),
      observePickupComplete: gh<_i640.ObservePickupCompleteUseCase>(),
      observeMachineProgress: gh<_i804.ObserveMachineProgressUseCase>(),
      checkMachineAvailability: gh<_i893.CheckMachineAvailabilityUseCase>(),
      sendMakeCommand: gh<_i1052.SendMakeCommandUseCase>(),
      sendCancelCommand: gh<_i622.SendCancelCommandUseCase>(),
      observePrinterStatus: gh<_i328.ObservePrinterStatusUseCase>(),
      printLabel: gh<_i413.PrintLabelUseCase>(),
      startCalibration: gh<_i583.StartCalibrationUseCase>(),
      getRecipe: gh<_i510.GetRecipeUseCase>(),
      observeCalibrationStatus: gh<_i5.ObserveCalibrationStatusUseCase>(),
      disposeMachine: gh<_i135.DisposeMachineUseCase>(),
      disposePrinter: gh<_i517.DisposePrinterUseCase>(),
    ),
  );
  gh.factory<_i102.FleetMonitorCubit>(
    () => _i102.FleetMonitorCubit(
      getFleetSnapshot: gh<_i26.GetFleetSnapshotUseCase>(),
      observeFleetHeartbeats: gh<_i398.ObserveFleetHeartbeatsUseCase>(),
    ),
  );
  return getIt;
}
