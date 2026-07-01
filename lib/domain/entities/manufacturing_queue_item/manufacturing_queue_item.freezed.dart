// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'manufacturing_queue_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ManufacturingQueueItem {

 String get machineIp; String get productKey; String get machineOrderNo;// format: "1001.01" — sent to Caye machine
 String get orderNo;// format: "1001" — used to look up KDS order list
 int get subItemIndex;// index within Order.items
 bool get isExtraShot; String get qrData;
/// Create a copy of ManufacturingQueueItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManufacturingQueueItemCopyWith<ManufacturingQueueItem> get copyWith => _$ManufacturingQueueItemCopyWithImpl<ManufacturingQueueItem>(this as ManufacturingQueueItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ManufacturingQueueItem&&(identical(other.machineIp, machineIp) || other.machineIp == machineIp)&&(identical(other.productKey, productKey) || other.productKey == productKey)&&(identical(other.machineOrderNo, machineOrderNo) || other.machineOrderNo == machineOrderNo)&&(identical(other.orderNo, orderNo) || other.orderNo == orderNo)&&(identical(other.subItemIndex, subItemIndex) || other.subItemIndex == subItemIndex)&&(identical(other.isExtraShot, isExtraShot) || other.isExtraShot == isExtraShot)&&(identical(other.qrData, qrData) || other.qrData == qrData));
}


@override
int get hashCode => Object.hash(runtimeType,machineIp,productKey,machineOrderNo,orderNo,subItemIndex,isExtraShot,qrData);

@override
String toString() {
  return 'ManufacturingQueueItem(machineIp: $machineIp, productKey: $productKey, machineOrderNo: $machineOrderNo, orderNo: $orderNo, subItemIndex: $subItemIndex, isExtraShot: $isExtraShot, qrData: $qrData)';
}


}

