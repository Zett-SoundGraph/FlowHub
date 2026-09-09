// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fleet_monitor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FleetMonitorState {

 Map<String, DateTime> get deviceLastSeen;// Newest first. Capped at [FleetMonitorCubit.maxLogEntries] to bound memory.
 List<FleetHeartbeatEvent> get logEntries; FleetMonitorViewMode get viewMode;
/// Create a copy of FleetMonitorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FleetMonitorStateCopyWith<FleetMonitorState> get copyWith => _$FleetMonitorStateCopyWithImpl<FleetMonitorState>(this as FleetMonitorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FleetMonitorState&&const DeepCollectionEquality().equals(other.deviceLastSeen, deviceLastSeen)&&const DeepCollectionEquality().equals(other.logEntries, logEntries)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(deviceLastSeen),const DeepCollectionEquality().hash(logEntries),viewMode);

@override
String toString() {
  return 'FleetMonitorState(deviceLastSeen: $deviceLastSeen, logEntries: $logEntries, viewMode: $viewMode)';
}


}

/// @nodoc
abstract mixin class $FleetMonitorStateCopyWith<$Res>  {
  factory $FleetMonitorStateCopyWith(FleetMonitorState value, $Res Function(FleetMonitorState) _then) = _$FleetMonitorStateCopyWithImpl;
@useResult
$Res call({
 Map<String, DateTime> deviceLastSeen, List<FleetHeartbeatEvent> logEntries, FleetMonitorViewMode viewMode
});




}
/// @nodoc
class _$FleetMonitorStateCopyWithImpl<$Res>
    implements $FleetMonitorStateCopyWith<$Res> {
  _$FleetMonitorStateCopyWithImpl(this._self, this._then);

  final FleetMonitorState _self;
  final $Res Function(FleetMonitorState) _then;

/// Create a copy of FleetMonitorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deviceLastSeen = null,Object? logEntries = null,Object? viewMode = null,}) {
  return _then(_self.copyWith(
deviceLastSeen: null == deviceLastSeen ? _self.deviceLastSeen : deviceLastSeen // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,logEntries: null == logEntries ? _self.logEntries : logEntries // ignore: cast_nullable_to_non_nullable
as List<FleetHeartbeatEvent>,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as FleetMonitorViewMode,
  ));
}

}


/// Adds pattern-matching-related methods to [FleetMonitorState].
extension FleetMonitorStatePatterns on FleetMonitorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FleetMonitorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FleetMonitorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FleetMonitorState value)  $default,){
final _that = this;
switch (_that) {
case _FleetMonitorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FleetMonitorState value)?  $default,){
final _that = this;
switch (_that) {
case _FleetMonitorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, DateTime> deviceLastSeen,  List<FleetHeartbeatEvent> logEntries,  FleetMonitorViewMode viewMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FleetMonitorState() when $default != null:
return $default(_that.deviceLastSeen,_that.logEntries,_that.viewMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, DateTime> deviceLastSeen,  List<FleetHeartbeatEvent> logEntries,  FleetMonitorViewMode viewMode)  $default,) {final _that = this;
switch (_that) {
case _FleetMonitorState():
return $default(_that.deviceLastSeen,_that.logEntries,_that.viewMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, DateTime> deviceLastSeen,  List<FleetHeartbeatEvent> logEntries,  FleetMonitorViewMode viewMode)?  $default,) {final _that = this;
switch (_that) {
case _FleetMonitorState() when $default != null:
return $default(_that.deviceLastSeen,_that.logEntries,_that.viewMode);case _:
  return null;

}
}

}

/// @nodoc


class _FleetMonitorState implements FleetMonitorState {
  const _FleetMonitorState({final  Map<String, DateTime> deviceLastSeen = const {}, final  List<FleetHeartbeatEvent> logEntries = const [], this.viewMode = FleetMonitorViewMode.log}): _deviceLastSeen = deviceLastSeen,_logEntries = logEntries;
  

 final  Map<String, DateTime> _deviceLastSeen;
@override@JsonKey() Map<String, DateTime> get deviceLastSeen {
  if (_deviceLastSeen is EqualUnmodifiableMapView) return _deviceLastSeen;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_deviceLastSeen);
}

// Newest first. Capped at [FleetMonitorCubit.maxLogEntries] to bound memory.
 final  List<FleetHeartbeatEvent> _logEntries;
// Newest first. Capped at [FleetMonitorCubit.maxLogEntries] to bound memory.
@override@JsonKey() List<FleetHeartbeatEvent> get logEntries {
  if (_logEntries is EqualUnmodifiableListView) return _logEntries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_logEntries);
}

@override@JsonKey() final  FleetMonitorViewMode viewMode;

/// Create a copy of FleetMonitorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FleetMonitorStateCopyWith<_FleetMonitorState> get copyWith => __$FleetMonitorStateCopyWithImpl<_FleetMonitorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FleetMonitorState&&const DeepCollectionEquality().equals(other._deviceLastSeen, _deviceLastSeen)&&const DeepCollectionEquality().equals(other._logEntries, _logEntries)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_deviceLastSeen),const DeepCollectionEquality().hash(_logEntries),viewMode);

@override
String toString() {
  return 'FleetMonitorState(deviceLastSeen: $deviceLastSeen, logEntries: $logEntries, viewMode: $viewMode)';
}


}

/// @nodoc
abstract mixin class _$FleetMonitorStateCopyWith<$Res> implements $FleetMonitorStateCopyWith<$Res> {
  factory _$FleetMonitorStateCopyWith(_FleetMonitorState value, $Res Function(_FleetMonitorState) _then) = __$FleetMonitorStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, DateTime> deviceLastSeen, List<FleetHeartbeatEvent> logEntries, FleetMonitorViewMode viewMode
});




}
/// @nodoc
class __$FleetMonitorStateCopyWithImpl<$Res>
    implements _$FleetMonitorStateCopyWith<$Res> {
  __$FleetMonitorStateCopyWithImpl(this._self, this._then);

  final _FleetMonitorState _self;
  final $Res Function(_FleetMonitorState) _then;

/// Create a copy of FleetMonitorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deviceLastSeen = null,Object? logEntries = null,Object? viewMode = null,}) {
  return _then(_FleetMonitorState(
deviceLastSeen: null == deviceLastSeen ? _self._deviceLastSeen : deviceLastSeen // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,logEntries: null == logEntries ? _self._logEntries : logEntries // ignore: cast_nullable_to_non_nullable
as List<FleetHeartbeatEvent>,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as FleetMonitorViewMode,
  ));
}


}

// dart format on
