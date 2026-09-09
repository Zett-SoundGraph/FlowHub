// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kiosk_update_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KioskUpdateMessage {

 String get eventId; int get version; int get orders; int get waiting;
/// Create a copy of KioskUpdateMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KioskUpdateMessageCopyWith<KioskUpdateMessage> get copyWith => _$KioskUpdateMessageCopyWithImpl<KioskUpdateMessage>(this as KioskUpdateMessage, _$identity);

  /// Serializes this KioskUpdateMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KioskUpdateMessage&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.version, version) || other.version == version)&&(identical(other.orders, orders) || other.orders == orders)&&(identical(other.waiting, waiting) || other.waiting == waiting));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,version,orders,waiting);

@override
String toString() {
  return 'KioskUpdateMessage(eventId: $eventId, version: $version, orders: $orders, waiting: $waiting)';
}


}

/// @nodoc
abstract mixin class $KioskUpdateMessageCopyWith<$Res>  {
  factory $KioskUpdateMessageCopyWith(KioskUpdateMessage value, $Res Function(KioskUpdateMessage) _then) = _$KioskUpdateMessageCopyWithImpl;
@useResult
$Res call({
 String eventId, int version, int orders, int waiting
});




}
/// @nodoc
class _$KioskUpdateMessageCopyWithImpl<$Res>
    implements $KioskUpdateMessageCopyWith<$Res> {
  _$KioskUpdateMessageCopyWithImpl(this._self, this._then);

  final KioskUpdateMessage _self;
  final $Res Function(KioskUpdateMessage) _then;

/// Create a copy of KioskUpdateMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventId = null,Object? version = null,Object? orders = null,Object? waiting = null,}) {
  return _then(_self.copyWith(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,orders: null == orders ? _self.orders : orders // ignore: cast_nullable_to_non_nullable
as int,waiting: null == waiting ? _self.waiting : waiting // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [KioskUpdateMessage].
extension KioskUpdateMessagePatterns on KioskUpdateMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KioskUpdateMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KioskUpdateMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KioskUpdateMessage value)  $default,){
final _that = this;
switch (_that) {
case _KioskUpdateMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KioskUpdateMessage value)?  $default,){
final _that = this;
switch (_that) {
case _KioskUpdateMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String eventId,  int version,  int orders,  int waiting)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KioskUpdateMessage() when $default != null:
return $default(_that.eventId,_that.version,_that.orders,_that.waiting);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String eventId,  int version,  int orders,  int waiting)  $default,) {final _that = this;
switch (_that) {
case _KioskUpdateMessage():
return $default(_that.eventId,_that.version,_that.orders,_that.waiting);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String eventId,  int version,  int orders,  int waiting)?  $default,) {final _that = this;
switch (_that) {
case _KioskUpdateMessage() when $default != null:
return $default(_that.eventId,_that.version,_that.orders,_that.waiting);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KioskUpdateMessage implements KioskUpdateMessage {
  const _KioskUpdateMessage({this.eventId = '', this.version = 0, this.orders = 0, this.waiting = 0});
  factory _KioskUpdateMessage.fromJson(Map<String, dynamic> json) => _$KioskUpdateMessageFromJson(json);

@override@JsonKey() final  String eventId;
@override@JsonKey() final  int version;
@override@JsonKey() final  int orders;
@override@JsonKey() final  int waiting;

/// Create a copy of KioskUpdateMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KioskUpdateMessageCopyWith<_KioskUpdateMessage> get copyWith => __$KioskUpdateMessageCopyWithImpl<_KioskUpdateMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KioskUpdateMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KioskUpdateMessage&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.version, version) || other.version == version)&&(identical(other.orders, orders) || other.orders == orders)&&(identical(other.waiting, waiting) || other.waiting == waiting));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,version,orders,waiting);

@override
String toString() {
  return 'KioskUpdateMessage(eventId: $eventId, version: $version, orders: $orders, waiting: $waiting)';
}


}

/// @nodoc
abstract mixin class _$KioskUpdateMessageCopyWith<$Res> implements $KioskUpdateMessageCopyWith<$Res> {
  factory _$KioskUpdateMessageCopyWith(_KioskUpdateMessage value, $Res Function(_KioskUpdateMessage) _then) = __$KioskUpdateMessageCopyWithImpl;
@override @useResult
$Res call({
 String eventId, int version, int orders, int waiting
});




}
/// @nodoc
class __$KioskUpdateMessageCopyWithImpl<$Res>
    implements _$KioskUpdateMessageCopyWith<$Res> {
  __$KioskUpdateMessageCopyWithImpl(this._self, this._then);

  final _KioskUpdateMessage _self;
  final $Res Function(_KioskUpdateMessage) _then;

/// Create a copy of KioskUpdateMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? version = null,Object? orders = null,Object? waiting = null,}) {
  return _then(_KioskUpdateMessage(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,orders: null == orders ? _self.orders : orders // ignore: cast_nullable_to_non_nullable
as int,waiting: null == waiting ? _self.waiting : waiting // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
