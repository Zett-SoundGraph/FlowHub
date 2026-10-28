// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nudof_control_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NudofControlState {

// The Shelly plug's own reachability (its Gen2+ online/LWT topic) — the
// same signal Device Management's "Nudof Machine(M)" row shows, NOT
// whether this FlowHub device itself is connected to the broker (that
// wouldn't tell you anything about the plug specifically).
 bool get isOnline;// null until the first switch:0 status arrives — distinct from `false`
// (confirmed off) so the UI can show "—" instead of a wrong guess.
 bool? get isOutputOn; double? get apower; DateTime? get lastUpdated;// TEST/LOG-ONLY signal — see NudofControlCubit's class doc comment.
 bool get isDispensing;
/// Create a copy of NudofControlState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NudofControlStateCopyWith<NudofControlState> get copyWith => _$NudofControlStateCopyWithImpl<NudofControlState>(this as NudofControlState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NudofControlState&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.isOutputOn, isOutputOn) || other.isOutputOn == isOutputOn)&&(identical(other.apower, apower) || other.apower == apower)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.isDispensing, isDispensing) || other.isDispensing == isDispensing));
}


@override
int get hashCode => Object.hash(runtimeType,isOnline,isOutputOn,apower,lastUpdated,isDispensing);

@override
String toString() {
  return 'NudofControlState(isOnline: $isOnline, isOutputOn: $isOutputOn, apower: $apower, lastUpdated: $lastUpdated, isDispensing: $isDispensing)';
}


}

/// @nodoc
abstract mixin class $NudofControlStateCopyWith<$Res>  {
  factory $NudofControlStateCopyWith(NudofControlState value, $Res Function(NudofControlState) _then) = _$NudofControlStateCopyWithImpl;
@useResult
$Res call({
 bool isOnline, bool? isOutputOn, double? apower, DateTime? lastUpdated, bool isDispensing
});




}
/// @nodoc
class _$NudofControlStateCopyWithImpl<$Res>
    implements $NudofControlStateCopyWith<$Res> {
  _$NudofControlStateCopyWithImpl(this._self, this._then);

  final NudofControlState _self;
  final $Res Function(NudofControlState) _then;

/// Create a copy of NudofControlState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isOnline = null,Object? isOutputOn = freezed,Object? apower = freezed,Object? lastUpdated = freezed,Object? isDispensing = null,}) {
  return _then(_self.copyWith(
isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,isOutputOn: freezed == isOutputOn ? _self.isOutputOn : isOutputOn // ignore: cast_nullable_to_non_nullable
as bool?,apower: freezed == apower ? _self.apower : apower // ignore: cast_nullable_to_non_nullable
as double?,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,isDispensing: null == isDispensing ? _self.isDispensing : isDispensing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NudofControlState].
extension NudofControlStatePatterns on NudofControlState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NudofControlState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NudofControlState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NudofControlState value)  $default,){
final _that = this;
switch (_that) {
case _NudofControlState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NudofControlState value)?  $default,){
final _that = this;
switch (_that) {
case _NudofControlState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isOnline,  bool? isOutputOn,  double? apower,  DateTime? lastUpdated,  bool isDispensing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NudofControlState() when $default != null:
return $default(_that.isOnline,_that.isOutputOn,_that.apower,_that.lastUpdated,_that.isDispensing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isOnline,  bool? isOutputOn,  double? apower,  DateTime? lastUpdated,  bool isDispensing)  $default,) {final _that = this;
switch (_that) {
case _NudofControlState():
return $default(_that.isOnline,_that.isOutputOn,_that.apower,_that.lastUpdated,_that.isDispensing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isOnline,  bool? isOutputOn,  double? apower,  DateTime? lastUpdated,  bool isDispensing)?  $default,) {final _that = this;
switch (_that) {
case _NudofControlState() when $default != null:
return $default(_that.isOnline,_that.isOutputOn,_that.apower,_that.lastUpdated,_that.isDispensing);case _:
  return null;

}
}

}

/// @nodoc


class _NudofControlState implements NudofControlState {
  const _NudofControlState({this.isOnline = false, this.isOutputOn, this.apower, this.lastUpdated, this.isDispensing = false});
  

// The Shelly plug's own reachability (its Gen2+ online/LWT topic) — the
// same signal Device Management's "Nudof Machine(M)" row shows, NOT
// whether this FlowHub device itself is connected to the broker (that
// wouldn't tell you anything about the plug specifically).
@override@JsonKey() final  bool isOnline;
// null until the first switch:0 status arrives — distinct from `false`
// (confirmed off) so the UI can show "—" instead of a wrong guess.
@override final  bool? isOutputOn;
@override final  double? apower;
@override final  DateTime? lastUpdated;
// TEST/LOG-ONLY signal — see NudofControlCubit's class doc comment.
@override@JsonKey() final  bool isDispensing;

/// Create a copy of NudofControlState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NudofControlStateCopyWith<_NudofControlState> get copyWith => __$NudofControlStateCopyWithImpl<_NudofControlState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NudofControlState&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.isOutputOn, isOutputOn) || other.isOutputOn == isOutputOn)&&(identical(other.apower, apower) || other.apower == apower)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated)&&(identical(other.isDispensing, isDispensing) || other.isDispensing == isDispensing));
}


@override
int get hashCode => Object.hash(runtimeType,isOnline,isOutputOn,apower,lastUpdated,isDispensing);

@override
String toString() {
  return 'NudofControlState(isOnline: $isOnline, isOutputOn: $isOutputOn, apower: $apower, lastUpdated: $lastUpdated, isDispensing: $isDispensing)';
}


}

/// @nodoc
abstract mixin class _$NudofControlStateCopyWith<$Res> implements $NudofControlStateCopyWith<$Res> {
  factory _$NudofControlStateCopyWith(_NudofControlState value, $Res Function(_NudofControlState) _then) = __$NudofControlStateCopyWithImpl;
@override @useResult
$Res call({
 bool isOnline, bool? isOutputOn, double? apower, DateTime? lastUpdated, bool isDispensing
});




}
/// @nodoc
class __$NudofControlStateCopyWithImpl<$Res>
    implements _$NudofControlStateCopyWith<$Res> {
  __$NudofControlStateCopyWithImpl(this._self, this._then);

  final _NudofControlState _self;
  final $Res Function(_NudofControlState) _then;

/// Create a copy of NudofControlState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isOnline = null,Object? isOutputOn = freezed,Object? apower = freezed,Object? lastUpdated = freezed,Object? isDispensing = null,}) {
  return _then(_NudofControlState(
isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,isOutputOn: freezed == isOutputOn ? _self.isOutputOn : isOutputOn // ignore: cast_nullable_to_non_nullable
as bool?,apower: freezed == apower ? _self.apower : apower // ignore: cast_nullable_to_non_nullable
as double?,lastUpdated: freezed == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime?,isDispensing: null == isDispensing ? _self.isDispensing : isDispensing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
