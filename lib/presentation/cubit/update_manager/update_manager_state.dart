import 'package:flowhub/domain/entities/flow_installation/flow_app_update_progress.dart';
import 'package:flowhub/domain/entities/flow_installation/store_device.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_manager_state.freezed.dart';

/// Loading state of the Update Manager screen.
enum UpdateManagerStatus { loading, ready, error }

@freezed
abstract class UpdateManagerState with _$UpdateManagerState {
  const factory UpdateManagerState({
    @Default(UpdateManagerStatus.loading) UpdateManagerStatus status,
    // FlowManager store ID from the device record; empty until loaded.
    @Default('') String storeId,
    @Default(<StoreDevice>[]) List<StoreDevice> devices,
    // Update requests FlowManager still has open for the store.
    @Default(0) int pending,
    // Latest progress report per deviceId (highest seq).
    @Default(<String, FlowAppUpdateProgress>{})
    Map<String, FlowAppUpdateProgress> progress,
    // Devices whose update request is being sent right now.
    @Default(<String>{}) Set<String> requesting,
    // One-line result or error for the operator; null when there is none.
    String? message,
    DateTime? loadedAt,
  }) = _UpdateManagerState;
}
