import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:kds/domain/usecases/observe_machine_connection_usecase.dart';
import 'package:kds/domain/usecases/send_cancel_command_usecase.dart';
import 'package:kds/domain/usecases/send_cleaning_command_usecase.dart';
import 'package:kds/domain/usecases/send_query_status_usecase.dart';
import 'package:kds/domain/usecases/send_rinsing_command_usecase.dart';
import 'package:kds/domain/usecases/send_time_sync_usecase.dart';
import 'package:kds/domain/usecases/send_today_extraction_history_usecase.dart';

import 'caye_management_state.dart';

@injectable
class CayeManagementCubit extends Cubit<CayeManagementState> {
  final ObserveMachineConnectionUseCase _observeMachineConnection;
  final SendCancelCommandUseCase _sendCancelCommand;
  final SendRinsingCommandUseCase _sendRinsingCommand;
  final SendCleaningCommandUseCase _sendCleaningCommand;
  final SendQueryStatusUseCase _sendQueryStatus;
  final SendTimeSyncUseCase _sendTimeSync;
  final SendTodayExtractionHistoryUseCase _sendTodayExtractionHistory;

  StreamSubscription<bool>? _connectionSubscription;

  CayeManagementCubit({
    required ObserveMachineConnectionUseCase observeMachineConnection,
    required SendCancelCommandUseCase sendCancelCommand,
    required SendRinsingCommandUseCase sendRinsingCommand,
    required SendCleaningCommandUseCase sendCleaningCommand,
    required SendQueryStatusUseCase sendQueryStatus,
    required SendTimeSyncUseCase sendTimeSync,
    required SendTodayExtractionHistoryUseCase sendTodayExtractionHistory,
  })  : _observeMachineConnection = observeMachineConnection,
        _sendCancelCommand = sendCancelCommand,
        _sendRinsingCommand = sendRinsingCommand,
        _sendCleaningCommand = sendCleaningCommand,
        _sendQueryStatus = sendQueryStatus,
        _sendTimeSync = sendTimeSync,
        _sendTodayExtractionHistory = sendTodayExtractionHistory,
        super(const CayeManagementState()) {
    _connectionSubscription = _observeMachineConnection().listen((connected) {
      emit(state.copyWith(isConnected: connected));
    });
  }

  Future<void> sendCancelCommand(String ip, String productKey, String orderNo) async {
    await _sendCancelCommand((ip: ip, productKey: productKey, orderNo: orderNo));
  }

  Future<void> sendRinsingCommand(String ip) => _sendRinsingCommand(ip);

  Future<void> sendCleaningCommand(String ip, {int mode = 0}) async {
    await _sendCleaningCommand((ip: ip, mode: mode));
  }

  Future<void> sendQueryStatus(String ip) => _sendQueryStatus(ip);

  Future<void> sendTimeSync(String ip) => _sendTimeSync(ip);

  Future<void> sendTodayExtractionHistory(String ip) async {
    await _sendTodayExtractionHistory(ip);
  }

  @override
  Future<void> close() async {
    await _connectionSubscription?.cancel();
    return super.close();
  }
}
