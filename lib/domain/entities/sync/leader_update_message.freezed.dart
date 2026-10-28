// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leader_update_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LeaderUpdateMessage {

 String get updateType;// Generic receiver-group label, not a specific device — this is a
// single retained broadcast every Follower (F01/F02/...) receives
// identically, so no one Follower's own name can go here. Never read
// by any receiver; purely a human-eyeballing label on a raw payload.
 String get boardName; String get eventId;// Monotonically increasing — a follower only applies this update if it's
// newer than the last one it already applied, guarding against
// out-of-order delivery rolling the UI back to a stale state.
 int get version; List<Order> get orders; bool get isCalibrating; int get calibrationHeight; bool get isPrinterConnected; bool get isLabelAttached;// Raspberry Pi (ToF) and Caye machine connections only physically exist
// on the leader (direct WebSocket-server / TCP-socket hardware links) —
// mirrored here the same way isPrinterConnected already is, so a
// follower's Device Management screen shows the leader's real state
// instead of being permanently stuck at FlowHubState.initial()'s false.
 bool get isConnected; bool get isCayeConnected;
/// Create a copy of LeaderUpdateMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeaderUpdateMessageCopyWith<LeaderUpdateMessage> get copyWith => _$LeaderUpdateMessageCopyWithImpl<LeaderUpdateMessage>(this as LeaderUpdateMessage, _$identity);

  /// Serializes this LeaderUpdateMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeaderUpdateMessage&&(identical(other.updateType, updateType) || other.updateType == updateType)&&(identical(other.boardName, boardName) || other.boardName == boardName)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.orders, orders)&&(identical(other.isCalibrating, isCalibrating) || other.isCalibrating == isCalibrating)&&(identical(other.calibrationHeight, calibrationHeight) || other.calibrationHeight == calibrationHeight)&&(identical(other.isPrinterConnected, isPrinterConnected) || other.isPrinterConnected == isPrinterConnected)&&(identical(other.isLabelAttached, isLabelAttached) || other.isLabelAttached == isLabelAttached)&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected)&&(identical(other.isCayeConnected, isCayeConnected) || other.isCayeConnected == isCayeConnected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,updateType,boardName,eventId,version,const DeepCollectionEquality().hash(orders),isCalibrating,calibrationHeight,isPrinterConnected,isLabelAttached,isConnected,isCayeConnected);

@override
String toString() {
  return 'LeaderUpdateMessage(updateType: $updateType, boardName: $boardName, eventId: $eventId, version: $version, orders: $orders, isCalibrating: $isCalibrating, calibrationHeight: $calibrationHeight, isPrinterConnected: $isPrinterConnected, isLabelAttached: $isLabelAttached, isConnected: $isConnected, isCayeConnected: $isCayeConnected)';
}


}

