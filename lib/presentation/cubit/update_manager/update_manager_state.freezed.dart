// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_manager_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdateManagerState {

 UpdateManagerStatus get status;// FlowManager store ID from the device record; empty until loaded.
 String get storeId; List<StoreDevice> get devices;// Update requests FlowManager still has open for the store.
 int get pending;// Latest progress report per deviceId (highest seq).
 Map<String, FlowAppUpdateProgress> get progress;// Devices whose update request is being sent right now.
 Set<String> get requesting;// One-line result or error for the operator; null when there is none.
 String? get message; DateTime? get loadedAt;
/// Create a copy of UpdateManagerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateManagerStateCopyWith<UpdateManagerState> get copyWith => _$UpdateManagerStateCopyWithImpl<UpdateManagerState>(this as UpdateManagerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateManagerState&&(identical(other.status, status) || other.status == status)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&const DeepCollectionEquality().equals(other.devices, devices)&&(identical(other.pending, pending) || other.pending == pending)&&const DeepCollectionEquality().equals(other.progress, progress)&&const DeepCollectionEquality().equals(other.requesting, requesting)&&(identical(other.message, message) || other.message == message)&&(identical(other.loadedAt, loadedAt) || other.loadedAt == loadedAt));
}


@override
int get hashCode => Object.hash(runtimeType,status,storeId,const DeepCollectionEquality().hash(devices),pending,const DeepCollectionEquality().hash(progress),const DeepCollectionEquality().hash(requesting),message,loadedAt);

@override
String toString() {
  return 'UpdateManagerState(status: $status, storeId: $storeId, devices: $devices, pending: $pending, progress: $progress, requesting: $requesting, message: $message, loadedAt: $loadedAt)';
}


}

/// @nodoc
abstract mixin class $UpdateManagerStateCopyWith<$Res>  {
  factory $UpdateManagerStateCopyWith(UpdateManagerState value, $Res Function(UpdateManagerState) _then) = _$UpdateManagerStateCopyWithImpl;
@useResult
$Res call({
 UpdateManagerStatus status, String storeId, List<StoreDevice> devices, int pending, Map<String, FlowAppUpdateProgress> progress, Set<String> requesting, String? message, DateTime? loadedAt
});




}
/// @nodoc
class _$UpdateManagerStateCopyWithImpl<$Res>
    implements $UpdateManagerStateCopyWith<$Res> {
  _$UpdateManagerStateCopyWithImpl(this._self, this._then);

  final UpdateManagerState _self;
  final $Res Function(UpdateManagerState) _then;

/// Create a copy of UpdateManagerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? storeId = null,Object? devices = null,Object? pending = null,Object? progress = null,Object? requesting = null,Object? message = freezed,Object? loadedAt = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UpdateManagerStatus,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,devices: null == devices ? _self.devices : devices // ignore: cast_nullable_to_non_nullable
as List<StoreDevice>,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as Map<String, FlowAppUpdateProgress>,requesting: null == requesting ? _self.requesting : requesting // ignore: cast_nullable_to_non_nullable
as Set<String>,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,loadedAt: freezed == loadedAt ? _self.loadedAt : loadedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateManagerState].
extension UpdateManagerStatePatterns on UpdateManagerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateManagerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateManagerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateManagerState value)  $default,){
final _that = this;
switch (_that) {
case _UpdateManagerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateManagerState value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateManagerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UpdateManagerStatus status,  String storeId,  List<StoreDevice> devices,  int pending,  Map<String, FlowAppUpdateProgress> progress,  Set<String> requesting,  String? message,  DateTime? loadedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateManagerState() when $default != null:
return $default(_that.status,_that.storeId,_that.devices,_that.pending,_that.progress,_that.requesting,_that.message,_that.loadedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UpdateManagerStatus status,  String storeId,  List<StoreDevice> devices,  int pending,  Map<String, FlowAppUpdateProgress> progress,  Set<String> requesting,  String? message,  DateTime? loadedAt)  $default,) {final _that = this;
switch (_that) {
case _UpdateManagerState():
return $default(_that.status,_that.storeId,_that.devices,_that.pending,_that.progress,_that.requesting,_that.message,_that.loadedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UpdateManagerStatus status,  String storeId,  List<StoreDevice> devices,  int pending,  Map<String, FlowAppUpdateProgress> progress,  Set<String> requesting,  String? message,  DateTime? loadedAt)?  $default,) {final _that = this;
switch (_that) {
case _UpdateManagerState() when $default != null:
return $default(_that.status,_that.storeId,_that.devices,_that.pending,_that.progress,_that.requesting,_that.message,_that.loadedAt);case _:
  return null;

}
}

}

/// @nodoc


class _UpdateManagerState implements UpdateManagerState {
  const _UpdateManagerState({this.status = UpdateManagerStatus.loading, this.storeId = '', final  List<StoreDevice> devices = const <StoreDevice>[], this.pending = 0, final  Map<String, FlowAppUpdateProgress> progress = const <String, FlowAppUpdateProgress>{}, final  Set<String> requesting = const <String>{}, this.message, this.loadedAt}): _devices = devices,_progress = progress,_requesting = requesting;
  

@override@JsonKey() final  UpdateManagerStatus status;
// FlowManager store ID from the device record; empty until loaded.
@override@JsonKey() final  String storeId;
 final  List<StoreDevice> _devices;
@override@JsonKey() List<StoreDevice> get devices {
  if (_devices is EqualUnmodifiableListView) return _devices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_devices);
}

// Update requests FlowManager still has open for the store.
@override@JsonKey() final  int pending;
// Latest progress report per deviceId (highest seq).
 final  Map<String, FlowAppUpdateProgress> _progress;
// Latest progress report per deviceId (highest seq).
@override@JsonKey() Map<String, FlowAppUpdateProgress> get progress {
  if (_progress is EqualUnmodifiableMapView) return _progress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_progress);
}

