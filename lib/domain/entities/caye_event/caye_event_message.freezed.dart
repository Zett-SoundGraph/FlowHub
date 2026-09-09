// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'caye_event_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CayeEventMessage {

 String get eventId; int get version; int get status; List<String> get faults;
/// Create a copy of CayeEventMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CayeEventMessageCopyWith<CayeEventMessage> get copyWith => _$CayeEventMessageCopyWithImpl<CayeEventMessage>(this as CayeEventMessage, _$identity);

  /// Serializes this CayeEventMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CayeEventMessage&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.version, version) || other.version == version)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.faults, faults));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,version,status,const DeepCollectionEquality().hash(faults));

@override
String toString() {
  return 'CayeEventMessage(eventId: $eventId, version: $version, status: $status, faults: $faults)';
}


}

/// @nodoc
abstract mixin class $CayeEventMessageCopyWith<$Res>  {
  factory $CayeEventMessageCopyWith(CayeEventMessage value, $Res Function(CayeEventMessage) _then) = _$CayeEventMessageCopyWithImpl;
@useResult
$Res call({
 String eventId, int version, int status, List<String> faults
});




}
/// @nodoc
class _$CayeEventMessageCopyWithImpl<$Res>
    implements $CayeEventMessageCopyWith<$Res> {
  _$CayeEventMessageCopyWithImpl(this._self, this._then);

  final CayeEventMessage _self;
  final $Res Function(CayeEventMessage) _then;

/// Create a copy of CayeEventMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventId = null,Object? version = null,Object? status = null,Object? faults = null,}) {
  return _then(_self.copyWith(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,faults: null == faults ? _self.faults : faults // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CayeEventMessage].
extension CayeEventMessagePatterns on CayeEventMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CayeEventMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CayeEventMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CayeEventMessage value)  $default,){
final _that = this;
switch (_that) {
case _CayeEventMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CayeEventMessage value)?  $default,){
final _that = this;
switch (_that) {
case _CayeEventMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String eventId,  int version,  int status,  List<String> faults)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CayeEventMessage() when $default != null:
return $default(_that.eventId,_that.version,_that.status,_that.faults);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String eventId,  int version,  int status,  List<String> faults)  $default,) {final _that = this;
switch (_that) {
case _CayeEventMessage():
return $default(_that.eventId,_that.version,_that.status,_that.faults);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String eventId,  int version,  int status,  List<String> faults)?  $default,) {final _that = this;
switch (_that) {
case _CayeEventMessage() when $default != null:
return $default(_that.eventId,_that.version,_that.status,_that.faults);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CayeEventMessage implements CayeEventMessage {
  const _CayeEventMessage({this.eventId = '', this.version = 0, this.status = 0, final  List<String> faults = const []}): _faults = faults;
  factory _CayeEventMessage.fromJson(Map<String, dynamic> json) => _$CayeEventMessageFromJson(json);

@override@JsonKey() final  String eventId;
@override@JsonKey() final  int version;
@override@JsonKey() final  int status;
 final  List<String> _faults;
@override@JsonKey() List<String> get faults {
  if (_faults is EqualUnmodifiableListView) return _faults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_faults);
}


/// Create a copy of CayeEventMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CayeEventMessageCopyWith<_CayeEventMessage> get copyWith => __$CayeEventMessageCopyWithImpl<_CayeEventMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CayeEventMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CayeEventMessage&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.version, version) || other.version == version)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._faults, _faults));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,version,status,const DeepCollectionEquality().hash(_faults));

@override
String toString() {
  return 'CayeEventMessage(eventId: $eventId, version: $version, status: $status, faults: $faults)';
}


}

/// @nodoc
abstract mixin class _$CayeEventMessageCopyWith<$Res> implements $CayeEventMessageCopyWith<$Res> {
  factory _$CayeEventMessageCopyWith(_CayeEventMessage value, $Res Function(_CayeEventMessage) _then) = __$CayeEventMessageCopyWithImpl;
@override @useResult
$Res call({
 String eventId, int version, int status, List<String> faults
});




}
/// @nodoc
class __$CayeEventMessageCopyWithImpl<$Res>
    implements _$CayeEventMessageCopyWith<$Res> {
  __$CayeEventMessageCopyWithImpl(this._self, this._then);

  final _CayeEventMessage _self;
  final $Res Function(_CayeEventMessage) _then;

/// Create a copy of CayeEventMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? version = null,Object? status = null,Object? faults = null,}) {
  return _then(_CayeEventMessage(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,faults: null == faults ? _self._faults : faults // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
