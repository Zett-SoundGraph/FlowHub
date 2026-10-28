// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'board_update_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BoardUpdateMessage {

// Generic receiver-group label, not a specific device — this is a
// single broadcast both Flow Board and Pickup Board receive
// identically, so neither one's own name alone fits here. Never read
// by any receiver; purely a human-eyeballing label on a raw payload.
 String get boardName; String get eventId; int get version; List<BoardOrder> get orders;
/// Create a copy of BoardUpdateMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoardUpdateMessageCopyWith<BoardUpdateMessage> get copyWith => _$BoardUpdateMessageCopyWithImpl<BoardUpdateMessage>(this as BoardUpdateMessage, _$identity);

  /// Serializes this BoardUpdateMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoardUpdateMessage&&(identical(other.boardName, boardName) || other.boardName == boardName)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.orders, orders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,boardName,eventId,version,const DeepCollectionEquality().hash(orders));

@override
String toString() {
  return 'BoardUpdateMessage(boardName: $boardName, eventId: $eventId, version: $version, orders: $orders)';
}


}

/// @nodoc
abstract mixin class $BoardUpdateMessageCopyWith<$Res>  {
  factory $BoardUpdateMessageCopyWith(BoardUpdateMessage value, $Res Function(BoardUpdateMessage) _then) = _$BoardUpdateMessageCopyWithImpl;
@useResult
$Res call({
 String boardName, String eventId, int version, List<BoardOrder> orders
});




}
/// @nodoc
class _$BoardUpdateMessageCopyWithImpl<$Res>
    implements $BoardUpdateMessageCopyWith<$Res> {
  _$BoardUpdateMessageCopyWithImpl(this._self, this._then);

  final BoardUpdateMessage _self;
  final $Res Function(BoardUpdateMessage) _then;

/// Create a copy of BoardUpdateMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? boardName = null,Object? eventId = null,Object? version = null,Object? orders = null,}) {
  return _then(_self.copyWith(
boardName: null == boardName ? _self.boardName : boardName // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,orders: null == orders ? _self.orders : orders // ignore: cast_nullable_to_non_nullable
as List<BoardOrder>,
  ));
}

}


