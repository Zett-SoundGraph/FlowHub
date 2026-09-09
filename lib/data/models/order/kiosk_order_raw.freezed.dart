// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kiosk_order_raw.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KioskOrderRaw {

 String get eventId; String get orderNo; String get language; int get totalCups; String? get orderTime; List<KioskOrderItemRaw> get items;
/// Create a copy of KioskOrderRaw
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KioskOrderRawCopyWith<KioskOrderRaw> get copyWith => _$KioskOrderRawCopyWithImpl<KioskOrderRaw>(this as KioskOrderRaw, _$identity);

  /// Serializes this KioskOrderRaw to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KioskOrderRaw&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.orderNo, orderNo) || other.orderNo == orderNo)&&(identical(other.language, language) || other.language == language)&&(identical(other.totalCups, totalCups) || other.totalCups == totalCups)&&(identical(other.orderTime, orderTime) || other.orderTime == orderTime)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,orderNo,language,totalCups,orderTime,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'KioskOrderRaw(eventId: $eventId, orderNo: $orderNo, language: $language, totalCups: $totalCups, orderTime: $orderTime, items: $items)';
}


}

/// @nodoc
abstract mixin class $KioskOrderRawCopyWith<$Res>  {
  factory $KioskOrderRawCopyWith(KioskOrderRaw value, $Res Function(KioskOrderRaw) _then) = _$KioskOrderRawCopyWithImpl;
@useResult
$Res call({
 String eventId, String orderNo, String language, int totalCups, String? orderTime, List<KioskOrderItemRaw> items
});




}
/// @nodoc
class _$KioskOrderRawCopyWithImpl<$Res>
    implements $KioskOrderRawCopyWith<$Res> {
  _$KioskOrderRawCopyWithImpl(this._self, this._then);

  final KioskOrderRaw _self;
  final $Res Function(KioskOrderRaw) _then;

/// Create a copy of KioskOrderRaw
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventId = null,Object? orderNo = null,Object? language = null,Object? totalCups = null,Object? orderTime = freezed,Object? items = null,}) {
  return _then(_self.copyWith(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,orderNo: null == orderNo ? _self.orderNo : orderNo // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,totalCups: null == totalCups ? _self.totalCups : totalCups // ignore: cast_nullable_to_non_nullable
as int,orderTime: freezed == orderTime ? _self.orderTime : orderTime // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<KioskOrderItemRaw>,
  ));
}

}


