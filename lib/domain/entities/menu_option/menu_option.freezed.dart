// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MenuOption {

 String get optionNo; MenuOptionType get type; String get nameEN; String get groupNameEN; double get volume;
/// Create a copy of MenuOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuOptionCopyWith<MenuOption> get copyWith => _$MenuOptionCopyWithImpl<MenuOption>(this as MenuOption, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuOption&&(identical(other.optionNo, optionNo) || other.optionNo == optionNo)&&(identical(other.type, type) || other.type == type)&&(identical(other.nameEN, nameEN) || other.nameEN == nameEN)&&(identical(other.groupNameEN, groupNameEN) || other.groupNameEN == groupNameEN)&&(identical(other.volume, volume) || other.volume == volume));
}


@override
int get hashCode => Object.hash(runtimeType,optionNo,type,nameEN,groupNameEN,volume);

@override
String toString() {
  return 'MenuOption(optionNo: $optionNo, type: $type, nameEN: $nameEN, groupNameEN: $groupNameEN, volume: $volume)';
}


}

/// @nodoc
abstract mixin class $MenuOptionCopyWith<$Res>  {
  factory $MenuOptionCopyWith(MenuOption value, $Res Function(MenuOption) _then) = _$MenuOptionCopyWithImpl;
@useResult
$Res call({
 String optionNo, MenuOptionType type, String nameEN, String groupNameEN, double volume
});




}
/// @nodoc
class _$MenuOptionCopyWithImpl<$Res>
    implements $MenuOptionCopyWith<$Res> {
  _$MenuOptionCopyWithImpl(this._self, this._then);

  final MenuOption _self;
  final $Res Function(MenuOption) _then;

/// Create a copy of MenuOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? optionNo = null,Object? type = null,Object? nameEN = null,Object? groupNameEN = null,Object? volume = null,}) {
  return _then(_self.copyWith(
optionNo: null == optionNo ? _self.optionNo : optionNo // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MenuOptionType,nameEN: null == nameEN ? _self.nameEN : nameEN // ignore: cast_nullable_to_non_nullable
as String,groupNameEN: null == groupNameEN ? _self.groupNameEN : groupNameEN // ignore: cast_nullable_to_non_nullable
as String,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuOption].
extension MenuOptionPatterns on MenuOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuOption value)  $default,){
final _that = this;
switch (_that) {
case _MenuOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuOption value)?  $default,){
final _that = this;
switch (_that) {
case _MenuOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String optionNo,  MenuOptionType type,  String nameEN,  String groupNameEN,  double volume)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuOption() when $default != null:
return $default(_that.optionNo,_that.type,_that.nameEN,_that.groupNameEN,_that.volume);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String optionNo,  MenuOptionType type,  String nameEN,  String groupNameEN,  double volume)  $default,) {final _that = this;
switch (_that) {
case _MenuOption():
return $default(_that.optionNo,_that.type,_that.nameEN,_that.groupNameEN,_that.volume);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String optionNo,  MenuOptionType type,  String nameEN,  String groupNameEN,  double volume)?  $default,) {final _that = this;
switch (_that) {
case _MenuOption() when $default != null:
return $default(_that.optionNo,_that.type,_that.nameEN,_that.groupNameEN,_that.volume);case _:
  return null;

}
}

}

/// @nodoc


class _MenuOption implements MenuOption {
  const _MenuOption({required this.optionNo, required this.type, required this.nameEN, this.groupNameEN = '', this.volume = 0.0});
  

@override final  String optionNo;
@override final  MenuOptionType type;
@override final  String nameEN;
@override@JsonKey() final  String groupNameEN;
@override@JsonKey() final  double volume;

/// Create a copy of MenuOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuOptionCopyWith<_MenuOption> get copyWith => __$MenuOptionCopyWithImpl<_MenuOption>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuOption&&(identical(other.optionNo, optionNo) || other.optionNo == optionNo)&&(identical(other.type, type) || other.type == type)&&(identical(other.nameEN, nameEN) || other.nameEN == nameEN)&&(identical(other.groupNameEN, groupNameEN) || other.groupNameEN == groupNameEN)&&(identical(other.volume, volume) || other.volume == volume));
}


@override
int get hashCode => Object.hash(runtimeType,optionNo,type,nameEN,groupNameEN,volume);

@override
String toString() {
  return 'MenuOption(optionNo: $optionNo, type: $type, nameEN: $nameEN, groupNameEN: $groupNameEN, volume: $volume)';
}


}

/// @nodoc
abstract mixin class _$MenuOptionCopyWith<$Res> implements $MenuOptionCopyWith<$Res> {
  factory _$MenuOptionCopyWith(_MenuOption value, $Res Function(_MenuOption) _then) = __$MenuOptionCopyWithImpl;
@override @useResult
$Res call({
 String optionNo, MenuOptionType type, String nameEN, String groupNameEN, double volume
});




}
/// @nodoc
class __$MenuOptionCopyWithImpl<$Res>
    implements _$MenuOptionCopyWith<$Res> {
  __$MenuOptionCopyWithImpl(this._self, this._then);

  final _MenuOption _self;
  final $Res Function(_MenuOption) _then;

/// Create a copy of MenuOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? optionNo = null,Object? type = null,Object? nameEN = null,Object? groupNameEN = null,Object? volume = null,}) {
  return _then(_MenuOption(
optionNo: null == optionNo ? _self.optionNo : optionNo // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MenuOptionType,nameEN: null == nameEN ? _self.nameEN : nameEN // ignore: cast_nullable_to_non_nullable
as String,groupNameEN: null == groupNameEN ? _self.groupNameEN : groupNameEN // ignore: cast_nullable_to_non_nullable
as String,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
