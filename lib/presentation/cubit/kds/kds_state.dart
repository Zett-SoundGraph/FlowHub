import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flowhub/domain/entities/index.dart';

part 'kds_state.freezed.dart';

@freezed
abstract class KdsState with _$KdsState {
  const factory KdsState({
    required List<Order> orders,
    @Default(false) bool isConnected,
    @Default(false) bool isLabelAttached,
    @Default(false) bool isPrinterConnected,
    @Default(false) bool isCayeConnected,
    @Default(false) bool isCalibrating,
    @Default(920) int calibrationHeight,
    @Default(0) int manufacturingQueueLength,
    // Consecutive-shot test progress (Caye Machine Control screen's test
    // button) — local to whichever device the test is running on (leader
    // only; see KdsCubit.startConsecutiveShotTest), not mirrored to
    // followers via LeaderUpdateMessage. shotTestTotal == 0 means no test
    // has been run this session.
    @Default(0) int shotTestTotal,
    @Default(0) int shotTestCompleted,
    DateTime? shotTestStartedAt,
    DateTime? shotTestFinishedAt,
    String? errorMessage,
  }) = _KdsState;

  factory KdsState.initial() => const KdsState(orders: []);
}