/// @nodoc
abstract mixin class $ManufacturingQueueItemCopyWith<$Res>  {
  factory $ManufacturingQueueItemCopyWith(ManufacturingQueueItem value, $Res Function(ManufacturingQueueItem) _then) = _$ManufacturingQueueItemCopyWithImpl;
@useResult
$Res call({
 String machineIp, String productKey, String machineOrderNo, String orderNo, int subItemIndex, bool isExtraShot, String qrData
});




}
/// @nodoc
class _$ManufacturingQueueItemCopyWithImpl<$Res>
    implements $ManufacturingQueueItemCopyWith<$Res> {
  _$ManufacturingQueueItemCopyWithImpl(this._self, this._then);

  final ManufacturingQueueItem _self;
  final $Res Function(ManufacturingQueueItem) _then;

/// Create a copy of ManufacturingQueueItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? machineIp = null,Object? productKey = null,Object? machineOrderNo = null,Object? orderNo = null,Object? subItemIndex = null,Object? isExtraShot = null,Object? qrData = null,}) {
  return _then(_self.copyWith(
machineIp: null == machineIp ? _self.machineIp : machineIp // ignore: cast_nullable_to_non_nullable
as String,productKey: null == productKey ? _self.productKey : productKey // ignore: cast_nullable_to_non_nullable
as String,machineOrderNo: null == machineOrderNo ? _self.machineOrderNo : machineOrderNo // ignore: cast_nullable_to_non_nullable
as String,orderNo: null == orderNo ? _self.orderNo : orderNo // ignore: cast_nullable_to_non_nullable
as String,subItemIndex: null == subItemIndex ? _self.subItemIndex : subItemIndex // ignore: cast_nullable_to_non_nullable
as int,isExtraShot: null == isExtraShot ? _self.isExtraShot : isExtraShot // ignore: cast_nullable_to_non_nullable
as bool,qrData: null == qrData ? _self.qrData : qrData // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ManufacturingQueueItem].
extension ManufacturingQueueItemPatterns on ManufacturingQueueItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ManufacturingQueueItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ManufacturingQueueItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ManufacturingQueueItem value)  $default,){
final _that = this;
switch (_that) {
case _ManufacturingQueueItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ManufacturingQueueItem value)?  $default,){
final _that = this;
switch (_that) {
case _ManufacturingQueueItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String machineIp,  String productKey,  String machineOrderNo,  String orderNo,  int subItemIndex,  bool isExtraShot,  String qrData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ManufacturingQueueItem() when $default != null:
return $default(_that.machineIp,_that.productKey,_that.machineOrderNo,_that.orderNo,_that.subItemIndex,_that.isExtraShot,_that.qrData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String machineIp,  String productKey,  String machineOrderNo,  String orderNo,  int subItemIndex,  bool isExtraShot,  String qrData)  $default,) {final _that = this;
switch (_that) {
case _ManufacturingQueueItem():
return $default(_that.machineIp,_that.productKey,_that.machineOrderNo,_that.orderNo,_that.subItemIndex,_that.isExtraShot,_that.qrData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String machineIp,  String productKey,  String machineOrderNo,  String orderNo,  int subItemIndex,  bool isExtraShot,  String qrData)?  $default,) {final _that = this;
switch (_that) {
case _ManufacturingQueueItem() when $default != null:
return $default(_that.machineIp,_that.productKey,_that.machineOrderNo,_that.orderNo,_that.subItemIndex,_that.isExtraShot,_that.qrData);case _:
  return null;

}
}

}

/// @nodoc


class _ManufacturingQueueItem implements ManufacturingQueueItem {
  const _ManufacturingQueueItem({required this.machineIp, required this.productKey, required this.machineOrderNo, required this.orderNo, required this.subItemIndex, this.isExtraShot = false, this.qrData = ''});
  

@override final  String machineIp;
@override final  String productKey;
@override final  String machineOrderNo;
// format: "1001.01" — sent to Caye machine
@override final  String orderNo;
// format: "1001" — used to look up KDS order list
@override final  int subItemIndex;
// index within Order.items
@override@JsonKey() final  bool isExtraShot;
@override@JsonKey() final  String qrData;

/// Create a copy of ManufacturingQueueItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManufacturingQueueItemCopyWith<_ManufacturingQueueItem> get copyWith => __$ManufacturingQueueItemCopyWithImpl<_ManufacturingQueueItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ManufacturingQueueItem&&(identical(other.machineIp, machineIp) || other.machineIp == machineIp)&&(identical(other.productKey, productKey) || other.productKey == productKey)&&(identical(other.machineOrderNo, machineOrderNo) || other.machineOrderNo == machineOrderNo)&&(identical(other.orderNo, orderNo) || other.orderNo == orderNo)&&(identical(other.subItemIndex, subItemIndex) || other.subItemIndex == subItemIndex)&&(identical(other.isExtraShot, isExtraShot) || other.isExtraShot == isExtraShot)&&(identical(other.qrData, qrData) || other.qrData == qrData));
}


@override
int get hashCode => Object.hash(runtimeType,machineIp,productKey,machineOrderNo,orderNo,subItemIndex,isExtraShot,qrData);

@override
String toString() {
  return 'ManufacturingQueueItem(machineIp: $machineIp, productKey: $productKey, machineOrderNo: $machineOrderNo, orderNo: $orderNo, subItemIndex: $subItemIndex, isExtraShot: $isExtraShot, qrData: $qrData)';
}


}

/// @nodoc
abstract mixin class _$ManufacturingQueueItemCopyWith<$Res> implements $ManufacturingQueueItemCopyWith<$Res> {
  factory _$ManufacturingQueueItemCopyWith(_ManufacturingQueueItem value, $Res Function(_ManufacturingQueueItem) _then) = __$ManufacturingQueueItemCopyWithImpl;
@override @useResult
$Res call({
 String machineIp, String productKey, String machineOrderNo, String orderNo, int subItemIndex, bool isExtraShot, String qrData
});




}
/// @nodoc
class __$ManufacturingQueueItemCopyWithImpl<$Res>
    implements _$ManufacturingQueueItemCopyWith<$Res> {
  __$ManufacturingQueueItemCopyWithImpl(this._self, this._then);

  final _ManufacturingQueueItem _self;
  final $Res Function(_ManufacturingQueueItem) _then;

/// Create a copy of ManufacturingQueueItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? machineIp = null,Object? productKey = null,Object? machineOrderNo = null,Object? orderNo = null,Object? subItemIndex = null,Object? isExtraShot = null,Object? qrData = null,}) {
  return _then(_ManufacturingQueueItem(
machineIp: null == machineIp ? _self.machineIp : machineIp // ignore: cast_nullable_to_non_nullable
as String,productKey: null == productKey ? _self.productKey : productKey // ignore: cast_nullable_to_non_nullable
as String,machineOrderNo: null == machineOrderNo ? _self.machineOrderNo : machineOrderNo // ignore: cast_nullable_to_non_nullable
as String,orderNo: null == orderNo ? _self.orderNo : orderNo // ignore: cast_nullable_to_non_nullable
as String,subItemIndex: null == subItemIndex ? _self.subItemIndex : subItemIndex // ignore: cast_nullable_to_non_nullable
as int,isExtraShot: null == isExtraShot ? _self.isExtraShot : isExtraShot // ignore: cast_nullable_to_non_nullable
as bool,qrData: null == qrData ? _self.qrData : qrData // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
