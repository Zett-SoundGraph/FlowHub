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
import '../../data/sources/remote/printer_data_source.dart' as _i656;
import '../../domain/exception/base_exception_handler.dart' as _i543;
import '../../domain/repositories/index.dart' as _i445;
import '../../domain/repositories/machine_repository.dart' as _i958;
import '../../domain/repositories/order_repository.dart' as _i507;
import '../../domain/repositories/printer_repository.dart' as _i115;
import '../../domain/repositories/recipe_repository.dart' as _i197;
import '../../domain/usecases/check_machine_availability_usecase.dart' as _i201;
import '../../domain/usecases/complete_cooking_usecase.dart' as _i110;
import '../../domain/usecases/complete_pickup_usecase.dart' as _i500;
import '../../domain/usecases/connect_order_socket_usecase.dart' as _i6;
import '../../domain/usecases/disconnect_order_socket_usecase.dart' as _i479;
import '../../domain/usecases/dispose_machine_usecase.dart' as _i202;
import '../../domain/usecases/dispose_printer_usecase.dart' as _i203;
import '../../domain/usecases/get_recipe_usecase.dart' as _i510;
import '../../domain/usecases/observe_barcode_scan_usecase.dart' as _i174;
import '../../domain/usecases/observe_calibration_status_usecase.dart' as _i204;
import '../../domain/usecases/observe_machine_connection_usecase.dart' as _i205;
import '../../domain/usecases/observe_machine_progress_usecase.dart' as _i804;
import '../../domain/usecases/observe_order_connection_usecase.dart' as _i628;
import '../../domain/usecases/observe_pickup_complete_usecase.dart' as _i640;
import '../../domain/usecases/observe_printer_status_usecase.dart' as _i328;
import '../../domain/usecases/print_label_usecase.dart' as _i206;
import '../../domain/usecases/send_cancel_command_usecase.dart' as _i207;
import '../../domain/usecases/send_cleaning_command_usecase.dart' as _i208;
import '../../domain/usecases/send_make_command_usecase.dart' as _i209;
import '../../domain/usecases/send_query_status_usecase.dart' as _i210;
import '../../domain/usecases/send_rinsing_command_usecase.dart' as _i211;
import '../../domain/usecases/send_time_sync_usecase.dart' as _i212;
import '../../domain/usecases/send_today_extraction_history_usecase.dart' as _i213;
import '../../domain/usecases/start_calibration_usecase.dart' as _i583;
import '../../presentation/cubit/caye/caye_management_cubit.dart' as _i214;
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
  gh.singleton<_i507.OrderRepository>(
    () => _i717.OrderRepositoryImpl(
      gh<_i919.IKdsSocketDataSource>(),
      // gh<_i792.IBarcodeScanDataSource>(), // WebSocket 방식으로 대체됨
    ),
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
  gh.factory<_i583.StartCalibrationUseCase>(
    () => _i583.StartCalibrationUseCase(gh<_i507.OrderRepository>()),
  );
  gh.singleton<_i115.PrinterRepository>(
    () => _i514.PrinterRepositoryImpl(gh<_i656.IPrinterDataSource>()),
  );
  gh.singleton<_i197.RecipeRepository>(
    () => _i869.RecipeRepositoryImpl(gh<_i489.IRecipeDataSource>()),
  );
  gh.factory<_i174.ObserveBarcodeScanUseCase>(
    () => _i174.ObserveBarcodeScanUseCase(gh<_i507.OrderRepository>()),
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
  gh.factory<_i328.ObservePrinterStatusUseCase>(
    () => _i328.ObservePrinterStatusUseCase(gh<_i115.PrinterRepository>()),
  );
  gh.factory<_i510.GetRecipeUseCase>(
    () => _i510.GetRecipeUseCase(gh<_i197.RecipeRepository>()),
  );
  // MachineRepository-based UseCases
  gh.factory<_i201.CheckMachineAvailabilityUseCase>(
    () => _i201.CheckMachineAvailabilityUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i209.SendMakeCommandUseCase>(
    () => _i209.SendMakeCommandUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i207.SendCancelCommandUseCase>(
    () => _i207.SendCancelCommandUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i211.SendRinsingCommandUseCase>(
    () => _i211.SendRinsingCommandUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i208.SendCleaningCommandUseCase>(
    () => _i208.SendCleaningCommandUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i210.SendQueryStatusUseCase>(
    () => _i210.SendQueryStatusUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i212.SendTimeSyncUseCase>(
    () => _i212.SendTimeSyncUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i213.SendTodayExtractionHistoryUseCase>(
    () => _i213.SendTodayExtractionHistoryUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i205.ObserveMachineConnectionUseCase>(
    () => _i205.ObserveMachineConnectionUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i202.DisposeMachineUseCase>(
    () => _i202.DisposeMachineUseCase(gh<_i958.MachineRepository>()),
  );
  // PrinterRepository-based UseCases
  gh.factory<_i206.PrintLabelUseCase>(
    () => _i206.PrintLabelUseCase(gh<_i115.PrinterRepository>()),
  );
  gh.factory<_i203.DisposePrinterUseCase>(
    () => _i203.DisposePrinterUseCase(gh<_i115.PrinterRepository>()),
  );
  // OrderRepository-based UseCases
  gh.factory<_i204.ObserveCalibrationStatusUseCase>(
    () => _i204.ObserveCalibrationStatusUseCase(gh<_i507.OrderRepository>()),
  );
  // CayeManagementCubit
  gh.factory<_i214.CayeManagementCubit>(
    () => _i214.CayeManagementCubit(
      observeMachineConnection: gh<_i205.ObserveMachineConnectionUseCase>(),
      sendCancelCommand: gh<_i207.SendCancelCommandUseCase>(),
      sendRinsingCommand: gh<_i211.SendRinsingCommandUseCase>(),
      sendCleaningCommand: gh<_i208.SendCleaningCommandUseCase>(),
      sendQueryStatus: gh<_i210.SendQueryStatusUseCase>(),
      sendTimeSync: gh<_i212.SendTimeSyncUseCase>(),
      sendTodayExtractionHistory: gh<_i213.SendTodayExtractionHistoryUseCase>(),
    ),
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
      checkMachineAvailability: gh<_i201.CheckMachineAvailabilityUseCase>(),
      sendMakeCommand: gh<_i209.SendMakeCommandUseCase>(),
      sendCancelCommand: gh<_i207.SendCancelCommandUseCase>(),
      observePrinterStatus: gh<_i328.ObservePrinterStatusUseCase>(),
      printLabel: gh<_i206.PrintLabelUseCase>(),
      startCalibration: gh<_i583.StartCalibrationUseCase>(),
      getRecipe: gh<_i510.GetRecipeUseCase>(),
      observeCalibrationStatus: gh<_i204.ObserveCalibrationStatusUseCase>(),
      disposeMachine: gh<_i202.DisposeMachineUseCase>(),
      disposePrinter: gh<_i203.DisposePrinterUseCase>(),
    ),
  );
  return getIt;
}
