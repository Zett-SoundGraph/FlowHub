// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_recipe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MenuRecipe {

 String get productKey; String get menuNameEN; String get beanWeight; String get espresso; String get waterIce; String get waterHot; String get milk;// CSV column[11] — e.g. "20(Banana_Syrup)" → stored as "Banana_Syrup:20"
 String get dispenserData;
/// Create a copy of MenuRecipe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuRecipeCopyWith<MenuRecipe> get copyWith => _$MenuRecipeCopyWithImpl<MenuRecipe>(this as MenuRecipe, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuRecipe&&(identical(other.productKey, productKey) || other.productKey == productKey)&&(identical(other.menuNameEN, menuNameEN) || other.menuNameEN == menuNameEN)&&(identical(other.beanWeight, beanWeight) || other.beanWeight == beanWeight)&&(identical(other.espresso, espresso) || other.espresso == espresso)&&(identical(other.waterIce, waterIce) || other.waterIce == waterIce)&&(identical(other.waterHot, waterHot) || other.waterHot == waterHot)&&(identical(other.milk, milk) || other.milk == milk)&&(identical(other.dispenserData, dispenserData) || other.dispenserData == dispenserData));
}


@override
int get hashCode => Object.hash(runtimeType,productKey,menuNameEN,beanWeight,espresso,waterIce,waterHot,milk,dispenserData);

@override
String toString() {
  return 'MenuRecipe(productKey: $productKey, menuNameEN: $menuNameEN, beanWeight: $beanWeight, espresso: $espresso, waterIce: $waterIce, waterHot: $waterHot, milk: $milk, dispenserData: $dispenserData)';
}


}