/// Adds pattern-matching-related methods to [BoardUpdateMessage].
extension BoardUpdateMessagePatterns on BoardUpdateMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BoardUpdateMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BoardUpdateMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BoardUpdateMessage value)  $default,){
final _that = this;
switch (_that) {
case _BoardUpdateMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BoardUpdateMessage value)?  $default,){
final _that = this;
switch (_that) {
case _BoardUpdateMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String boardName,  String eventId,  int version,  List<BoardOrder> orders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BoardUpdateMessage() when $default != null:
return $default(_that.boardName,_that.eventId,_that.version,_that.orders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String boardName,  String eventId,  int version,  List<BoardOrder> orders)  $default,) {final _that = this;
switch (_that) {
case _BoardUpdateMessage():
return $default(_that.boardName,_that.eventId,_that.version,_that.orders);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String boardName,  String eventId,  int version,  List<BoardOrder> orders)?  $default,) {final _that = this;
switch (_that) {
case _BoardUpdateMessage() when $default != null:
return $default(_that.boardName,_that.eventId,_that.version,_that.orders);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BoardUpdateMessage implements BoardUpdateMessage {
  const _BoardUpdateMessage({this.boardName = 'flowBoards', this.eventId = '', this.version = 0, final  List<BoardOrder> orders = const []}): _orders = orders;
  factory _BoardUpdateMessage.fromJson(Map<String, dynamic> json) => _$BoardUpdateMessageFromJson(json);

// Generic receiver-group label, not a specific device — this is a
// single broadcast both Flow Board and Pickup Board receive
// identically, so neither one's own name alone fits here. Never read
// by any receiver; purely a human-eyeballing label on a raw payload.
@override@JsonKey() final  String boardName;
@override@JsonKey() final  String eventId;
@override@JsonKey() final  int version;
 final  List<BoardOrder> _orders;
@override@JsonKey() List<BoardOrder> get orders {
  if (_orders is EqualUnmodifiableListView) return _orders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_orders);
}


/// Create a copy of BoardUpdateMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoardUpdateMessageCopyWith<_BoardUpdateMessage> get copyWith => __$BoardUpdateMessageCopyWithImpl<_BoardUpdateMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BoardUpdateMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BoardUpdateMessage&&(identical(other.boardName, boardName) || other.boardName == boardName)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other._orders, _orders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,boardName,eventId,version,const DeepCollectionEquality().hash(_orders));

@override
String toString() {
  return 'BoardUpdateMessage(boardName: $boardName, eventId: $eventId, version: $version, orders: $orders)';
}


}

/// @nodoc
abstract mixin class _$BoardUpdateMessageCopyWith<$Res> implements $BoardUpdateMessageCopyWith<$Res> {
  factory _$BoardUpdateMessageCopyWith(_BoardUpdateMessage value, $Res Function(_BoardUpdateMessage) _then) = __$BoardUpdateMessageCopyWithImpl;
@override @useResult
$Res call({
 String boardName, String eventId, int version, List<BoardOrder> orders
});




}
/// @nodoc
class __$BoardUpdateMessageCopyWithImpl<$Res>
    implements _$BoardUpdateMessageCopyWith<$Res> {
  __$BoardUpdateMessageCopyWithImpl(this._self, this._then);

  final _BoardUpdateMessage _self;
  final $Res Function(_BoardUpdateMessage) _then;

/// Create a copy of BoardUpdateMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? boardName = null,Object? eventId = null,Object? version = null,Object? orders = null,}) {
  return _then(_BoardUpdateMessage(
boardName: null == boardName ? _self.boardName : boardName // ignore: cast_nullable_to_non_nullable
as String,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,orders: null == orders ? _self._orders : orders // ignore: cast_nullable_to_non_nullable
as List<BoardOrder>,
  ));
}


}


/// @nodoc
mixin _$BoardOrder {

 String get orderNo; String get tab; int get totalCups; String get lang;// Average of every item's own progress (see Order.aggregateProgress) —
// reaches 1.0 only once every item is individually confirmed complete.
 double get progress; List<BoardOrderItem> get items;
/// Create a copy of BoardOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoardOrderCopyWith<BoardOrder> get copyWith => _$BoardOrderCopyWithImpl<BoardOrder>(this as BoardOrder, _$identity);

  /// Serializes this BoardOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoardOrder&&(identical(other.orderNo, orderNo) || other.orderNo == orderNo)&&(identical(other.tab, tab) || other.tab == tab)&&(identical(other.totalCups, totalCups) || other.totalCups == totalCups)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.progress, progress) || other.progress == progress)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderNo,tab,totalCups,lang,progress,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'BoardOrder(orderNo: $orderNo, tab: $tab, totalCups: $totalCups, lang: $lang, progress: $progress, items: $items)';
}


}

