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
import '../../data/repositories/menu_repository_impl.dart' as _i668;
import '../../data/repositories/order_history_repository_impl.dart' as _i1008;
import '../../data/repositories/order_repository_impl.dart' as _i717;
import '../../data/repositories/printer_repository_impl.dart' as _i514;
import '../../data/repositories/receipt_printer_repository_impl.dart' as _i211;
import '../../data/sources/local/caye_key_data_source.dart' as _i819;
import '../../data/sources/local/order_history_data_source.dart' as _i871;
import '../../data/sources/remote/caye_machine_data_source.dart' as _i422;
import '../../data/sources/remote/kds_barcode_scan_data_source.dart' as _i792;
import '../../data/sources/remote/kds_socket_data_source.dart' as _i919;
import '../../data/sources/remote/menu_sheet_data_source.dart' as _i25;
import '../../data/sources/remote/mqtt_data_source.dart' as _i126;
import '../../data/sources/remote/printer_data_source.dart' as _i656;
import '../../data/sources/remote/receipt_printer_data_source.dart' as _i879;
import '../../domain/exception/base_exception_handler.dart' as _i543;
import '../../domain/repositories/index.dart' as _i445;
import '../../domain/repositories/machine_repository.dart' as _i958;
import '../../domain/repositories/menu_repository.dart' as _i196;
import '../../domain/repositories/order_history_repository.dart' as _i158;
import '../../domain/repositories/order_repository.dart' as _i507;
import '../../domain/repositories/printer_repository.dart' as _i115;
import '../../domain/repositories/receipt_printer_repository.dart' as _i85;
import '../../domain/usecases/append_order_history_usecase.dart' as _i7;
import '../../domain/usecases/check_machine_availability_usecase.dart' as _i893;
import '../../domain/usecases/complete_cooking_usecase.dart' as _i110;
import '../../domain/usecases/complete_pickup_usecase.dart' as _i500;
import '../../domain/usecases/connect_order_socket_usecase.dart' as _i6;
import '../../domain/usecases/disconnect_order_socket_usecase.dart' as _i479;
import '../../domain/usecases/dispose_machine_usecase.dart' as _i135;
import '../../domain/usecases/dispose_printer_usecase.dart' as _i517;
import '../../domain/usecases/get_caye_api_key_usecase.dart' as _i1017;
import '../../domain/usecases/get_fleet_snapshot_usecase.dart' as _i26;
import '../../domain/usecases/get_label_options_usecase.dart' as _i208;
import '../../domain/usecases/get_machine_connection_snapshot_usecase.dart'
    as _i849;
import '../../domain/usecases/get_menu_info_by_sku_usecase.dart' as _i212;
import '../../domain/usecases/get_menu_info_usecase.dart' as _i586;
import '../../domain/usecases/get_menu_ingredients_usecase.dart' as _i33;
import '../../domain/usecases/get_recipe_dispenser_usecase.dart' as _i624;
import '../../domain/usecases/get_recipe_image_usecase.dart' as _i308;
import '../../domain/usecases/get_recipe_ingredient_labels_usecase.dart'
    as _i939;
import '../../domain/usecases/get_recipe_popup_ingredients_usecase.dart'
    as _i996;
import '../../domain/usecases/get_recipe_timing_usecase.dart' as _i534;
import '../../domain/usecases/get_recipe_version_usecase.dart' as _i279;
import '../../domain/usecases/observe_barcode_scan_usecase.dart' as _i174;
import '../../domain/usecases/observe_calibration_status_usecase.dart' as _i5;
import '../../domain/usecases/observe_fleet_heartbeats_usecase.dart' as _i398;
import '../../domain/usecases/observe_follower_sync_request_usecase.dart'
    as _i282;