// Devices whose update request is being sent right now.
 final  Set<String> _requesting;
// Devices whose update request is being sent right now.
@override@JsonKey() Set<String> get requesting {
  if (_requesting is EqualUnmodifiableSetView) return _requesting;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_requesting);
}

// One-line result or error for the operator; null when there is none.
@override final  String? message;
@override final  DateTime? loadedAt;

/// Create a copy of UpdateManagerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateManagerStateCopyWith<_UpdateManagerState> get copyWith => __$UpdateManagerStateCopyWithImpl<_UpdateManagerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateManagerState&&(identical(other.status, status) || other.status == status)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&const DeepCollectionEquality().equals(other._devices, _devices)&&(identical(other.pending, pending) || other.pending == pending)&&const DeepCollectionEquality().equals(other._progress, _progress)&&const DeepCollectionEquality().equals(other._requesting, _requesting)&&(identical(other.message, message) || other.message == message)&&(identical(other.loadedAt, loadedAt) || other.loadedAt == loadedAt));
}


@override
int get hashCode => Object.hash(runtimeType,status,storeId,const DeepCollectionEquality().hash(_devices),pending,const DeepCollectionEquality().hash(_progress),const DeepCollectionEquality().hash(_requesting),message,loadedAt);

@override
String toString() {
  return 'UpdateManagerState(status: $status, storeId: $storeId, devices: $devices, pending: $pending, progress: $progress, requesting: $requesting, message: $message, loadedAt: $loadedAt)';
}


}

/// @nodoc
abstract mixin class _$UpdateManagerStateCopyWith<$Res> implements $UpdateManagerStateCopyWith<$Res> {
  factory _$UpdateManagerStateCopyWith(_UpdateManagerState value, $Res Function(_UpdateManagerState) _then) = __$UpdateManagerStateCopyWithImpl;
@override @useResult
$Res call({
 UpdateManagerStatus status, String storeId, List<StoreDevice> devices, int pending, Map<String, FlowAppUpdateProgress> progress, Set<String> requesting, String? message, DateTime? loadedAt
});




}
/// @nodoc
class __$UpdateManagerStateCopyWithImpl<$Res>
    implements _$UpdateManagerStateCopyWith<$Res> {
  __$UpdateManagerStateCopyWithImpl(this._self, this._then);

  final _UpdateManagerState _self;
  final $Res Function(_UpdateManagerState) _then;

/// Create a copy of UpdateManagerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? storeId = null,Object? devices = null,Object? pending = null,Object? progress = null,Object? requesting = null,Object? message = freezed,Object? loadedAt = freezed,}) {
  return _then(_UpdateManagerState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UpdateManagerStatus,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as String,devices: null == devices ? _self._devices : devices // ignore: cast_nullable_to_non_nullable
as List<StoreDevice>,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,progress: null == progress ? _self._progress : progress // ignore: cast_nullable_to_non_nullable
as Map<String, FlowAppUpdateProgress>,requesting: null == requesting ? _self._requesting : requesting // ignore: cast_nullable_to_non_nullable
as Set<String>,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,loadedAt: freezed == loadedAt ? _self.loadedAt : loadedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
