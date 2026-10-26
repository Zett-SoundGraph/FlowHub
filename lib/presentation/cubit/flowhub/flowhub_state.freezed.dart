// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flowhub_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FlowHubState {

 List<Order> get orders; bool get isConnected; bool get isLabelAttached; bool get isPrinterConnected; bool get isCayeConnected;// The Shelly plug's own reachability (its Gen2+ online/LWT topic) — see
// FlowHubCubit's Nudof online subscription. Unlike isCayeConnected/
// isPrinterConnected, this is sourced identically on every FlowHub
// instance regardless of leader/follower role (same reasoning as the
// Raspberry Pi heartbeat row bypassing LeaderUpdateMessage mirroring —
// the retained MQTT topic is visible to every instance directly).
 bool get isNudofOnline;// Each WLED guidance light's own `<Device Topic>/status` presence —
// see FlowHubCubit's _initWledOnline for the subscription. Sourced
// identically on every FlowHub instance regardless of leader/follower
// role, same reasoning as isNudofOnline above.
 bool get isNudofWledOnline; bool get isCayeWledOnline; bool get isCalibrating; int get calibrationHeight; int get manufacturingQueueLength;// Consecutive-shot test progress (Caye Machine Control screen's test
// button) — local to whichever device the test is running on (leader
// only; see FlowHubCubit.startConsecutiveShotTest), not mirrored to
// followers via LeaderUpdateMessage. shotTestTotal == 0 means no test
// has been run this session.
 int get shotTestTotal; int get shotTestCompleted; DateTime? get shotTestStartedAt; DateTime? get shotTestFinishedAt; String? get errorMessage;
/// Create a copy of FlowHubState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlowHubStateCopyWith<FlowHubState> get copyWith => _$FlowHubStateCopyWithImpl<FlowHubState>(this as FlowHubState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FlowHubState&&const DeepCollectionEquality().equals(other.orders, orders)&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected)&&(identical(other.isLabelAttached, isLabelAttached) || other.isLabelAttached == isLabelAttached)&&(identical(other.isPrinterConnected, isPrinterConnected) || other.isPrinterConnected == isPrinterConnected)&&(identical(other.isCayeConnected, isCayeConnected) || other.isCayeConnected == isCayeConnected)&&(identical(other.isNudofOnline, isNudofOnline) || other.isNudofOnline == isNudofOnline)&&(identical(other.isNudofWledOnline, isNudofWledOnline) || other.isNudofWledOnline == isNudofWledOnline)&&(identical(other.isCayeWledOnline, isCayeWledOnline) || other.isCayeWledOnline == isCayeWledOnline)&&(identical(other.isCalibrating, isCalibrating) || other.isCalibrating == isCalibrating)&&(identical(other.calibrationHeight, calibrationHeight) || other.calibrationHeight == calibrationHeight)&&(identical(other.manufacturingQueueLength, manufacturingQueueLength) || other.manufacturingQueueLength == manufacturingQueueLength)&&(identical(other.shotTestTotal, shotTestTotal) || other.shotTestTotal == shotTestTotal)&&(identical(other.shotTestCompleted, shotTestCompleted) || other.shotTestCompleted == shotTestCompleted)&&(identical(other.shotTestStartedAt, shotTestStartedAt) || other.shotTestStartedAt == shotTestStartedAt)&&(identical(other.shotTestFinishedAt, shotTestFinishedAt) || other.shotTestFinishedAt == shotTestFinishedAt)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(orders),isConnected,isLabelAttached,isPrinterConnected,isCayeConnected,isNudofOnline,isNudofWledOnline,isCayeWledOnline,isCalibrating,calibrationHeight,manufacturingQueueLength,shotTestTotal,shotTestCompleted,shotTestStartedAt,shotTestFinishedAt,errorMessage);

