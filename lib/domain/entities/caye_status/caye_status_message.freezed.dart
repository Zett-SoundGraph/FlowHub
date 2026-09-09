// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'caye_status_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CayeStatusMessage {

 String get eventId; int get version; Map<String, dynamic> get data;
/// Create a copy of CayeStatusMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CayeStatusMessageCopyWith<CayeStatusMessage> get copyWith => _$CayeStatusMessageCopyWithImpl<CayeStatusMessage>(this as CayeStatusMessage, _$identity);

  /// Serializes this CayeStatusMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CayeStatusMessage&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,version,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'CayeStatusMessage(eventId: $eventId, version: $version, data: $data)';
}


}

/// @nodoc
abstract mixin class $CayeStatusMessageCopyWith<$Res>  {
  factory $CayeStatusMessageCopyWith(CayeStatusMessage value, $Res Function(CayeStatusMessage) _then) = _$CayeStatusMessageCopyWithImpl;
@useResult
$Res call({
 String eventId, int version, Map<String, dynamic> data
});




}
/// @nodoc
class _$CayeStatusMessageCopyWithImpl<$Res>
    implements $CayeStatusMessageCopyWith<$Res> {
  _$CayeStatusMessageCopyWithImpl(this._self, this._then);

  final CayeStatusMessage _self;
  final $Res Function(CayeStatusMessage) _then;

/// Create a copy of CayeStatusMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventId = null,Object? version = null,Object? data = null,}) {
  return _then(_self.copyWith(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [CayeStatusMessage].
extension CayeStatusMessagePatterns on CayeStatusMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CayeStatusMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CayeStatusMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CayeStatusMessage value)  $default,){
final _that = this;
switch (_that) {
case _CayeStatusMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CayeStatusMessage value)?  $default,){
final _that = this;
switch (_that) {
case _CayeStatusMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String eventId,  int version,  Map<String, dynamic> data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CayeStatusMessage() when $default != null:
return $default(_that.eventId,_that.version,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String eventId,  int version,  Map<String, dynamic> data)  $default,) {final _that = this;
switch (_that) {
case _CayeStatusMessage():
return $default(_that.eventId,_that.version,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String eventId,  int version,  Map<String, dynamic> data)?  $default,) {final _that = this;
switch (_that) {
case _CayeStatusMessage() when $default != null:
return $default(_that.eventId,_that.version,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CayeStatusMessage implements CayeStatusMessage {
  const _CayeStatusMessage({this.eventId = '', this.version = 0, final  Map<String, dynamic> data = const <String, dynamic>{}}): _data = data;
  factory _CayeStatusMessage.fromJson(Map<String, dynamic> json) => _$CayeStatusMessageFromJson(json);

@override@JsonKey() final  String eventId;
@override@JsonKey() final  int version;
 final  Map<String, dynamic> _data;
@override@JsonKey() Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}


/// Create a copy of CayeStatusMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CayeStatusMessageCopyWith<_CayeStatusMessage> get copyWith => __$CayeStatusMessageCopyWithImpl<_CayeStatusMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CayeStatusMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CayeStatusMessage&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,version,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'CayeStatusMessage(eventId: $eventId, version: $version, data: $data)';
}


}

/// @nodoc
abstract mixin class _$CayeStatusMessageCopyWith<$Res> implements $CayeStatusMessageCopyWith<$Res> {
  factory _$CayeStatusMessageCopyWith(_CayeStatusMessage value, $Res Function(_CayeStatusMessage) _then) = __$CayeStatusMessageCopyWithImpl;
@override @useResult
$Res call({
 String eventId, int version, Map<String, dynamic> data
});




}
/// @nodoc
class __$CayeStatusMessageCopyWithImpl<$Res>
    implements _$CayeStatusMessageCopyWith<$Res> {
  __$CayeStatusMessageCopyWithImpl(this._self, this._then);

  final _CayeStatusMessage _self;
  final $Res Function(_CayeStatusMessage) _then;

/// Create a copy of CayeStatusMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? version = null,Object? data = null,}) {
  return _then(_CayeStatusMessage(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
