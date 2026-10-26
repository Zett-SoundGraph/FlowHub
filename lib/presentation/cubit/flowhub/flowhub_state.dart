import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flowhub/domain/entities/index.dart';

part 'flowhub_state.freezed.dart';

@freezed
abstract class FlowHubState with _$FlowHubState {
  const factory FlowHubState({
    required List<Order> orders,
    @Default(false) bool isConnected,
    @Default(false) bool isLabelAttached,
    @Default(false) bool isPrinterConnected,
    @Default(false) bool isCayeConnected,
    // The Shelly plug's own reachability (its Gen2+ online/LWT topic) — see
    // FlowHubCubit's Nudof online subscription. Unlike isCayeConnected/
    // isPrinterConnected, this is sourced identically on every FlowHub
    // instance regardless of leader/follower role (same reasoning as the
    // Raspberry Pi heartbeat row bypassing LeaderUpdateMessage mirroring —
    // the retained MQTT topic is visible to every instance directly).
    @Default(false) bool isNudofOnline,
    // Each WLED guidance light's own `<Device Topic>/status` presence —
    // see FlowHubCubit's _initWledOnline for the subscription. Sourced
    // identically on every FlowHub instance regardless of leader/follower
    // role, same reasoning as isNudofOnline above.
    @Default(false) bool isNudofWledOnline,
    @Default(false) bool isCayeWledOnline,
    @Default(false) bool isCalibrating,
    @Default(920) int calibrationHeight,
    @Default(0) int manufacturingQueueLength,
    // Consecutive-shot test progress (Caye Machine Control screen's test
    // button) — local to whichever device the test is running on (leader
    // only; see FlowHubCubit.startConsecutiveShotTest), not mirrored to
    // followers via LeaderUpdateMessage. shotTestTotal == 0 means no test
    // has been run this session.
    @Default(0) int shotTestTotal,
    @Default(0) int shotTestCompleted,
    DateTime? shotTestStartedAt,
    DateTime? shotTestFinishedAt,
    String? errorMessage,
  }) = _FlowHubState;

  factory FlowHubState.initial() => const FlowHubState(orders: []);
}
