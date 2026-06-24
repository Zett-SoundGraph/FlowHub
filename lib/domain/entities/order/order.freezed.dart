// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Order {

 String get orderNo; String get rawOrderId; String? get nickname; List<SubItem> get items; int get drinkCount; int get foodCount; int get bottleCount;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.orderNo, orderNo) || other.orderNo == orderNo)&&(identical(other.rawOrderId, rawOrderId) || other.rawOrderId == rawOrderId)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.drinkCount, drinkCount) || other.drinkCount == drinkCount)&&(identical(other.foodCount, foodCount) || other.foodCount == foodCount)&&(identical(other.bottleCount, bottleCount) || other.bottleCount == bottleCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderNo,rawOrderId,nickname,const DeepCollectionEquality().hash(items),drinkCount,foodCount,bottleCount);

@override
String toString() {
  return 'Order(orderNo: $orderNo, rawOrderId: $rawOrderId, nickname: $nickname, items: $items, drinkCount: $drinkCount, foodCount: $foodCount, bottleCount: $bottleCount)';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 String orderNo, String rawOrderId, String? nickname, List<SubItem> items, int drinkCount, int foodCount, int bottleCount
});




}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderNo = null,Object? rawOrderId = null,Object? nickname = freezed,Object? items = null,Object? drinkCount = null,Object? foodCount = null,Object? bottleCount = null,}) {
  return _then(_self.copyWith(
orderNo: null == orderNo ? _self.orderNo : orderNo // ignore: cast_nullable_to_non_nullable
as String,rawOrderId: null == rawOrderId ? _self.rawOrderId : rawOrderId // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SubItem>,drinkCount: null == drinkCount ? _self.drinkCount : drinkCount // ignore: cast_nullable_to_non_nullable
as int,foodCount: null == foodCount ? _self.foodCount : foodCount // ignore: cast_nullable_to_non_nullable
as int,bottleCount: null == bottleCount ? _self.bottleCount : bottleCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String orderNo,  String rawOrderId,  String? nickname,  List<SubItem> items,  int drinkCount,  int foodCount,  int bottleCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.orderNo,_that.rawOrderId,_that.nickname,_that.items,_that.drinkCount,_that.foodCount,_that.bottleCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String orderNo,  String rawOrderId,  String? nickname,  List<SubItem> items,  int drinkCount,  int foodCount,  int bottleCount)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.orderNo,_that.rawOrderId,_that.nickname,_that.items,_that.drinkCount,_that.foodCount,_that.bottleCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String orderNo,  String rawOrderId,  String? nickname,  List<SubItem> items,  int drinkCount,  int foodCount,  int bottleCount)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.orderNo,_that.rawOrderId,_that.nickname,_that.items,_that.drinkCount,_that.foodCount,_that.bottleCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Order extends Order {
  const _Order({this.orderNo = '', this.rawOrderId = '', this.nickname, final  List<SubItem> items = const [], this.drinkCount = 0, this.foodCount = 0, this.bottleCount = 0}): _items = items,super._();
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

@override@JsonKey() final  String orderNo;
@override@JsonKey() final  String rawOrderId;
@override final  String? nickname;
 final  List<SubItem> _items;
@override@JsonKey() List<SubItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int drinkCount;
@override@JsonKey() final  int foodCount;
@override@JsonKey() final  int bottleCount;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.orderNo, orderNo) || other.orderNo == orderNo)&&(identical(other.rawOrderId, rawOrderId) || other.rawOrderId == rawOrderId)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.drinkCount, drinkCount) || other.drinkCount == drinkCount)&&(identical(other.foodCount, foodCount) || other.foodCount == foodCount)&&(identical(other.bottleCount, bottleCount) || other.bottleCount == bottleCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderNo,rawOrderId,nickname,const DeepCollectionEquality().hash(_items),drinkCount,foodCount,bottleCount);

@override
String toString() {
  return 'Order(orderNo: $orderNo, rawOrderId: $rawOrderId, nickname: $nickname, items: $items, drinkCount: $drinkCount, foodCount: $foodCount, bottleCount: $bottleCount)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 String orderNo, String rawOrderId, String? nickname, List<SubItem> items, int drinkCount, int foodCount, int bottleCount
});




}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderNo = null,Object? rawOrderId = null,Object? nickname = freezed,Object? items = null,Object? drinkCount = null,Object? foodCount = null,Object? bottleCount = null,}) {
  return _then(_Order(
orderNo: null == orderNo ? _self.orderNo : orderNo // ignore: cast_nullable_to_non_nullable
as String,rawOrderId: null == rawOrderId ? _self.rawOrderId : rawOrderId // ignore: cast_nullable_to_non_nullable
as String,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SubItem>,drinkCount: null == drinkCount ? _self.drinkCount : drinkCount // ignore: cast_nullable_to_non_nullable
as int,foodCount: null == foodCount ? _self.foodCount : foodCount // ignore: cast_nullable_to_non_nullable
as int,bottleCount: null == bottleCount ? _self.bottleCount : bottleCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
