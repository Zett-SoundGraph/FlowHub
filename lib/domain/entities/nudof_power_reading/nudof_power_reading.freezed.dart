// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nudof_power_reading.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NudofPowerReading {

 bool get output; double get apower; double get voltage; double get current; DateTime get timestamp;
/// Create a copy of NudofPowerReading
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NudofPowerReadingCopyWith<NudofPowerReading> get copyWith => _$NudofPowerReadingCopyWithImpl<NudofPowerReading>(this as NudofPowerReading, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NudofPowerReading&&(identical(other.output, output) || other.output == output)&&(identical(other.apower, apower) || other.apower == apower)&&(identical(other.voltage, voltage) || other.voltage == voltage)&&(identical(other.current, current) || other.current == current)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}


@override
int get hashCode => Object.hash(runtimeType,output,apower,voltage,current,timestamp);

@override
String toString() {
  return 'NudofPowerReading(output: $output, apower: $apower, voltage: $voltage, current: $current, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $NudofPowerReadingCopyWith<$Res>  {
  factory $NudofPowerReadingCopyWith(NudofPowerReading value, $Res Function(NudofPowerReading) _then) = _$NudofPowerReadingCopyWithImpl;
@useResult
$Res call({
 bool output, double apower, double voltage, double current, DateTime timestamp
});




}
/// @nodoc
class _$NudofPowerReadingCopyWithImpl<$Res>
    implements $NudofPowerReadingCopyWith<$Res> {
  _$NudofPowerReadingCopyWithImpl(this._self, this._then);

  final NudofPowerReading _self;
  final $Res Function(NudofPowerReading) _then;

/// Create a copy of NudofPowerReading
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? output = null,Object? apower = null,Object? voltage = null,Object? current = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
output: null == output ? _self.output : output // ignore: cast_nullable_to_non_nullable
as bool,apower: null == apower ? _self.apower : apower // ignore: cast_nullable_to_non_nullable
as double,voltage: null == voltage ? _self.voltage : voltage // ignore: cast_nullable_to_non_nullable
as double,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as double,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [NudofPowerReading].
extension NudofPowerReadingPatterns on NudofPowerReading {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NudofPowerReading value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NudofPowerReading() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NudofPowerReading value)  $default,){
final _that = this;
switch (_that) {
case _NudofPowerReading():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NudofPowerReading value)?  $default,){
final _that = this;
switch (_that) {
case _NudofPowerReading() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool output,  double apower,  double voltage,  double current,  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NudofPowerReading() when $default != null:
return $default(_that.output,_that.apower,_that.voltage,_that.current,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool output,  double apower,  double voltage,  double current,  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _NudofPowerReading():
return $default(_that.output,_that.apower,_that.voltage,_that.current,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool output,  double apower,  double voltage,  double current,  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _NudofPowerReading() when $default != null:
return $default(_that.output,_that.apower,_that.voltage,_that.current,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc


class _NudofPowerReading implements NudofPowerReading {
  const _NudofPowerReading({required this.output, required this.apower, required this.voltage, required this.current, required this.timestamp});
  

@override final  bool output;
@override final  double apower;
@override final  double voltage;
@override final  double current;
@override final  DateTime timestamp;

/// Create a copy of NudofPowerReading
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NudofPowerReadingCopyWith<_NudofPowerReading> get copyWith => __$NudofPowerReadingCopyWithImpl<_NudofPowerReading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NudofPowerReading&&(identical(other.output, output) || other.output == output)&&(identical(other.apower, apower) || other.apower == apower)&&(identical(other.voltage, voltage) || other.voltage == voltage)&&(identical(other.current, current) || other.current == current)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}


@override
int get hashCode => Object.hash(runtimeType,output,apower,voltage,current,timestamp);

@override
String toString() {
  return 'NudofPowerReading(output: $output, apower: $apower, voltage: $voltage, current: $current, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$NudofPowerReadingCopyWith<$Res> implements $NudofPowerReadingCopyWith<$Res> {
  factory _$NudofPowerReadingCopyWith(_NudofPowerReading value, $Res Function(_NudofPowerReading) _then) = __$NudofPowerReadingCopyWithImpl;
@override @useResult
$Res call({
 bool output, double apower, double voltage, double current, DateTime timestamp
});




}
/// @nodoc
class __$NudofPowerReadingCopyWithImpl<$Res>
    implements _$NudofPowerReadingCopyWith<$Res> {
  __$NudofPowerReadingCopyWithImpl(this._self, this._then);

  final _NudofPowerReading _self;
  final $Res Function(_NudofPowerReading) _then;

/// Create a copy of NudofPowerReading
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? output = null,Object? apower = null,Object? voltage = null,Object? current = null,Object? timestamp = null,}) {
  return _then(_NudofPowerReading(
output: null == output ? _self.output : output // ignore: cast_nullable_to_non_nullable
as bool,apower: null == apower ? _self.apower : apower // ignore: cast_nullable_to_non_nullable
as double,voltage: null == voltage ? _self.voltage : voltage // ignore: cast_nullable_to_non_nullable
as double,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as double,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