/// @nodoc
abstract mixin class $BoardOrderCopyWith<$Res>  {
  factory $BoardOrderCopyWith(BoardOrder value, $Res Function(BoardOrder) _then) = _$BoardOrderCopyWithImpl;
@useResult
$Res call({
 String orderNo, String tab, int totalCups, String lang, double progress, List<BoardOrderItem> items
});




}
/// @nodoc
class _$BoardOrderCopyWithImpl<$Res>
    implements $BoardOrderCopyWith<$Res> {
  _$BoardOrderCopyWithImpl(this._self, this._then);

  final BoardOrder _self;
  final $Res Function(BoardOrder) _then;

/// Create a copy of BoardOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderNo = null,Object? tab = null,Object? totalCups = null,Object? lang = null,Object? progress = null,Object? items = null,}) {
  return _then(_self.copyWith(
orderNo: null == orderNo ? _self.orderNo : orderNo // ignore: cast_nullable_to_non_nullable
as String,tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as String,totalCups: null == totalCups ? _self.totalCups : totalCups // ignore: cast_nullable_to_non_nullable
as int,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<BoardOrderItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [BoardOrder].
extension BoardOrderPatterns on BoardOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BoardOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BoardOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BoardOrder value)  $default,){
final _that = this;
switch (_that) {
case _BoardOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BoardOrder value)?  $default,){
final _that = this;
switch (_that) {
case _BoardOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String orderNo,  String tab,  int totalCups,  String lang,  double progress,  List<BoardOrderItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BoardOrder() when $default != null:
return $default(_that.orderNo,_that.tab,_that.totalCups,_that.lang,_that.progress,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String orderNo,  String tab,  int totalCups,  String lang,  double progress,  List<BoardOrderItem> items)  $default,) {final _that = this;
switch (_that) {
case _BoardOrder():
return $default(_that.orderNo,_that.tab,_that.totalCups,_that.lang,_that.progress,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String orderNo,  String tab,  int totalCups,  String lang,  double progress,  List<BoardOrderItem> items)?  $default,) {final _that = this;
switch (_that) {
case _BoardOrder() when $default != null:
return $default(_that.orderNo,_that.tab,_that.totalCups,_that.lang,_that.progress,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BoardOrder implements BoardOrder {
  const _BoardOrder({this.orderNo = '', this.tab = 'newOrder', this.totalCups = 0, this.lang = '', this.progress = 0.0, final  List<BoardOrderItem> items = const []}): _items = items;
  factory _BoardOrder.fromJson(Map<String, dynamic> json) => _$BoardOrderFromJson(json);

@override@JsonKey() final  String orderNo;
@override@JsonKey() final  String tab;
@override@JsonKey() final  int totalCups;
@override@JsonKey() final  String lang;
// Average of every item's own progress (see Order.aggregateProgress) —
// reaches 1.0 only once every item is individually confirmed complete.
@override@JsonKey() final  double progress;
 final  List<BoardOrderItem> _items;
@override@JsonKey() List<BoardOrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of BoardOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoardOrderCopyWith<_BoardOrder> get copyWith => __$BoardOrderCopyWithImpl<_BoardOrder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BoardOrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BoardOrder&&(identical(other.orderNo, orderNo) || other.orderNo == orderNo)&&(identical(other.tab, tab) || other.tab == tab)&&(identical(other.totalCups, totalCups) || other.totalCups == totalCups)&&(identical(other.lang, lang) || other.lang == lang)&&(identical(other.progress, progress) || other.progress == progress)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderNo,tab,totalCups,lang,progress,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'BoardOrder(orderNo: $orderNo, tab: $tab, totalCups: $totalCups, lang: $lang, progress: $progress, items: $items)';
}


}

/// @nodoc
abstract mixin class _$BoardOrderCopyWith<$Res> implements $BoardOrderCopyWith<$Res> {
  factory _$BoardOrderCopyWith(_BoardOrder value, $Res Function(_BoardOrder) _then) = __$BoardOrderCopyWithImpl;
@override @useResult
$Res call({
 String orderNo, String tab, int totalCups, String lang, double progress, List<BoardOrderItem> items
});




}
/// @nodoc
class __$BoardOrderCopyWithImpl<$Res>
    implements _$BoardOrderCopyWith<$Res> {
  __$BoardOrderCopyWithImpl(this._self, this._then);

  final _BoardOrder _self;
  final $Res Function(_BoardOrder) _then;

/// Create a copy of BoardOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderNo = null,Object? tab = null,Object? totalCups = null,Object? lang = null,Object? progress = null,Object? items = null,}) {
  return _then(_BoardOrder(
orderNo: null == orderNo ? _self.orderNo : orderNo // ignore: cast_nullable_to_non_nullable
as String,tab: null == tab ? _self.tab : tab // ignore: cast_nullable_to_non_nullable
as String,totalCups: null == totalCups ? _self.totalCups : totalCups // ignore: cast_nullable_to_non_nullable
as int,lang: null == lang ? _self.lang : lang // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<BoardOrderItem>,
  ));
}


}


/// @nodoc
mixin _$BoardOrderItem {

 int get seq; String get skuNo; String get temp;// Estimated-time (Nudof) or real-telemetry (Caye) progress, continuously
// pushed by FlowHub — see SubItem's phase-tracking fields for how this is
// computed. Holds at 0.99 for any phase whose completion is confirmed by
// a real signal rather than the estimate alone.
 double get progress;// Plain display name (e.g. "Cafe Latte") — for boards to fill the
// "[Menu Name]" token in a Language List bottom-bar template without
// needing their own SKU->name lookup.
 String get menuName;// ProductionStage's name (e.g. "nudofDispensing") — see that enum's doc
// comment for the full event list a board can key a bottom-bar message
// off of. 'none' means no stage-worthy event has happened yet.
 String get stage;// First Nudof ingredient name involved (e.g. "Cold_Brew"), for the
// "[Dispenser]" token in the PB.BB.0002 template — only meaningful when
// stage is 'nudofDispensing', empty otherwise.
 String get dispenserName;
/// Create a copy of BoardOrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoardOrderItemCopyWith<BoardOrderItem> get copyWith => _$BoardOrderItemCopyWithImpl<BoardOrderItem>(this as BoardOrderItem, _$identity);

  /// Serializes this BoardOrderItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoardOrderItem&&(identical(other.seq, seq) || other.seq == seq)&&(identical(other.skuNo, skuNo) || other.skuNo == skuNo)&&(identical(other.temp, temp) || other.temp == temp)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.menuName, menuName) || other.menuName == menuName)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.dispenserName, dispenserName) || other.dispenserName == dispenserName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,seq,skuNo,temp,progress,menuName,stage,dispenserName);

@override
String toString() {
  return 'BoardOrderItem(seq: $seq, skuNo: $skuNo, temp: $temp, progress: $progress, menuName: $menuName, stage: $stage, dispenserName: $dispenserName)';
}


}

/// @nodoc
abstract mixin class $BoardOrderItemCopyWith<$Res>  {
  factory $BoardOrderItemCopyWith(BoardOrderItem value, $Res Function(BoardOrderItem) _then) = _$BoardOrderItemCopyWithImpl;
@useResult
$Res call({
 int seq, String skuNo, String temp, double progress, String menuName, String stage, String dispenserName
});




}
/// @nodoc
class _$BoardOrderItemCopyWithImpl<$Res>
    implements $BoardOrderItemCopyWith<$Res> {
  _$BoardOrderItemCopyWithImpl(this._self, this._then);

  final BoardOrderItem _self;
  final $Res Function(BoardOrderItem) _then;

/// Create a copy of BoardOrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? seq = null,Object? skuNo = null,Object? temp = null,Object? progress = null,Object? menuName = null,Object? stage = null,Object? dispenserName = null,}) {
  return _then(_self.copyWith(
seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,skuNo: null == skuNo ? _self.skuNo : skuNo // ignore: cast_nullable_to_non_nullable
as String,temp: null == temp ? _self.temp : temp // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,menuName: null == menuName ? _self.menuName : menuName // ignore: cast_nullable_to_non_nullable
as String,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String,dispenserName: null == dispenserName ? _self.dispenserName : dispenserName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BoardOrderItem].
extension BoardOrderItemPatterns on BoardOrderItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BoardOrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BoardOrderItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BoardOrderItem value)  $default,){
final _that = this;
switch (_that) {
case _BoardOrderItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BoardOrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _BoardOrderItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int seq,  String skuNo,  String temp,  double progress,  String menuName,  String stage,  String dispenserName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BoardOrderItem() when $default != null:
return $default(_that.seq,_that.skuNo,_that.temp,_that.progress,_that.menuName,_that.stage,_that.dispenserName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int seq,  String skuNo,  String temp,  double progress,  String menuName,  String stage,  String dispenserName)  $default,) {final _that = this;
switch (_that) {
case _BoardOrderItem():
return $default(_that.seq,_that.skuNo,_that.temp,_that.progress,_that.menuName,_that.stage,_that.dispenserName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int seq,  String skuNo,  String temp,  double progress,  String menuName,  String stage,  String dispenserName)?  $default,) {final _that = this;
switch (_that) {
case _BoardOrderItem() when $default != null:
return $default(_that.seq,_that.skuNo,_that.temp,_that.progress,_that.menuName,_that.stage,_that.dispenserName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BoardOrderItem implements BoardOrderItem {
  const _BoardOrderItem({this.seq = 0, this.skuNo = '', this.temp = '', this.progress = 0.0, this.menuName = '', this.stage = 'none', this.dispenserName = ''});
  factory _BoardOrderItem.fromJson(Map<String, dynamic> json) => _$BoardOrderItemFromJson(json);

@override@JsonKey() final  int seq;
@override@JsonKey() final  String skuNo;
@override@JsonKey() final  String temp;
// Estimated-time (Nudof) or real-telemetry (Caye) progress, continuously
// pushed by FlowHub — see SubItem's phase-tracking fields for how this is
// computed. Holds at 0.99 for any phase whose completion is confirmed by
// a real signal rather than the estimate alone.
@override@JsonKey() final  double progress;
// Plain display name (e.g. "Cafe Latte") — for boards to fill the
// "[Menu Name]" token in a Language List bottom-bar template without
// needing their own SKU->name lookup.
@override@JsonKey() final  String menuName;
// ProductionStage's name (e.g. "nudofDispensing") — see that enum's doc
// comment for the full event list a board can key a bottom-bar message
// off of. 'none' means no stage-worthy event has happened yet.
@override@JsonKey() final  String stage;
// First Nudof ingredient name involved (e.g. "Cold_Brew"), for the
// "[Dispenser]" token in the PB.BB.0002 template — only meaningful when
// stage is 'nudofDispensing', empty otherwise.
@override@JsonKey() final  String dispenserName;

/// Create a copy of BoardOrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BoardOrderItemCopyWith<_BoardOrderItem> get copyWith => __$BoardOrderItemCopyWithImpl<_BoardOrderItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BoardOrderItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BoardOrderItem&&(identical(other.seq, seq) || other.seq == seq)&&(identical(other.skuNo, skuNo) || other.skuNo == skuNo)&&(identical(other.temp, temp) || other.temp == temp)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.menuName, menuName) || other.menuName == menuName)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.dispenserName, dispenserName) || other.dispenserName == dispenserName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,seq,skuNo,temp,progress,menuName,stage,dispenserName);

@override
String toString() {
  return 'BoardOrderItem(seq: $seq, skuNo: $skuNo, temp: $temp, progress: $progress, menuName: $menuName, stage: $stage, dispenserName: $dispenserName)';
}


}

/// @nodoc
abstract mixin class _$BoardOrderItemCopyWith<$Res> implements $BoardOrderItemCopyWith<$Res> {
  factory _$BoardOrderItemCopyWith(_BoardOrderItem value, $Res Function(_BoardOrderItem) _then) = __$BoardOrderItemCopyWithImpl;
@override @useResult
$Res call({
 int seq, String skuNo, String temp, double progress, String menuName, String stage, String dispenserName
});




}
/// @nodoc
class __$BoardOrderItemCopyWithImpl<$Res>
    implements _$BoardOrderItemCopyWith<$Res> {
  __$BoardOrderItemCopyWithImpl(this._self, this._then);

  final _BoardOrderItem _self;
  final $Res Function(_BoardOrderItem) _then;

/// Create a copy of BoardOrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? seq = null,Object? skuNo = null,Object? temp = null,Object? progress = null,Object? menuName = null,Object? stage = null,Object? dispenserName = null,}) {
  return _then(_BoardOrderItem(
seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,skuNo: null == skuNo ? _self.skuNo : skuNo // ignore: cast_nullable_to_non_nullable
as String,temp: null == temp ? _self.temp : temp // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,menuName: null == menuName ? _self.menuName : menuName // ignore: cast_nullable_to_non_nullable
as String,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as String,dispenserName: null == dispenserName ? _self.dispenserName : dispenserName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
