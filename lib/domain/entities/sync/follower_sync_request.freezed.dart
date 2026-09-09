// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follower_sync_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FollowerSyncRequest {

 String get sync; String get eventId; int get version; Map<String, dynamic> get params;
/// Create a copy of FollowerSyncRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowerSyncRequestCopyWith<FollowerSyncRequest> get copyWith => _$FollowerSyncRequestCopyWithImpl<FollowerSyncRequest>(this as FollowerSyncRequest, _$identity);

  /// Serializes this FollowerSyncRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowerSyncRequest&&(identical(other.sync, sync) || other.sync == sync)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.params, params));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sync,eventId,version,const DeepCollectionEquality().hash(params));

@override
String toString() {
  return 'FollowerSyncRequest(sync: $sync, eventId: $eventId, version: $version, params: $params)';
}


}

/// @nodoc
abstract mixin class $FollowerSyncRequestCopyWith<$Res>  {
  factory $FollowerSyncRequestCopyWith(FollowerSyncRequest value, $Res Function(FollowerSyncRequest) _then) = _$FollowerSyncRequestCopyWithImpl;
@useResult
$Res call({
 String sync, String eventId, int version, Map<String, dynamic> params
});




}
/// @nodoc
class _$FollowerSyncRequestCopyWithImpl<$Res>
    implements $FollowerSyncRequestCopyWith<$Res> {
  _$FollowerSyncRequestCopyWithImpl(this._self, this._then);

  final FollowerSyncRequest _self;
  final $Res Function(FollowerSyncRequest) _then;

/// Create a copy of FollowerSyncRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sync = null,Object? eventId = null,Object? version = null,Object? params = null,}) {
  return _then(_self.copyWith(
sync: null == sync ? _self.sync : sync // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,params: null == params ? _self.params : params // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [FollowerSyncRequest].
extension FollowerSyncRequestPatterns on FollowerSyncRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowerSyncRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowerSyncRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowerSyncRequest value)  $default,){
final _that = this;
switch (_that) {
case _FollowerSyncRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowerSyncRequest value)?  $default,){
final _that = this;
switch (_that) {
case _FollowerSyncRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sync,  String eventId,  int version,  Map<String, dynamic> params)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowerSyncRequest() when $default != null:
return $default(_that.sync,_that.eventId,_that.version,_that.params);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sync,  String eventId,  int version,  Map<String, dynamic> params)  $default,) {final _that = this;
switch (_that) {
case _FollowerSyncRequest():
return $default(_that.sync,_that.eventId,_that.version,_that.params);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sync,  String eventId,  int version,  Map<String, dynamic> params)?  $default,) {final _that = this;
switch (_that) {
case _FollowerSyncRequest() when $default != null:
return $default(_that.sync,_that.eventId,_that.version,_that.params);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FollowerSyncRequest implements FollowerSyncRequest {
  const _FollowerSyncRequest({required this.sync, this.eventId = '', this.version = 0, final  Map<String, dynamic> params = const {}}): _params = params;
  factory _FollowerSyncRequest.fromJson(Map<String, dynamic> json) => _$FollowerSyncRequestFromJson(json);

@override final  String sync;
@override@JsonKey() final  String eventId;
@override@JsonKey() final  int version;
 final  Map<String, dynamic> _params;
@override@JsonKey() Map<String, dynamic> get params {
  if (_params is EqualUnmodifiableMapView) return _params;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_params);
}


/// Create a copy of FollowerSyncRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowerSyncRequestCopyWith<_FollowerSyncRequest> get copyWith => __$FollowerSyncRequestCopyWithImpl<_FollowerSyncRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowerSyncRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowerSyncRequest&&(identical(other.sync, sync) || other.sync == sync)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other._params, _params));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sync,eventId,version,const DeepCollectionEquality().hash(_params));

@override
String toString() {
  return 'FollowerSyncRequest(sync: $sync, eventId: $eventId, version: $version, params: $params)';
}


}

/// @nodoc
abstract mixin class _$FollowerSyncRequestCopyWith<$Res> implements $FollowerSyncRequestCopyWith<$Res> {
  factory _$FollowerSyncRequestCopyWith(_FollowerSyncRequest value, $Res Function(_FollowerSyncRequest) _then) = __$FollowerSyncRequestCopyWithImpl;
@override @useResult
$Res call({
 String sync, String eventId, int version, Map<String, dynamic> params
});




}
/// @nodoc
class __$FollowerSyncRequestCopyWithImpl<$Res>
    implements _$FollowerSyncRequestCopyWith<$Res> {
  __$FollowerSyncRequestCopyWithImpl(this._self, this._then);

  final _FollowerSyncRequest _self;
  final $Res Function(_FollowerSyncRequest) _then;

/// Create a copy of FollowerSyncRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sync = null,Object? eventId = null,Object? version = null,Object? params = null,}) {
  return _then(_FollowerSyncRequest(
sync: null == sync ? _self.sync : sync // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,params: null == params ? _self._params : params // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
