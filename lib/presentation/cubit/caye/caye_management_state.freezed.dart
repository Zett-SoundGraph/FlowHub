// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'caye_management_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CayeManagementState {

 bool get isConnected;// Empty until the persisted key (if any) finishes loading — see
// CayeManagementCubit's constructor.
 String get apiKey;
/// Create a copy of CayeManagementState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CayeManagementStateCopyWith<CayeManagementState> get copyWith => _$CayeManagementStateCopyWithImpl<CayeManagementState>(this as CayeManagementState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CayeManagementState&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected)&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey));
}


@override
int get hashCode => Object.hash(runtimeType,isConnected,apiKey);

@override
String toString() {
  return 'CayeManagementState(isConnected: $isConnected, apiKey: $apiKey)';
}


}

/// @nodoc
abstract mixin class $CayeManagementStateCopyWith<$Res>  {
  factory $CayeManagementStateCopyWith(CayeManagementState value, $Res Function(CayeManagementState) _then) = _$CayeManagementStateCopyWithImpl;
@useResult
$Res call({
 bool isConnected, String apiKey
});




}
/// @nodoc
class _$CayeManagementStateCopyWithImpl<$Res>
    implements $CayeManagementStateCopyWith<$Res> {
  _$CayeManagementStateCopyWithImpl(this._self, this._then);

  final CayeManagementState _self;
  final $Res Function(CayeManagementState) _then;

/// Create a copy of CayeManagementState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isConnected = null,Object? apiKey = null,}) {
  return _then(_self.copyWith(
isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,apiKey: null == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CayeManagementState].
extension CayeManagementStatePatterns on CayeManagementState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CayeManagementState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CayeManagementState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CayeManagementState value)  $default,){
final _that = this;
switch (_that) {
case _CayeManagementState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CayeManagementState value)?  $default,){
final _that = this;
switch (_that) {
case _CayeManagementState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isConnected,  String apiKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CayeManagementState() when $default != null:
return $default(_that.isConnected,_that.apiKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isConnected,  String apiKey)  $default,) {final _that = this;
switch (_that) {
case _CayeManagementState():
return $default(_that.isConnected,_that.apiKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isConnected,  String apiKey)?  $default,) {final _that = this;
switch (_that) {
case _CayeManagementState() when $default != null:
return $default(_that.isConnected,_that.apiKey);case _:
  return null;

}
}

}

/// @nodoc


class _CayeManagementState implements CayeManagementState {
  const _CayeManagementState({this.isConnected = false, this.apiKey = ''});
  

@override@JsonKey() final  bool isConnected;
// Empty until the persisted key (if any) finishes loading — see
// CayeManagementCubit's constructor.
@override@JsonKey() final  String apiKey;

/// Create a copy of CayeManagementState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CayeManagementStateCopyWith<_CayeManagementState> get copyWith => __$CayeManagementStateCopyWithImpl<_CayeManagementState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CayeManagementState&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected)&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey));
}


@override
int get hashCode => Object.hash(runtimeType,isConnected,apiKey);

@override
String toString() {
  return 'CayeManagementState(isConnected: $isConnected, apiKey: $apiKey)';
}


}

/// @nodoc
abstract mixin class _$CayeManagementStateCopyWith<$Res> implements $CayeManagementStateCopyWith<$Res> {
  factory _$CayeManagementStateCopyWith(_CayeManagementState value, $Res Function(_CayeManagementState) _then) = __$CayeManagementStateCopyWithImpl;
@override @useResult
$Res call({
 bool isConnected, String apiKey
});




}
/// @nodoc
class __$CayeManagementStateCopyWithImpl<$Res>
    implements _$CayeManagementStateCopyWith<$Res> {
  __$CayeManagementStateCopyWithImpl(this._self, this._then);

  final _CayeManagementState _self;
  final $Res Function(_CayeManagementState) _then;

/// Create a copy of CayeManagementState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isConnected = null,Object? apiKey = null,}) {
  return _then(_CayeManagementState(
isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,apiKey: null == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