/// @nodoc
abstract mixin class $LeaderUpdateMessageCopyWith<$Res>  {
  factory $LeaderUpdateMessageCopyWith(LeaderUpdateMessage value, $Res Function(LeaderUpdateMessage) _then) = _$LeaderUpdateMessageCopyWithImpl;
@useResult
$Res call({
 String updateType, String boardName, String eventId, int version, List<Order> orders, bool isCalibrating, int calibrationHeight, bool isPrinterConnected, bool isLabelAttached, bool isConnected, bool isCayeConnected
});




}
/// @nodoc
class _$LeaderUpdateMessageCopyWithImpl<$Res>
    implements $LeaderUpdateMessageCopyWith<$Res> {
  _$LeaderUpdateMessageCopyWithImpl(this._self, this._then);

  final LeaderUpdateMessage _self;
  final $Res Function(LeaderUpdateMessage) _then;

/// Create a copy of LeaderUpdateMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? updateType = null,Object? boardName = null,Object? eventId = null,Object? version = null,Object? orders = null,Object? isCalibrating = null,Object? calibrationHeight = null,Object? isPrinterConnected = null,Object? isLabelAttached = null,Object? isConnected = null,Object? isCayeConnected = null,}) {
  return _then(_self.copyWith(
updateType: null == updateType ? _self.updateType : updateType // ignore: cast_nullable_to_non_nullable
as String,boardName: null == boardName ? _self.boardName : boardName // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,orders: null == orders ? _self.orders : orders // ignore: cast_nullable_to_non_nullable
as List<Order>,isCalibrating: null == isCalibrating ? _self.isCalibrating : isCalibrating // ignore: cast_nullable_to_non_nullable
as bool,calibrationHeight: null == calibrationHeight ? _self.calibrationHeight : calibrationHeight // ignore: cast_nullable_to_non_nullable
as int,isPrinterConnected: null == isPrinterConnected ? _self.isPrinterConnected : isPrinterConnected // ignore: cast_nullable_to_non_nullable
as bool,isLabelAttached: null == isLabelAttached ? _self.isLabelAttached : isLabelAttached // ignore: cast_nullable_to_non_nullable
as bool,isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,isCayeConnected: null == isCayeConnected ? _self.isCayeConnected : isCayeConnected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LeaderUpdateMessage].
extension LeaderUpdateMessagePatterns on LeaderUpdateMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeaderUpdateMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeaderUpdateMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeaderUpdateMessage value)  $default,){
final _that = this;
switch (_that) {
case _LeaderUpdateMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeaderUpdateMessage value)?  $default,){
final _that = this;
switch (_that) {
case _LeaderUpdateMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String updateType,  String boardName,  String eventId,  int version,  List<Order> orders,  bool isCalibrating,  int calibrationHeight,  bool isPrinterConnected,  bool isLabelAttached,  bool isConnected,  bool isCayeConnected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeaderUpdateMessage() when $default != null:
return $default(_that.updateType,_that.boardName,_that.eventId,_that.version,_that.orders,_that.isCalibrating,_that.calibrationHeight,_that.isPrinterConnected,_that.isLabelAttached,_that.isConnected,_that.isCayeConnected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String updateType,  String boardName,  String eventId,  int version,  List<Order> orders,  bool isCalibrating,  int calibrationHeight,  bool isPrinterConnected,  bool isLabelAttached,  bool isConnected,  bool isCayeConnected)  $default,) {final _that = this;
switch (_that) {
case _LeaderUpdateMessage():
return $default(_that.updateType,_that.boardName,_that.eventId,_that.version,_that.orders,_that.isCalibrating,_that.calibrationHeight,_that.isPrinterConnected,_that.isLabelAttached,_that.isConnected,_that.isCayeConnected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String updateType,  String boardName,  String eventId,  int version,  List<Order> orders,  bool isCalibrating,  int calibrationHeight,  bool isPrinterConnected,  bool isLabelAttached,  bool isConnected,  bool isCayeConnected)?  $default,) {final _that = this;
switch (_that) {
case _LeaderUpdateMessage() when $default != null:
return $default(_that.updateType,_that.boardName,_that.eventId,_that.version,_that.orders,_that.isCalibrating,_that.calibrationHeight,_that.isPrinterConnected,_that.isLabelAttached,_that.isConnected,_that.isCayeConnected);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeaderUpdateMessage implements LeaderUpdateMessage {
  const _LeaderUpdateMessage({this.updateType = 'orders_snapshot', this.boardName = 'flowhubF', this.eventId = '', this.version = 0, final  List<Order> orders = const [], this.isCalibrating = false, this.calibrationHeight = 920, this.isPrinterConnected = false, this.isLabelAttached = false, this.isConnected = false, this.isCayeConnected = false}): _orders = orders;
  factory _LeaderUpdateMessage.fromJson(Map<String, dynamic> json) => _$LeaderUpdateMessageFromJson(json);

@override@JsonKey() final  String updateType;
// Generic receiver-group label, not a specific device — this is a
// single retained broadcast every Follower (F01/F02/...) receives
// identically, so no one Follower's own name can go here. Never read
// by any receiver; purely a human-eyeballing label on a raw payload.
@override@JsonKey() final  String boardName;
@override@JsonKey() final  String eventId;
// Monotonically increasing — a follower only applies this update if it's
// newer than the last one it already applied, guarding against
// out-of-order delivery rolling the UI back to a stale state.
@override@JsonKey() final  int version;
 final  List<Order> _orders;
@override@JsonKey() List<Order> get orders {
  if (_orders is EqualUnmodifiableListView) return _orders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_orders);
}

@override@JsonKey() final  bool isCalibrating;
@override@JsonKey() final  int calibrationHeight;
@override@JsonKey() final  bool isPrinterConnected;
@override@JsonKey() final  bool isLabelAttached;
// Raspberry Pi (ToF) and Caye machine connections only physically exist
// on the leader (direct WebSocket-server / TCP-socket hardware links) —
// mirrored here the same way isPrinterConnected already is, so a
// follower's Device Management screen shows the leader's real state
// instead of being permanently stuck at FlowHubState.initial()'s false.
@override@JsonKey() final  bool isConnected;
@override@JsonKey() final  bool isCayeConnected;

/// Create a copy of LeaderUpdateMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeaderUpdateMessageCopyWith<_LeaderUpdateMessage> get copyWith => __$LeaderUpdateMessageCopyWithImpl<_LeaderUpdateMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeaderUpdateMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeaderUpdateMessage&&(identical(other.updateType, updateType) || other.updateType == updateType)&&(identical(other.boardName, boardName) || other.boardName == boardName)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other._orders, _orders)&&(identical(other.isCalibrating, isCalibrating) || other.isCalibrating == isCalibrating)&&(identical(other.calibrationHeight, calibrationHeight) || other.calibrationHeight == calibrationHeight)&&(identical(other.isPrinterConnected, isPrinterConnected) || other.isPrinterConnected == isPrinterConnected)&&(identical(other.isLabelAttached, isLabelAttached) || other.isLabelAttached == isLabelAttached)&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected)&&(identical(other.isCayeConnected, isCayeConnected) || other.isCayeConnected == isCayeConnected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,updateType,boardName,eventId,version,const DeepCollectionEquality().hash(_orders),isCalibrating,calibrationHeight,isPrinterConnected,isLabelAttached,isConnected,isCayeConnected);

@override
String toString() {
  return 'LeaderUpdateMessage(updateType: $updateType, boardName: $boardName, eventId: $eventId, version: $version, orders: $orders, isCalibrating: $isCalibrating, calibrationHeight: $calibrationHeight, isPrinterConnected: $isPrinterConnected, isLabelAttached: $isLabelAttached, isConnected: $isConnected, isCayeConnected: $isCayeConnected)';
}


}

/// @nodoc
abstract mixin class _$LeaderUpdateMessageCopyWith<$Res> implements $LeaderUpdateMessageCopyWith<$Res> {
  factory _$LeaderUpdateMessageCopyWith(_LeaderUpdateMessage value, $Res Function(_LeaderUpdateMessage) _then) = __$LeaderUpdateMessageCopyWithImpl;
@override @useResult
$Res call({
 String updateType, String boardName, String eventId, int version, List<Order> orders, bool isCalibrating, int calibrationHeight, bool isPrinterConnected, bool isLabelAttached, bool isConnected, bool isCayeConnected
});




}
/// @nodoc
class __$LeaderUpdateMessageCopyWithImpl<$Res>
    implements _$LeaderUpdateMessageCopyWith<$Res> {
  __$LeaderUpdateMessageCopyWithImpl(this._self, this._then);

  final _LeaderUpdateMessage _self;
  final $Res Function(_LeaderUpdateMessage) _then;

/// Create a copy of LeaderUpdateMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? updateType = null,Object? boardName = null,Object? eventId = null,Object? version = null,Object? orders = null,Object? isCalibrating = null,Object? calibrationHeight = null,Object? isPrinterConnected = null,Object? isLabelAttached = null,Object? isConnected = null,Object? isCayeConnected = null,}) {
  return _then(_LeaderUpdateMessage(
updateType: null == updateType ? _self.updateType : updateType // ignore: cast_nullable_to_non_nullable
as String,boardName: null == boardName ? _self.boardName : boardName // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,orders: null == orders ? _self._orders : orders // ignore: cast_nullable_to_non_nullable
as List<Order>,isCalibrating: null == isCalibrating ? _self.isCalibrating : isCalibrating // ignore: cast_nullable_to_non_nullable
as bool,calibrationHeight: null == calibrationHeight ? _self.calibrationHeight : calibrationHeight // ignore: cast_nullable_to_non_nullable
as int,isPrinterConnected: null == isPrinterConnected ? _self.isPrinterConnected : isPrinterConnected // ignore: cast_nullable_to_non_nullable
as bool,isLabelAttached: null == isLabelAttached ? _self.isLabelAttached : isLabelAttached // ignore: cast_nullable_to_non_nullable
as bool,isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,isCayeConnected: null == isCayeConnected ? _self.isCayeConnected : isCayeConnected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
