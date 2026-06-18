// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_raw.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderRaw {

 String get orderNo; String get menuName; OrderStatus get status;
/// Create a copy of OrderRaw
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderRawCopyWith<OrderRaw> get copyWith => _$OrderRawCopyWithImpl<OrderRaw>(this as OrderRaw, _$identity);

  /// Serializes this OrderRaw to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderRaw&&(identical(other.orderNo, orderNo) || other.orderNo == orderNo)&&(identical(other.menuName, menuName) || other.menuName == menuName)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderNo,menuName,status);

@override
String toString() {
  return 'OrderRaw(orderNo: $orderNo, menuName: $menuName, status: $status)';
}


}

/// @nodoc
abstract mixin class $OrderRawCopyWith<$Res>  {
  factory $OrderRawCopyWith(OrderRaw value, $Res Function(OrderRaw) _then) = _$OrderRawCopyWithImpl;
@useResult
$Res call({
 String orderNo, String menuName, OrderStatus status
});




}
/// @nodoc
class _$OrderRawCopyWithImpl<$Res>
    implements $OrderRawCopyWith<$Res> {
  _$OrderRawCopyWithImpl(this._self, this._then);

  final OrderRaw _self;
  final $Res Function(OrderRaw) _then;

/// Create a copy of OrderRaw
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderNo = null,Object? menuName = null,Object? status = null,}) {
  return _then(_self.copyWith(
orderNo: null == orderNo ? _self.orderNo : orderNo // ignore: cast_nullable_to_non_nullable
as String,menuName: null == menuName ? _self.menuName : menuName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderRaw].
extension OrderRawPatterns on OrderRaw {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderRaw value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderRaw() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderRaw value)  $default,){
final _that = this;
switch (_that) {
case _OrderRaw():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderRaw value)?  $default,){
final _that = this;
switch (_that) {
case _OrderRaw() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String orderNo,  String menuName,  OrderStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderRaw() when $default != null:
return $default(_that.orderNo,_that.menuName,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String orderNo,  String menuName,  OrderStatus status)  $default,) {final _that = this;
switch (_that) {
case _OrderRaw():
return $default(_that.orderNo,_that.menuName,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String orderNo,  String menuName,  OrderStatus status)?  $default,) {final _that = this;
switch (_that) {
case _OrderRaw() when $default != null:
return $default(_that.orderNo,_that.menuName,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderRaw extends OrderRaw {
  const _OrderRaw({this.orderNo = '', this.menuName = '', this.status = OrderStatus.pending}): super._();
  factory _OrderRaw.fromJson(Map<String, dynamic> json) => _$OrderRawFromJson(json);

@override@JsonKey() final  String orderNo;
@override@JsonKey() final  String menuName;
@override@JsonKey() final  OrderStatus status;

/// Create a copy of OrderRaw
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderRawCopyWith<_OrderRaw> get copyWith => __$OrderRawCopyWithImpl<_OrderRaw>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderRawToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderRaw&&(identical(other.orderNo, orderNo) || other.orderNo == orderNo)&&(identical(other.menuName, menuName) || other.menuName == menuName)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,orderNo,menuName,status);

@override
String toString() {
  return 'OrderRaw(orderNo: $orderNo, menuName: $menuName, status: $status)';
}


}

/// @nodoc
abstract mixin class _$OrderRawCopyWith<$Res> implements $OrderRawCopyWith<$Res> {
  factory _$OrderRawCopyWith(_OrderRaw value, $Res Function(_OrderRaw) _then) = __$OrderRawCopyWithImpl;
@override @useResult
$Res call({
 String orderNo, String menuName, OrderStatus status
});




}
/// @nodoc
class __$OrderRawCopyWithImpl<$Res>
    implements _$OrderRawCopyWith<$Res> {
  __$OrderRawCopyWithImpl(this._self, this._then);

  final _OrderRaw _self;
  final $Res Function(_OrderRaw) _then;

/// Create a copy of OrderRaw
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderNo = null,Object? menuName = null,Object? status = null,}) {
  return _then(_OrderRaw(
orderNo: null == orderNo ? _self.orderNo : orderNo // ignore: cast_nullable_to_non_nullable
as String,menuName: null == menuName ? _self.menuName : menuName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,
  ));
}


}

// dart format on