/// Adds pattern-matching-related methods to [KioskOrderRaw].
extension KioskOrderRawPatterns on KioskOrderRaw {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KioskOrderRaw value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KioskOrderRaw() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KioskOrderRaw value)  $default,){
final _that = this;
switch (_that) {
case _KioskOrderRaw():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KioskOrderRaw value)?  $default,){
final _that = this;
switch (_that) {
case _KioskOrderRaw() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String eventId,  String orderNo,  String language,  int totalCups,  String? orderTime,  List<KioskOrderItemRaw> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KioskOrderRaw() when $default != null:
return $default(_that.eventId,_that.orderNo,_that.language,_that.totalCups,_that.orderTime,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String eventId,  String orderNo,  String language,  int totalCups,  String? orderTime,  List<KioskOrderItemRaw> items)  $default,) {final _that = this;
switch (_that) {
case _KioskOrderRaw():
return $default(_that.eventId,_that.orderNo,_that.language,_that.totalCups,_that.orderTime,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String eventId,  String orderNo,  String language,  int totalCups,  String? orderTime,  List<KioskOrderItemRaw> items)?  $default,) {final _that = this;
switch (_that) {
case _KioskOrderRaw() when $default != null:
return $default(_that.eventId,_that.orderNo,_that.language,_that.totalCups,_that.orderTime,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KioskOrderRaw extends KioskOrderRaw {
  const _KioskOrderRaw({this.eventId = '', this.orderNo = '', this.language = '', this.totalCups = 0, this.orderTime, final  List<KioskOrderItemRaw> items = const []}): _items = items,super._();
  factory _KioskOrderRaw.fromJson(Map<String, dynamic> json) => _$KioskOrderRawFromJson(json);

@override@JsonKey() final  String eventId;
@override@JsonKey() final  String orderNo;
@override@JsonKey() final  String language;
@override@JsonKey() final  int totalCups;
@override final  String? orderTime;
 final  List<KioskOrderItemRaw> _items;
@override@JsonKey() List<KioskOrderItemRaw> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of KioskOrderRaw
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KioskOrderRawCopyWith<_KioskOrderRaw> get copyWith => __$KioskOrderRawCopyWithImpl<_KioskOrderRaw>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KioskOrderRawToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KioskOrderRaw&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.orderNo, orderNo) || other.orderNo == orderNo)&&(identical(other.language, language) || other.language == language)&&(identical(other.totalCups, totalCups) || other.totalCups == totalCups)&&(identical(other.orderTime, orderTime) || other.orderTime == orderTime)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,orderNo,language,totalCups,orderTime,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'KioskOrderRaw(eventId: $eventId, orderNo: $orderNo, language: $language, totalCups: $totalCups, orderTime: $orderTime, items: $items)';
}


}

/// @nodoc
abstract mixin class _$KioskOrderRawCopyWith<$Res> implements $KioskOrderRawCopyWith<$Res> {
  factory _$KioskOrderRawCopyWith(_KioskOrderRaw value, $Res Function(_KioskOrderRaw) _then) = __$KioskOrderRawCopyWithImpl;
@override @useResult
$Res call({
 String eventId, String orderNo, String language, int totalCups, String? orderTime, List<KioskOrderItemRaw> items
});




}
/// @nodoc
class __$KioskOrderRawCopyWithImpl<$Res>
    implements _$KioskOrderRawCopyWith<$Res> {
  __$KioskOrderRawCopyWithImpl(this._self, this._then);

  final _KioskOrderRaw _self;
  final $Res Function(_KioskOrderRaw) _then;

/// Create a copy of KioskOrderRaw
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? orderNo = null,Object? language = null,Object? totalCups = null,Object? orderTime = freezed,Object? items = null,}) {
  return _then(_KioskOrderRaw(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,orderNo: null == orderNo ? _self.orderNo : orderNo // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,totalCups: null == totalCups ? _self.totalCups : totalCups // ignore: cast_nullable_to_non_nullable
as int,orderTime: freezed == orderTime ? _self.orderTime : orderTime // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<KioskOrderItemRaw>,
  ));
}


}


/// @nodoc
mixin _$KioskOrderItemRaw {

 int get seq; String get skuNo; String get menuName; String get temp; String get size; List<SelectedOption> get options;
/// Create a copy of KioskOrderItemRaw
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KioskOrderItemRawCopyWith<KioskOrderItemRaw> get copyWith => _$KioskOrderItemRawCopyWithImpl<KioskOrderItemRaw>(this as KioskOrderItemRaw, _$identity);

  /// Serializes this KioskOrderItemRaw to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KioskOrderItemRaw&&(identical(other.seq, seq) || other.seq == seq)&&(identical(other.skuNo, skuNo) || other.skuNo == skuNo)&&(identical(other.menuName, menuName) || other.menuName == menuName)&&(identical(other.temp, temp) || other.temp == temp)&&(identical(other.size, size) || other.size == size)&&const DeepCollectionEquality().equals(other.options, options));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,seq,skuNo,menuName,temp,size,const DeepCollectionEquality().hash(options));

@override
String toString() {
  return 'KioskOrderItemRaw(seq: $seq, skuNo: $skuNo, menuName: $menuName, temp: $temp, size: $size, options: $options)';
}


}

/// @nodoc
abstract mixin class $KioskOrderItemRawCopyWith<$Res>  {
  factory $KioskOrderItemRawCopyWith(KioskOrderItemRaw value, $Res Function(KioskOrderItemRaw) _then) = _$KioskOrderItemRawCopyWithImpl;
@useResult
$Res call({
 int seq, String skuNo, String menuName, String temp, String size, List<SelectedOption> options
});




}
/// @nodoc
class _$KioskOrderItemRawCopyWithImpl<$Res>
    implements $KioskOrderItemRawCopyWith<$Res> {
  _$KioskOrderItemRawCopyWithImpl(this._self, this._then);

  final KioskOrderItemRaw _self;
  final $Res Function(KioskOrderItemRaw) _then;

/// Create a copy of KioskOrderItemRaw
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? seq = null,Object? skuNo = null,Object? menuName = null,Object? temp = null,Object? size = null,Object? options = null,}) {
  return _then(_self.copyWith(
seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,skuNo: null == skuNo ? _self.skuNo : skuNo // ignore: cast_nullable_to_non_nullable
as String,menuName: null == menuName ? _self.menuName : menuName // ignore: cast_nullable_to_non_nullable
as String,temp: null == temp ? _self.temp : temp // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<SelectedOption>,
  ));
}

}