import '../../domain/usecases/observe_kiosk_order_usecase.dart' as _i999;
import '../../domain/usecases/observe_leader_update_usecase.dart' as _i606;
import '../../domain/usecases/observe_machine_connection_usecase.dart' as _i847;
import '../../domain/usecases/observe_machine_progress_usecase.dart' as _i804;
import '../../domain/usecases/observe_order_connection_usecase.dart' as _i628;
import '../../domain/usecases/observe_pickup_complete_usecase.dart' as _i640;
import '../../domain/usecases/observe_printer_connection_usecase.dart' as _i397;
import '../../domain/usecases/observe_printer_status_usecase.dart' as _i328;
import '../../domain/usecases/observe_qr_complete_usecase.dart' as _i754;
import '../../domain/usecases/print_label_usecase.dart' as _i413;
import '../../domain/usecases/print_receipt_usecase.dart' as _i537;
import '../../domain/usecases/publish_board_update_usecase.dart' as _i836;
import '../../domain/usecases/publish_caye_cleaning_usecase.dart' as _i859;
import '../../domain/usecases/publish_caye_fault_usecase.dart' as _i786;
import '../../domain/usecases/publish_caye_rinsing_usecase.dart' as _i971;
import '../../domain/usecases/publish_caye_status_usecase.dart' as _i151;
import '../../domain/usecases/publish_follower_sync_usecase.dart' as _i878;
import '../../domain/usecases/publish_kiosk_update_usecase.dart' as _i265;
import '../../domain/usecases/publish_leader_update_usecase.dart' as _i563;
import '../../domain/usecases/publish_wled_api_usecase.dart' as _i761;
import '../../domain/usecases/publish_wled_power_usecase.dart' as _i130;
import '../../domain/usecases/reconnect_printer_usecase.dart' as _i593;
import '../../domain/usecases/resolve_menu_options_usecase.dart' as _i617;
import '../../domain/usecases/send_cancel_command_usecase.dart' as _i622;
import '../../domain/usecases/send_cleaning_command_usecase.dart' as _i682;
import '../../domain/usecases/send_extraction_history_usecase.dart' as _i819;
import '../../domain/usecases/send_make_command_usecase.dart' as _i1052;
import '../../domain/usecases/send_query_status_usecase.dart' as _i460;
import '../../domain/usecases/send_rinsing_command_usecase.dart' as _i68;
import '../../domain/usecases/send_time_sync_usecase.dart' as _i627;
import '../../domain/usecases/set_awaiting_detach_usecase.dart' as _i900;
import '../../domain/usecases/set_caye_api_key_usecase.dart' as _i189;
import '../../domain/usecases/start_calibration_usecase.dart' as _i583;
import '../../domain/usecases/sync_recipe_data_usecase.dart' as _i248;
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
  gh.factory<_i543.BaseExceptionHandler>(() => _i3.CommonExceptionHandler());
  gh.singleton<_i25.IMenuSheetDataSource>(() => _i25.MenuSheetDataSource());
  gh.singleton<_i819.ICayeKeyDataSource>(() => _i819.CayeKeyDataSource());
  gh.singleton<_i126.IMqttDataSource>(() => _i126.MqttDataSource());
  gh.singleton<_i919.IKdsSocketDataSource>(() => _i919.KdsSocketDataSource());
  gh.singleton<_i422.ICayeMachineDataSource>(
    () => _i422.CayeMachineDataSource(gh<_i819.ICayeKeyDataSource>()),
  );
  gh.singleton<_i656.IPrinterDataSource>(() => _i656.PrinterDataSource());
  gh.singleton<_i792.IBarcodeScanDataSource>(
    () => _i792.KdsBarcodeScanDataSource(),
  );
  gh.singleton<_i115.PrinterRepository>(
    () => _i514.PrinterRepositoryImpl(gh<_i656.IPrinterDataSource>()),
  );
  gh.singleton<_i871.IOrderHistoryDataSource>(
    () => _i871.OrderHistoryDataSource(),
  );
  gh.singleton<_i879.IReceiptPrinterDataSource>(
    () => _i879.ReceiptPrinterDataSource(),
  );
  gh.factory<_i397.ObservePrinterConnectionUseCase>(
    () => _i397.ObservePrinterConnectionUseCase(gh<_i115.PrinterRepository>()),
  );
  gh.factory<_i328.ObservePrinterStatusUseCase>(
    () => _i328.ObservePrinterStatusUseCase(gh<_i115.PrinterRepository>()),
  );
  gh.singleton<_i958.MachineRepository>(
    () => _i1003.MachineRepositoryImpl(gh<_i422.ICayeMachineDataSource>()),
  );
  gh.factory<_i517.DisposePrinterUseCase>(
    () => _i517.DisposePrinterUseCase(gh<_i115.PrinterRepository>()),
  );
  gh.factory<_i413.PrintLabelUseCase>(
    () => _i413.PrintLabelUseCase(gh<_i115.PrinterRepository>()),
  );
  gh.factory<_i593.ReconnectPrinterUseCase>(
    () => _i593.ReconnectPrinterUseCase(gh<_i115.PrinterRepository>()),
  );
  gh.factory<_i900.SetAwaitingDetachUseCase>(
    () => _i900.SetAwaitingDetachUseCase(gh<_i115.PrinterRepository>()),
  );
  gh.factory<_i893.CheckMachineAvailabilityUseCase>(
    () => _i893.CheckMachineAvailabilityUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i135.DisposeMachineUseCase>(
    () => _i135.DisposeMachineUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i1017.GetCayeApiKeyUseCase>(
    () => _i1017.GetCayeApiKeyUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i849.GetMachineConnectionSnapshotUseCase>(
    () => _i849.GetMachineConnectionSnapshotUseCase(
      gh<_i958.MachineRepository>(),
    ),
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
  gh.factory<_i819.SendExtractionHistoryUseCase>(
    () => _i819.SendExtractionHistoryUseCase(gh<_i958.MachineRepository>()),
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
  gh.factory<_i189.SetCayeApiKeyUseCase>(
    () => _i189.SetCayeApiKeyUseCase(gh<_i958.MachineRepository>()),
  );
  gh.singleton<_i158.OrderHistoryRepository>(
    () =>
        _i1008.OrderHistoryRepositoryImpl(gh<_i871.IOrderHistoryDataSource>()),
  );
  gh.singleton<_i196.MenuRepository>(
    () => _i668.MenuRepositoryImpl(gh<_i25.IMenuSheetDataSource>()),
  );
  gh.singleton<_i85.ReceiptPrinterRepository>(
    () => _i211.ReceiptPrinterRepositoryImpl(
      gh<_i879.IReceiptPrinterDataSource>(),
    ),
  );
  gh.singleton<_i507.OrderRepository>(
    () => _i717.OrderRepositoryImpl(
      gh<_i919.IKdsSocketDataSource>(),
      gh<_i126.IMqttDataSource>(),
    ),
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
  gh.factory<_i282.ObserveFollowerSyncRequestUseCase>(
    () => _i282.ObserveFollowerSyncRequestUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i999.ObserveKioskOrderUseCase>(
    () => _i999.ObserveKioskOrderUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i606.ObserveLeaderUpdateUseCase>(
    () => _i606.ObserveLeaderUpdateUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i628.ObserveOrderConnectionUseCase>(
    () => _i628.ObserveOrderConnectionUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i836.PublishBoardUpdateUseCase>(
    () => _i836.PublishBoardUpdateUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i859.PublishCayeCleaningUseCase>(
    () => _i859.PublishCayeCleaningUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i786.PublishCayeFaultUseCase>(
    () => _i786.PublishCayeFaultUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i971.PublishCayeRinsingUseCase>(
    () => _i971.PublishCayeRinsingUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i151.PublishCayeStatusUseCase>(
    () => _i151.PublishCayeStatusUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i878.PublishFollowerSyncUseCase>(
    () => _i878.PublishFollowerSyncUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i265.PublishKioskUpdateUseCase>(
    () => _i265.PublishKioskUpdateUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i563.PublishLeaderUpdateUseCase>(
    () => _i563.PublishLeaderUpdateUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i761.PublishWledApiUseCase>(
    () => _i761.PublishWledApiUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i130.PublishWledPowerUseCase>(
    () => _i130.PublishWledPowerUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i583.StartCalibrationUseCase>(
    () => _i583.StartCalibrationUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i110.CompleteCookingUseCase>(
    () => _i110.CompleteCookingUseCase(gh<_i445.OrderRepository>()),
  );
  gh.factory<_i500.CompletePickupUseCase>(
    () => _i500.CompletePickupUseCase(gh<_i445.OrderRepository>()),
  );
  gh.factory<_i537.PrintReceiptUseCase>(
    () => _i537.PrintReceiptUseCase(gh<_i85.ReceiptPrinterRepository>()),
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
  gh.factory<_i754.ObserveQrCompleteUseCase>(
    () => _i754.ObserveQrCompleteUseCase(gh<_i507.OrderRepository>()),
  );
  gh.factory<_i102.FleetMonitorCubit>(
    () => _i102.FleetMonitorCubit(
      getFleetSnapshot: gh<_i26.GetFleetSnapshotUseCase>(),
      observeFleetHeartbeats: gh<_i398.ObserveFleetHeartbeatsUseCase>(),
    ),
  );
  gh.factory<_i804.ObserveMachineProgressUseCase>(
    () => _i804.ObserveMachineProgressUseCase(gh<_i958.MachineRepository>()),
  );
  gh.factory<_i7.AppendOrderHistoryUseCase>(
    () => _i7.AppendOrderHistoryUseCase(gh<_i158.OrderHistoryRepository>()),
  );
  gh.factory<_i208.GetLabelOptionsUseCase>(
    () => _i208.GetLabelOptionsUseCase(gh<_i196.MenuRepository>()),
  );
  gh.factory<_i212.GetMenuInfoBySkuUseCase>(
    () => _i212.GetMenuInfoBySkuUseCase(gh<_i196.MenuRepository>()),
  );
  gh.factory<_i586.GetMenuInfoUseCase>(
    () => _i586.GetMenuInfoUseCase(gh<_i196.MenuRepository>()),
  );
  gh.factory<_i33.GetMenuIngredientsUseCase>(
    () => _i33.GetMenuIngredientsUseCase(gh<_i196.MenuRepository>()),
  );
  gh.factory<_i624.GetRecipeDispenserUseCase>(
    () => _i624.GetRecipeDispenserUseCase(gh<_i196.MenuRepository>()),
  );
  gh.factory<_i308.GetRecipeImageUseCase>(
    () => _i308.GetRecipeImageUseCase(gh<_i196.MenuRepository>()),
  );
  gh.factory<_i939.GetRecipeIngredientLabelsUseCase>(
    () => _i939.GetRecipeIngredientLabelsUseCase(gh<_i196.MenuRepository>()),
  );
  gh.factory<_i996.GetRecipePopupIngredientsUseCase>(
    () => _i996.GetRecipePopupIngredientsUseCase(gh<_i196.MenuRepository>()),
  );
  gh.factory<_i534.GetRecipeTimingUseCase>(
    () => _i534.GetRecipeTimingUseCase(gh<_i196.MenuRepository>()),
  );
  gh.factory<_i279.GetRecipeVersionUseCase>(
    () => _i279.GetRecipeVersionUseCase(gh<_i196.MenuRepository>()),
  );
  gh.factory<_i617.ResolveMenuOptionsUseCase>(
    () => _i617.ResolveMenuOptionsUseCase(gh<_i196.MenuRepository>()),
  );
  gh.factory<_i248.SyncRecipeDataUseCase>(
    () => _i248.SyncRecipeDataUseCase(gh<_i196.MenuRepository>()),
  );
  gh.factory<_i776.CayeManagementCubit>(
    () => _i776.CayeManagementCubit(
      observeMachineConnection: gh<_i847.ObserveMachineConnectionUseCase>(),
      getMachineConnectionSnapshot:
          gh<_i849.GetMachineConnectionSnapshotUseCase>(),
      sendCancelCommand: gh<_i622.SendCancelCommandUseCase>(),
      sendRinsingCommand: gh<_i68.SendRinsingCommandUseCase>(),
      sendCleaningCommand: gh<_i682.SendCleaningCommandUseCase>(),
      sendQueryStatus: gh<_i460.SendQueryStatusUseCase>(),
      sendTimeSync: gh<_i627.SendTimeSyncUseCase>(),
      sendExtractionHistory: gh<_i819.SendExtractionHistoryUseCase>(),
      observeMachineProgress: gh<_i804.ObserveMachineProgressUseCase>(),
      publishFollowerSync: gh<_i878.PublishFollowerSyncUseCase>(),
      getCayeApiKey: gh<_i1017.GetCayeApiKeyUseCase>(),
      setCayeApiKey: gh<_i189.SetCayeApiKeyUseCase>(),
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
      observeQrComplete: gh<_i754.ObserveQrCompleteUseCase>(),
      observePickupComplete: gh<_i640.ObservePickupCompleteUseCase>(),
      observeKioskOrder: gh<_i999.ObserveKioskOrderUseCase>(),
      observeMachineProgress: gh<_i804.ObserveMachineProgressUseCase>(),
      checkMachineAvailability: gh<_i893.CheckMachineAvailabilityUseCase>(),
      sendQueryStatus: gh<_i460.SendQueryStatusUseCase>(),
      sendMakeCommand: gh<_i1052.SendMakeCommandUseCase>(),
      sendCancelCommand: gh<_i622.SendCancelCommandUseCase>(),
      observePrinterStatus: gh<_i328.ObservePrinterStatusUseCase>(),
      observePrinterConnection: gh<_i397.ObservePrinterConnectionUseCase>(),
      observeMachineConnection: gh<_i847.ObserveMachineConnectionUseCase>(),
      getMachineConnectionSnapshot:
          gh<_i849.GetMachineConnectionSnapshotUseCase>(),
      printLabel: gh<_i413.PrintLabelUseCase>(),
      printReceipt: gh<_i537.PrintReceiptUseCase>(),
      reconnectPrinter: gh<_i593.ReconnectPrinterUseCase>(),
      setAwaitingDetach: gh<_i900.SetAwaitingDetachUseCase>(),
      appendOrderHistory: gh<_i7.AppendOrderHistoryUseCase>(),
      startCalibration: gh<_i583.StartCalibrationUseCase>(),
      syncRecipeData: gh<_i248.SyncRecipeDataUseCase>(),
      getMenuInfo: gh<_i586.GetMenuInfoUseCase>(),
      getMenuInfoBySku: gh<_i212.GetMenuInfoBySkuUseCase>(),
      getRecipeTiming: gh<_i534.GetRecipeTimingUseCase>(),
      getRecipeDispenser: gh<_i624.GetRecipeDispenserUseCase>(),
      getRecipeImage: gh<_i308.GetRecipeImageUseCase>(),
      getRecipeVersion: gh<_i279.GetRecipeVersionUseCase>(),
      getRecipeIngredientLabels: gh<_i939.GetRecipeIngredientLabelsUseCase>(),
      getRecipePopupIngredients: gh<_i996.GetRecipePopupIngredientsUseCase>(),
      getLabelOptions: gh<_i208.GetLabelOptionsUseCase>(),
      getMenuIngredients: gh<_i33.GetMenuIngredientsUseCase>(),
      resolveMenuOptions: gh<_i617.ResolveMenuOptionsUseCase>(),
      observeCalibrationStatus: gh<_i5.ObserveCalibrationStatusUseCase>(),
      disposeMachine: gh<_i135.DisposeMachineUseCase>(),
      disposePrinter: gh<_i517.DisposePrinterUseCase>(),
      observeLeaderUpdate: gh<_i606.ObserveLeaderUpdateUseCase>(),
      observeFollowerSyncRequest: gh<_i282.ObserveFollowerSyncRequestUseCase>(),
      publishLeaderUpdate: gh<_i563.PublishLeaderUpdateUseCase>(),
      publishFollowerSync: gh<_i878.PublishFollowerSyncUseCase>(),
      publishBoardUpdate: gh<_i836.PublishBoardUpdateUseCase>(),
      publishKioskUpdate: gh<_i265.PublishKioskUpdateUseCase>(),
      publishCayeFault: gh<_i786.PublishCayeFaultUseCase>(),
      publishCayeStatus: gh<_i151.PublishCayeStatusUseCase>(),
      publishCayeRinsing: gh<_i971.PublishCayeRinsingUseCase>(),
      publishCayeCleaning: gh<_i859.PublishCayeCleaningUseCase>(),
      sendRinsingCommand: gh<_i68.SendRinsingCommandUseCase>(),
      sendCleaningCommand: gh<_i682.SendCleaningCommandUseCase>(),
      sendTimeSync: gh<_i627.SendTimeSyncUseCase>(),
      setCayeApiKey: gh<_i189.SetCayeApiKeyUseCase>(),
    ),
  );
  return getIt;
}
