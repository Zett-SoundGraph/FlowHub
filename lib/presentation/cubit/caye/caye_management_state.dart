import 'package:freezed_annotation/freezed_annotation.dart';

part 'caye_management_state.freezed.dart';

@freezed
abstract class CayeManagementState with _$CayeManagementState {
  const factory CayeManagementState({
    @Default(false) bool isConnected,
  }) = _CayeManagementState;
}