/// Adds pattern-matching-related methods to [KioskOrderItemRaw].
extension KioskOrderItemRawPatterns on KioskOrderItemRaw {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KioskOrderItemRaw value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KioskOrderItemRaw() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KioskOrderItemRaw value)  $default,){
final _that = this;
switch (_that) {
case _KioskOrderItemRaw():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KioskOrderItemRaw value)?  $default,){
final _that = this;
switch (_that) {
case _KioskOrderItemRaw() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int seq,  String skuNo,  String menuName,  String temp,  String size,  List<SelectedOption> options)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KioskOrderItemRaw() when $default != null:
return $default(_that.seq,_that.skuNo,_that.menuName,_that.temp,_that.size,_that.options);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int seq,  String skuNo,  String menuName,  String temp,  String size,  List<SelectedOption> options)  $default,) {final _that = this;
switch (_that) {
case _KioskOrderItemRaw():
return $default(_that.seq,_that.skuNo,_that.menuName,_that.temp,_that.size,_that.options);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int seq,  String skuNo,  String menuName,  String temp,  String size,  List<SelectedOption> options)?  $default,) {final _that = this;
switch (_that) {
case _KioskOrderItemRaw() when $default != null:
return $default(_that.seq,_that.skuNo,_that.menuName,_that.temp,_that.size,_that.options);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KioskOrderItemRaw extends KioskOrderItemRaw {
  const _KioskOrderItemRaw({this.seq = 0, this.skuNo = '', this.menuName = '', this.temp = '', this.size = '', final  List<SelectedOption> options = const []}): _options = options,super._();
  factory _KioskOrderItemRaw.fromJson(Map<String, dynamic> json) => _$KioskOrderItemRawFromJson(json);

@override@JsonKey() final  int seq;
@override@JsonKey() final  String skuNo;
@override@JsonKey() final  String menuName;
@override@JsonKey() final  String temp;
@override@JsonKey() final  String size;
 final  List<SelectedOption> _options;
@override@JsonKey() List<SelectedOption> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}


/// Create a copy of KioskOrderItemRaw
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KioskOrderItemRawCopyWith<_KioskOrderItemRaw> get copyWith => __$KioskOrderItemRawCopyWithImpl<_KioskOrderItemRaw>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KioskOrderItemRawToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KioskOrderItemRaw&&(identical(other.seq, seq) || other.seq == seq)&&(identical(other.skuNo, skuNo) || other.skuNo == skuNo)&&(identical(other.menuName, menuName) || other.menuName == menuName)&&(identical(other.temp, temp) || other.temp == temp)&&(identical(other.size, size) || other.size == size)&&const DeepCollectionEquality().equals(other._options, _options));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,seq,skuNo,menuName,temp,size,const DeepCollectionEquality().hash(_options));

@override
String toString() {
  return 'KioskOrderItemRaw(seq: $seq, skuNo: $skuNo, menuName: $menuName, temp: $temp, size: $size, options: $options)';
}


}

/// @nodoc
abstract mixin class _$KioskOrderItemRawCopyWith<$Res> implements $KioskOrderItemRawCopyWith<$Res> {
  factory _$KioskOrderItemRawCopyWith(_KioskOrderItemRaw value, $Res Function(_KioskOrderItemRaw) _then) = __$KioskOrderItemRawCopyWithImpl;
@override @useResult
$Res call({
 int seq, String skuNo, String menuName, String temp, String size, List<SelectedOption> options
});




}
/// @nodoc
class __$KioskOrderItemRawCopyWithImpl<$Res>
    implements _$KioskOrderItemRawCopyWith<$Res> {
  __$KioskOrderItemRawCopyWithImpl(this._self, this._then);

  final _KioskOrderItemRaw _self;
  final $Res Function(_KioskOrderItemRaw) _then;

/// Create a copy of KioskOrderItemRaw
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? seq = null,Object? skuNo = null,Object? menuName = null,Object? temp = null,Object? size = null,Object? options = null,}) {
  return _then(_KioskOrderItemRaw(
seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,skuNo: null == skuNo ? _self.skuNo : skuNo // ignore: cast_nullable_to_non_nullable
as String,menuName: null == menuName ? _self.menuName : menuName // ignore: cast_nullable_to_non_nullable
as String,temp: null == temp ? _self.temp : temp // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<SelectedOption>,
  ));
}


}

// dart format on