/// @nodoc
abstract mixin class $MenuRecipeCopyWith<$Res>  {
  factory $MenuRecipeCopyWith(MenuRecipe value, $Res Function(MenuRecipe) _then) = _$MenuRecipeCopyWithImpl;
@useResult
$Res call({
 String productKey, String menuNameEN, String beanWeight, String espresso, String waterIce, String waterHot, String milk, String dispenserData
});




}
/// @nodoc
class _$MenuRecipeCopyWithImpl<$Res>
    implements $MenuRecipeCopyWith<$Res> {
  _$MenuRecipeCopyWithImpl(this._self, this._then);

  final MenuRecipe _self;
  final $Res Function(MenuRecipe) _then;

/// Create a copy of MenuRecipe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productKey = null,Object? menuNameEN = null,Object? beanWeight = null,Object? espresso = null,Object? waterIce = null,Object? waterHot = null,Object? milk = null,Object? dispenserData = null,}) {
  return _then(_self.copyWith(
productKey: null == productKey ? _self.productKey : productKey // ignore: cast_nullable_to_non_nullable
as String,menuNameEN: null == menuNameEN ? _self.menuNameEN : menuNameEN // ignore: cast_nullable_to_non_nullable
as String,beanWeight: null == beanWeight ? _self.beanWeight : beanWeight // ignore: cast_nullable_to_non_nullable
as String,espresso: null == espresso ? _self.espresso : espresso // ignore: cast_nullable_to_non_nullable
as String,waterIce: null == waterIce ? _self.waterIce : waterIce // ignore: cast_nullable_to_non_nullable
as String,waterHot: null == waterHot ? _self.waterHot : waterHot // ignore: cast_nullable_to_non_nullable
as String,milk: null == milk ? _self.milk : milk // ignore: cast_nullable_to_non_nullable
as String,dispenserData: null == dispenserData ? _self.dispenserData : dispenserData // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuRecipe].
extension MenuRecipePatterns on MenuRecipe {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuRecipe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuRecipe() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuRecipe value)  $default,){
final _that = this;
switch (_that) {
case _MenuRecipe():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuRecipe value)?  $default,){
final _that = this;
switch (_that) {
case _MenuRecipe() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productKey,  String menuNameEN,  String beanWeight,  String espresso,  String waterIce,  String waterHot,  String milk,  String dispenserData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuRecipe() when $default != null:
return $default(_that.productKey,_that.menuNameEN,_that.beanWeight,_that.espresso,_that.waterIce,_that.waterHot,_that.milk,_that.dispenserData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productKey,  String menuNameEN,  String beanWeight,  String espresso,  String waterIce,  String waterHot,  String milk,  String dispenserData)  $default,) {final _that = this;
switch (_that) {
case _MenuRecipe():
return $default(_that.productKey,_that.menuNameEN,_that.beanWeight,_that.espresso,_that.waterIce,_that.waterHot,_that.milk,_that.dispenserData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productKey,  String menuNameEN,  String beanWeight,  String espresso,  String waterIce,  String waterHot,  String milk,  String dispenserData)?  $default,) {final _that = this;
switch (_that) {
case _MenuRecipe() when $default != null:
return $default(_that.productKey,_that.menuNameEN,_that.beanWeight,_that.espresso,_that.waterIce,_that.waterHot,_that.milk,_that.dispenserData);case _:
  return null;

}
}

}

/// @nodoc


class _MenuRecipe extends MenuRecipe {
  const _MenuRecipe({required this.productKey, required this.menuNameEN, this.beanWeight = '', this.espresso = '', this.waterIce = '', this.waterHot = '', this.milk = '', this.dispenserData = 'N:0'}): super._();
  

@override final  String productKey;
@override final  String menuNameEN;
@override@JsonKey() final  String beanWeight;
@override@JsonKey() final  String espresso;
@override@JsonKey() final  String waterIce;
@override@JsonKey() final  String waterHot;
@override@JsonKey() final  String milk;
// CSV column[11] — e.g. "20(Banana_Syrup)" → stored as "Banana_Syrup:20"
@override@JsonKey() final  String dispenserData;

/// Create a copy of MenuRecipe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuRecipeCopyWith<_MenuRecipe> get copyWith => __$MenuRecipeCopyWithImpl<_MenuRecipe>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuRecipe&&(identical(other.productKey, productKey) || other.productKey == productKey)&&(identical(other.menuNameEN, menuNameEN) || other.menuNameEN == menuNameEN)&&(identical(other.beanWeight, beanWeight) || other.beanWeight == beanWeight)&&(identical(other.espresso, espresso) || other.espresso == espresso)&&(identical(other.waterIce, waterIce) || other.waterIce == waterIce)&&(identical(other.waterHot, waterHot) || other.waterHot == waterHot)&&(identical(other.milk, milk) || other.milk == milk)&&(identical(other.dispenserData, dispenserData) || other.dispenserData == dispenserData));
}


@override
int get hashCode => Object.hash(runtimeType,productKey,menuNameEN,beanWeight,espresso,waterIce,waterHot,milk,dispenserData);

@override
String toString() {
  return 'MenuRecipe(productKey: $productKey, menuNameEN: $menuNameEN, beanWeight: $beanWeight, espresso: $espresso, waterIce: $waterIce, waterHot: $waterHot, milk: $milk, dispenserData: $dispenserData)';
}


}

/// @nodoc
abstract mixin class _$MenuRecipeCopyWith<$Res> implements $MenuRecipeCopyWith<$Res> {
  factory _$MenuRecipeCopyWith(_MenuRecipe value, $Res Function(_MenuRecipe) _then) = __$MenuRecipeCopyWithImpl;
@override @useResult
$Res call({
 String productKey, String menuNameEN, String beanWeight, String espresso, String waterIce, String waterHot, String milk, String dispenserData
});




}
/// @nodoc
class __$MenuRecipeCopyWithImpl<$Res>
    implements _$MenuRecipeCopyWith<$Res> {
  __$MenuRecipeCopyWithImpl(this._self, this._then);

  final _MenuRecipe _self;
  final $Res Function(_MenuRecipe) _then;

/// Create a copy of MenuRecipe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productKey = null,Object? menuNameEN = null,Object? beanWeight = null,Object? espresso = null,Object? waterIce = null,Object? waterHot = null,Object? milk = null,Object? dispenserData = null,}) {
  return _then(_MenuRecipe(
productKey: null == productKey ? _self.productKey : productKey // ignore: cast_nullable_to_non_nullable
as String,menuNameEN: null == menuNameEN ? _self.menuNameEN : menuNameEN // ignore: cast_nullable_to_non_nullable
as String,beanWeight: null == beanWeight ? _self.beanWeight : beanWeight // ignore: cast_nullable_to_non_nullable
as String,espresso: null == espresso ? _self.espresso : espresso // ignore: cast_nullable_to_non_nullable
as String,waterIce: null == waterIce ? _self.waterIce : waterIce // ignore: cast_nullable_to_non_nullable
as String,waterHot: null == waterHot ? _self.waterHot : waterHot // ignore: cast_nullable_to_non_nullable
as String,milk: null == milk ? _self.milk : milk // ignore: cast_nullable_to_non_nullable
as String,dispenserData: null == dispenserData ? _self.dispenserData : dispenserData // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