@override
String toString() {
  return 'FlowHubState(orders: $orders, isConnected: $isConnected, isLabelAttached: $isLabelAttached, isPrinterConnected: $isPrinterConnected, isCayeConnected: $isCayeConnected, isNudofOnline: $isNudofOnline, isNudofWledOnline: $isNudofWledOnline, isCayeWledOnline: $isCayeWledOnline, isCalibrating: $isCalibrating, calibrationHeight: $calibrationHeight, manufacturingQueueLength: $manufacturingQueueLength, shotTestTotal: $shotTestTotal, shotTestCompleted: $shotTestCompleted, shotTestStartedAt: $shotTestStartedAt, shotTestFinishedAt: $shotTestFinishedAt, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $FlowHubStateCopyWith<$Res>  {
  factory $FlowHubStateCopyWith(FlowHubState value, $Res Function(FlowHubState) _then) = _$FlowHubStateCopyWithImpl;
@useResult
$Res call({
 List<Order> orders, bool isConnected, bool isLabelAttached, bool isPrinterConnected, bool isCayeConnected, bool isNudofOnline, bool isNudofWledOnline, bool isCayeWledOnline, bool isCalibrating, int calibrationHeight, int manufacturingQueueLength, int shotTestTotal, int shotTestCompleted, DateTime? shotTestStartedAt, DateTime? shotTestFinishedAt, String? errorMessage
});




}
/// @nodoc
class _$FlowHubStateCopyWithImpl<$Res>
    implements $FlowHubStateCopyWith<$Res> {
  _$FlowHubStateCopyWithImpl(this._self, this._then);

  final FlowHubState _self;
  final $Res Function(FlowHubState) _then;

/// Create a copy of FlowHubState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orders = null,Object? isConnected = null,Object? isLabelAttached = null,Object? isPrinterConnected = null,Object? isCayeConnected = null,Object? isNudofOnline = null,Object? isNudofWledOnline = null,Object? isCayeWledOnline = null,Object? isCalibrating = null,Object? calibrationHeight = null,Object? manufacturingQueueLength = null,Object? shotTestTotal = null,Object? shotTestCompleted = null,Object? shotTestStartedAt = freezed,Object? shotTestFinishedAt = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
orders: null == orders ? _self.orders : orders // ignore: cast_nullable_to_non_nullable
as List<Order>,isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,isLabelAttached: null == isLabelAttached ? _self.isLabelAttached : isLabelAttached // ignore: cast_nullable_to_non_nullable
as bool,isPrinterConnected: null == isPrinterConnected ? _self.isPrinterConnected : isPrinterConnected // ignore: cast_nullable_to_non_nullable
as bool,isCayeConnected: null == isCayeConnected ? _self.isCayeConnected : isCayeConnected // ignore: cast_nullable_to_non_nullable
as bool,isNudofOnline: null == isNudofOnline ? _self.isNudofOnline : isNudofOnline // ignore: cast_nullable_to_non_nullable
as bool,isNudofWledOnline: null == isNudofWledOnline ? _self.isNudofWledOnline : isNudofWledOnline // ignore: cast_nullable_to_non_nullable
as bool,isCayeWledOnline: null == isCayeWledOnline ? _self.isCayeWledOnline : isCayeWledOnline // ignore: cast_nullable_to_non_nullable
as bool,isCalibrating: null == isCalibrating ? _self.isCalibrating : isCalibrating // ignore: cast_nullable_to_non_nullable
as bool,calibrationHeight: null == calibrationHeight ? _self.calibrationHeight : calibrationHeight // ignore: cast_nullable_to_non_nullable
as int,manufacturingQueueLength: null == manufacturingQueueLength ? _self.manufacturingQueueLength : manufacturingQueueLength // ignore: cast_nullable_to_non_nullable
as int,shotTestTotal: null == shotTestTotal ? _self.shotTestTotal : shotTestTotal // ignore: cast_nullable_to_non_nullable
as int,shotTestCompleted: null == shotTestCompleted ? _self.shotTestCompleted : shotTestCompleted // ignore: cast_nullable_to_non_nullable
as int,shotTestStartedAt: freezed == shotTestStartedAt ? _self.shotTestStartedAt : shotTestStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,shotTestFinishedAt: freezed == shotTestFinishedAt ? _self.shotTestFinishedAt : shotTestFinishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FlowHubState].
extension FlowHubStatePatterns on FlowHubState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FlowHubState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FlowHubState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FlowHubState value)  $default,){
final _that = this;
switch (_that) {
case _FlowHubState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FlowHubState value)?  $default,){
final _that = this;
switch (_that) {
case _FlowHubState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Order> orders,  bool isConnected,  bool isLabelAttached,  bool isPrinterConnected,  bool isCayeConnected,  bool isNudofOnline,  bool isNudofWledOnline,  bool isCayeWledOnline,  bool isCalibrating,  int calibrationHeight,  int manufacturingQueueLength,  int shotTestTotal,  int shotTestCompleted,  DateTime? shotTestStartedAt,  DateTime? shotTestFinishedAt,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FlowHubState() when $default != null:
return $default(_that.orders,_that.isConnected,_that.isLabelAttached,_that.isPrinterConnected,_that.isCayeConnected,_that.isNudofOnline,_that.isNudofWledOnline,_that.isCayeWledOnline,_that.isCalibrating,_that.calibrationHeight,_that.manufacturingQueueLength,_that.shotTestTotal,_that.shotTestCompleted,_that.shotTestStartedAt,_that.shotTestFinishedAt,_that.errorMessage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Order> orders,  bool isConnected,  bool isLabelAttached,  bool isPrinterConnected,  bool isCayeConnected,  bool isNudofOnline,  bool isNudofWledOnline,  bool isCayeWledOnline,  bool isCalibrating,  int calibrationHeight,  int manufacturingQueueLength,  int shotTestTotal,  int shotTestCompleted,  DateTime? shotTestStartedAt,  DateTime? shotTestFinishedAt,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _FlowHubState():
return $default(_that.orders,_that.isConnected,_that.isLabelAttached,_that.isPrinterConnected,_that.isCayeConnected,_that.isNudofOnline,_that.isNudofWledOnline,_that.isCayeWledOnline,_that.isCalibrating,_that.calibrationHeight,_that.manufacturingQueueLength,_that.shotTestTotal,_that.shotTestCompleted,_that.shotTestStartedAt,_that.shotTestFinishedAt,_that.errorMessage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Order> orders,  bool isConnected,  bool isLabelAttached,  bool isPrinterConnected,  bool isCayeConnected,  bool isNudofOnline,  bool isNudofWledOnline,  bool isCayeWledOnline,  bool isCalibrating,  int calibrationHeight,  int manufacturingQueueLength,  int shotTestTotal,  int shotTestCompleted,  DateTime? shotTestStartedAt,  DateTime? shotTestFinishedAt,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _FlowHubState() when $default != null:
return $default(_that.orders,_that.isConnected,_that.isLabelAttached,_that.isPrinterConnected,_that.isCayeConnected,_that.isNudofOnline,_that.isNudofWledOnline,_that.isCayeWledOnline,_that.isCalibrating,_that.calibrationHeight,_that.manufacturingQueueLength,_that.shotTestTotal,_that.shotTestCompleted,_that.shotTestStartedAt,_that.shotTestFinishedAt,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _FlowHubState implements FlowHubState {
  const _FlowHubState({required final  List<Order> orders, this.isConnected = false, this.isLabelAttached = false, this.isPrinterConnected = false, this.isCayeConnected = false, this.isNudofOnline = false, this.isNudofWledOnline = false, this.isCayeWledOnline = false, this.isCalibrating = false, this.calibrationHeight = 920, this.manufacturingQueueLength = 0, this.shotTestTotal = 0, this.shotTestCompleted = 0, this.shotTestStartedAt, this.shotTestFinishedAt, this.errorMessage}): _orders = orders;
  

 final  List<Order> _orders;
@override List<Order> get orders {
  if (_orders is EqualUnmodifiableListView) return _orders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_orders);
}

@override@JsonKey() final  bool isConnected;
@override@JsonKey() final  bool isLabelAttached;
@override@JsonKey() final  bool isPrinterConnected;
@override@JsonKey() final  bool isCayeConnected;
// The Shelly plug's own reachability (its Gen2+ online/LWT topic) — see
// FlowHubCubit's Nudof online subscription. Unlike isCayeConnected/
// isPrinterConnected, this is sourced identically on every FlowHub
// instance regardless of leader/follower role (same reasoning as the
// Raspberry Pi heartbeat row bypassing LeaderUpdateMessage mirroring —
// the retained MQTT topic is visible to every instance directly).
@override@JsonKey() final  bool isNudofOnline;
// Each WLED guidance light's own `<Device Topic>/status` presence —
// see FlowHubCubit's _initWledOnline for the subscription. Sourced
// identically on every FlowHub instance regardless of leader/follower
// role, same reasoning as isNudofOnline above.
@override@JsonKey() final  bool isNudofWledOnline;
@override@JsonKey() final  bool isCayeWledOnline;
@override@JsonKey() final  bool isCalibrating;
@override@JsonKey() final  int calibrationHeight;
@override@JsonKey() final  int manufacturingQueueLength;
// Consecutive-shot test progress (Caye Machine Control screen's test
// button) — local to whichever device the test is running on (leader
// only; see FlowHubCubit.startConsecutiveShotTest), not mirrored to
// followers via LeaderUpdateMessage. shotTestTotal == 0 means no test
// has been run this session.
@override@JsonKey() final  int shotTestTotal;
@override@JsonKey() final  int shotTestCompleted;
@override final  DateTime? shotTestStartedAt;
@override final  DateTime? shotTestFinishedAt;
@override final  String? errorMessage;

/// Create a copy of FlowHubState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FlowHubStateCopyWith<_FlowHubState> get copyWith => __$FlowHubStateCopyWithImpl<_FlowHubState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FlowHubState&&const DeepCollectionEquality().equals(other._orders, _orders)&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected)&&(identical(other.isLabelAttached, isLabelAttached) || other.isLabelAttached == isLabelAttached)&&(identical(other.isPrinterConnected, isPrinterConnected) || other.isPrinterConnected == isPrinterConnected)&&(identical(other.isCayeConnected, isCayeConnected) || other.isCayeConnected == isCayeConnected)&&(identical(other.isNudofOnline, isNudofOnline) || other.isNudofOnline == isNudofOnline)&&(identical(other.isNudofWledOnline, isNudofWledOnline) || other.isNudofWledOnline == isNudofWledOnline)&&(identical(other.isCayeWledOnline, isCayeWledOnline) || other.isCayeWledOnline == isCayeWledOnline)&&(identical(other.isCalibrating, isCalibrating) || other.isCalibrating == isCalibrating)&&(identical(other.calibrationHeight, calibrationHeight) || other.calibrationHeight == calibrationHeight)&&(identical(other.manufacturingQueueLength, manufacturingQueueLength) || other.manufacturingQueueLength == manufacturingQueueLength)&&(identical(other.shotTestTotal, shotTestTotal) || other.shotTestTotal == shotTestTotal)&&(identical(other.shotTestCompleted, shotTestCompleted) || other.shotTestCompleted == shotTestCompleted)&&(identical(other.shotTestStartedAt, shotTestStartedAt) || other.shotTestStartedAt == shotTestStartedAt)&&(identical(other.shotTestFinishedAt, shotTestFinishedAt) || other.shotTestFinishedAt == shotTestFinishedAt)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_orders),isConnected,isLabelAttached,isPrinterConnected,isCayeConnected,isNudofOnline,isNudofWledOnline,isCayeWledOnline,isCalibrating,calibrationHeight,manufacturingQueueLength,shotTestTotal,shotTestCompleted,shotTestStartedAt,shotTestFinishedAt,errorMessage);

@override
String toString() {
  return 'FlowHubState(orders: $orders, isConnected: $isConnected, isLabelAttached: $isLabelAttached, isPrinterConnected: $isPrinterConnected, isCayeConnected: $isCayeConnected, isNudofOnline: $isNudofOnline, isNudofWledOnline: $isNudofWledOnline, isCayeWledOnline: $isCayeWledOnline, isCalibrating: $isCalibrating, calibrationHeight: $calibrationHeight, manufacturingQueueLength: $manufacturingQueueLength, shotTestTotal: $shotTestTotal, shotTestCompleted: $shotTestCompleted, shotTestStartedAt: $shotTestStartedAt, shotTestFinishedAt: $shotTestFinishedAt, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$FlowHubStateCopyWith<$Res> implements $FlowHubStateCopyWith<$Res> {
  factory _$FlowHubStateCopyWith(_FlowHubState value, $Res Function(_FlowHubState) _then) = __$FlowHubStateCopyWithImpl;
@override @useResult
$Res call({
 List<Order> orders, bool isConnected, bool isLabelAttached, bool isPrinterConnected, bool isCayeConnected, bool isNudofOnline, bool isNudofWledOnline, bool isCayeWledOnline, bool isCalibrating, int calibrationHeight, int manufacturingQueueLength, int shotTestTotal, int shotTestCompleted, DateTime? shotTestStartedAt, DateTime? shotTestFinishedAt, String? errorMessage
});




}
/// @nodoc
class __$FlowHubStateCopyWithImpl<$Res>
    implements _$FlowHubStateCopyWith<$Res> {
  __$FlowHubStateCopyWithImpl(this._self, this._then);

  final _FlowHubState _self;
  final $Res Function(_FlowHubState) _then;

/// Create a copy of FlowHubState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orders = null,Object? isConnected = null,Object? isLabelAttached = null,Object? isPrinterConnected = null,Object? isCayeConnected = null,Object? isNudofOnline = null,Object? isNudofWledOnline = null,Object? isCayeWledOnline = null,Object? isCalibrating = null,Object? calibrationHeight = null,Object? manufacturingQueueLength = null,Object? shotTestTotal = null,Object? shotTestCompleted = null,Object? shotTestStartedAt = freezed,Object? shotTestFinishedAt = freezed,Object? errorMessage = freezed,}) {
  return _then(_FlowHubState(
orders: null == orders ? _self._orders : orders // ignore: cast_nullable_to_non_nullable
as List<Order>,isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,isLabelAttached: null == isLabelAttached ? _self.isLabelAttached : isLabelAttached // ignore: cast_nullable_to_non_nullable
as bool,isPrinterConnected: null == isPrinterConnected ? _self.isPrinterConnected : isPrinterConnected // ignore: cast_nullable_to_non_nullable
as bool,isCayeConnected: null == isCayeConnected ? _self.isCayeConnected : isCayeConnected // ignore: cast_nullable_to_non_nullable
as bool,isNudofOnline: null == isNudofOnline ? _self.isNudofOnline : isNudofOnline // ignore: cast_nullable_to_non_nullable
as bool,isNudofWledOnline: null == isNudofWledOnline ? _self.isNudofWledOnline : isNudofWledOnline // ignore: cast_nullable_to_non_nullable
as bool,isCayeWledOnline: null == isCayeWledOnline ? _self.isCayeWledOnline : isCayeWledOnline // ignore: cast_nullable_to_non_nullable
as bool,isCalibrating: null == isCalibrating ? _self.isCalibrating : isCalibrating // ignore: cast_nullable_to_non_nullable
as bool,calibrationHeight: null == calibrationHeight ? _self.calibrationHeight : calibrationHeight // ignore: cast_nullable_to_non_nullable
as int,manufacturingQueueLength: null == manufacturingQueueLength ? _self.manufacturingQueueLength : manufacturingQueueLength // ignore: cast_nullable_to_non_nullable
as int,shotTestTotal: null == shotTestTotal ? _self.shotTestTotal : shotTestTotal // ignore: cast_nullable_to_non_nullable
as int,shotTestCompleted: null == shotTestCompleted ? _self.shotTestCompleted : shotTestCompleted // ignore: cast_nullable_to_non_nullable
as int,shotTestStartedAt: freezed == shotTestStartedAt ? _self.shotTestStartedAt : shotTestStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,shotTestFinishedAt: freezed == shotTestFinishedAt ? _self.shotTestFinishedAt : shotTestFinishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
