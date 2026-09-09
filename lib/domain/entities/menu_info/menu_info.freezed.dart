// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MenuOptionSlot {

 String get optionNo; bool get enabled; String get defaultRaw;
/// Create a copy of MenuOptionSlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuOptionSlotCopyWith<MenuOptionSlot> get copyWith => _$MenuOptionSlotCopyWithImpl<MenuOptionSlot>(this as MenuOptionSlot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuOptionSlot&&(identical(other.optionNo, optionNo) || other.optionNo == optionNo)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.defaultRaw, defaultRaw) || other.defaultRaw == defaultRaw));
}


@override
int get hashCode => Object.hash(runtimeType,optionNo,enabled,defaultRaw);

@override
String toString() {
  return 'MenuOptionSlot(optionNo: $optionNo, enabled: $enabled, defaultRaw: $defaultRaw)';
}


}

/// @nodoc
abstract mixin class $MenuOptionSlotCopyWith<$Res>  {
  factory $MenuOptionSlotCopyWith(MenuOptionSlot value, $Res Function(MenuOptionSlot) _then) = _$MenuOptionSlotCopyWithImpl;
@useResult
$Res call({
 String optionNo, bool enabled, String defaultRaw
});




}
/// @nodoc
class _$MenuOptionSlotCopyWithImpl<$Res>
    implements $MenuOptionSlotCopyWith<$Res> {
  _$MenuOptionSlotCopyWithImpl(this._self, this._then);

  final MenuOptionSlot _self;
  final $Res Function(MenuOptionSlot) _then;

/// Create a copy of MenuOptionSlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? optionNo = null,Object? enabled = null,Object? defaultRaw = null,}) {
  return _then(_self.copyWith(
optionNo: null == optionNo ? _self.optionNo : optionNo // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,defaultRaw: null == defaultRaw ? _self.defaultRaw : defaultRaw // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuOptionSlot].
extension MenuOptionSlotPatterns on MenuOptionSlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuOptionSlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuOptionSlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuOptionSlot value)  $default,){
final _that = this;
switch (_that) {
case _MenuOptionSlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuOptionSlot value)?  $default,){
final _that = this;
switch (_that) {
case _MenuOptionSlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String optionNo,  bool enabled,  String defaultRaw)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuOptionSlot() when $default != null:
return $default(_that.optionNo,_that.enabled,_that.defaultRaw);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String optionNo,  bool enabled,  String defaultRaw)  $default,) {final _that = this;
switch (_that) {
case _MenuOptionSlot():
return $default(_that.optionNo,_that.enabled,_that.defaultRaw);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String optionNo,  bool enabled,  String defaultRaw)?  $default,) {final _that = this;
switch (_that) {
case _MenuOptionSlot() when $default != null:
return $default(_that.optionNo,_that.enabled,_that.defaultRaw);case _:
  return null;

}
}

}

/// @nodoc


class _MenuOptionSlot implements MenuOptionSlot {
  const _MenuOptionSlot({required this.optionNo, required this.enabled, required this.defaultRaw});
  

@override final  String optionNo;
@override final  bool enabled;
@override final  String defaultRaw;

/// Create a copy of MenuOptionSlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuOptionSlotCopyWith<_MenuOptionSlot> get copyWith => __$MenuOptionSlotCopyWithImpl<_MenuOptionSlot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuOptionSlot&&(identical(other.optionNo, optionNo) || other.optionNo == optionNo)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.defaultRaw, defaultRaw) || other.defaultRaw == defaultRaw));
}


@override
int get hashCode => Object.hash(runtimeType,optionNo,enabled,defaultRaw);

@override
String toString() {
  return 'MenuOptionSlot(optionNo: $optionNo, enabled: $enabled, defaultRaw: $defaultRaw)';
}


}

/// @nodoc
abstract mixin class _$MenuOptionSlotCopyWith<$Res> implements $MenuOptionSlotCopyWith<$Res> {
  factory _$MenuOptionSlotCopyWith(_MenuOptionSlot value, $Res Function(_MenuOptionSlot) _then) = __$MenuOptionSlotCopyWithImpl;
@override @useResult
$Res call({
 String optionNo, bool enabled, String defaultRaw
});




}
/// @nodoc
class __$MenuOptionSlotCopyWithImpl<$Res>
    implements _$MenuOptionSlotCopyWith<$Res> {
  __$MenuOptionSlotCopyWithImpl(this._self, this._then);

  final _MenuOptionSlot _self;
  final $Res Function(_MenuOptionSlot) _then;

/// Create a copy of MenuOptionSlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? optionNo = null,Object? enabled = null,Object? defaultRaw = null,}) {
  return _then(_MenuOptionSlot(
optionNo: null == optionNo ? _self.optionNo : optionNo // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,defaultRaw: null == defaultRaw ? _self.defaultRaw : defaultRaw // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$MenuInfo {

 String get menuNameEN; bool get hot; bool get iced; String get groupNameEN; String get categoryNameEN; String? get thumbnailImageUrl; List<MenuOptionSlot> get optionSlots;
/// Create a copy of MenuInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuInfoCopyWith<MenuInfo> get copyWith => _$MenuInfoCopyWithImpl<MenuInfo>(this as MenuInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuInfo&&(identical(other.menuNameEN, menuNameEN) || other.menuNameEN == menuNameEN)&&(identical(other.hot, hot) || other.hot == hot)&&(identical(other.iced, iced) || other.iced == iced)&&(identical(other.groupNameEN, groupNameEN) || other.groupNameEN == groupNameEN)&&(identical(other.categoryNameEN, categoryNameEN) || other.categoryNameEN == categoryNameEN)&&(identical(other.thumbnailImageUrl, thumbnailImageUrl) || other.thumbnailImageUrl == thumbnailImageUrl)&&const DeepCollectionEquality().equals(other.optionSlots, optionSlots));
}


@override
int get hashCode => Object.hash(runtimeType,menuNameEN,hot,iced,groupNameEN,categoryNameEN,thumbnailImageUrl,const DeepCollectionEquality().hash(optionSlots));

@override
String toString() {
  return 'MenuInfo(menuNameEN: $menuNameEN, hot: $hot, iced: $iced, groupNameEN: $groupNameEN, categoryNameEN: $categoryNameEN, thumbnailImageUrl: $thumbnailImageUrl, optionSlots: $optionSlots)';
}


}

/// @nodoc
abstract mixin class $MenuInfoCopyWith<$Res>  {
  factory $MenuInfoCopyWith(MenuInfo value, $Res Function(MenuInfo) _then) = _$MenuInfoCopyWithImpl;
@useResult
$Res call({
 String menuNameEN, bool hot, bool iced, String groupNameEN, String categoryNameEN, String? thumbnailImageUrl, List<MenuOptionSlot> optionSlots
});




}
/// @nodoc
class _$MenuInfoCopyWithImpl<$Res>
    implements $MenuInfoCopyWith<$Res> {
  _$MenuInfoCopyWithImpl(this._self, this._then);

  final MenuInfo _self;
  final $Res Function(MenuInfo) _then;

/// Create a copy of MenuInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? menuNameEN = null,Object? hot = null,Object? iced = null,Object? groupNameEN = null,Object? categoryNameEN = null,Object? thumbnailImageUrl = freezed,Object? optionSlots = null,}) {
  return _then(_self.copyWith(
menuNameEN: null == menuNameEN ? _self.menuNameEN : menuNameEN // ignore: cast_nullable_to_non_nullable
as String,hot: null == hot ? _self.hot : hot // ignore: cast_nullable_to_non_nullable
as bool,iced: null == iced ? _self.iced : iced // ignore: cast_nullable_to_non_nullable
as bool,groupNameEN: null == groupNameEN ? _self.groupNameEN : groupNameEN // ignore: cast_nullable_to_non_nullable
as String,categoryNameEN: null == categoryNameEN ? _self.categoryNameEN : categoryNameEN // ignore: cast_nullable_to_non_nullable
as String,thumbnailImageUrl: freezed == thumbnailImageUrl ? _self.thumbnailImageUrl : thumbnailImageUrl // ignore: cast_nullable_to_non_nullable
as String?,optionSlots: null == optionSlots ? _self.optionSlots : optionSlots // ignore: cast_nullable_to_non_nullable
as List<MenuOptionSlot>,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuInfo].
extension MenuInfoPatterns on MenuInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuInfo value)  $default,){
final _that = this;
switch (_that) {
case _MenuInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuInfo value)?  $default,){
final _that = this;
switch (_that) {
case _MenuInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String menuNameEN,  bool hot,  bool iced,  String groupNameEN,  String categoryNameEN,  String? thumbnailImageUrl,  List<MenuOptionSlot> optionSlots)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuInfo() when $default != null:
return $default(_that.menuNameEN,_that.hot,_that.iced,_that.groupNameEN,_that.categoryNameEN,_that.thumbnailImageUrl,_that.optionSlots);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String menuNameEN,  bool hot,  bool iced,  String groupNameEN,  String categoryNameEN,  String? thumbnailImageUrl,  List<MenuOptionSlot> optionSlots)  $default,) {final _that = this;
switch (_that) {
case _MenuInfo():
return $default(_that.menuNameEN,_that.hot,_that.iced,_that.groupNameEN,_that.categoryNameEN,_that.thumbnailImageUrl,_that.optionSlots);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String menuNameEN,  bool hot,  bool iced,  String groupNameEN,  String categoryNameEN,  String? thumbnailImageUrl,  List<MenuOptionSlot> optionSlots)?  $default,) {final _that = this;
switch (_that) {
case _MenuInfo() when $default != null:
return $default(_that.menuNameEN,_that.hot,_that.iced,_that.groupNameEN,_that.categoryNameEN,_that.thumbnailImageUrl,_that.optionSlots);case _:
  return null;

}
}

}

/// @nodoc


class _MenuInfo implements MenuInfo {
  const _MenuInfo({required this.menuNameEN, this.hot = false, this.iced = false, this.groupNameEN = '', this.categoryNameEN = '', this.thumbnailImageUrl, final  List<MenuOptionSlot> optionSlots = const []}): _optionSlots = optionSlots;
  

@override final  String menuNameEN;
@override@JsonKey() final  bool hot;
@override@JsonKey() final  bool iced;
@override@JsonKey() final  String groupNameEN;
@override@JsonKey() final  String categoryNameEN;
@override final  String? thumbnailImageUrl;
 final  List<MenuOptionSlot> _optionSlots;
@override@JsonKey() List<MenuOptionSlot> get optionSlots {
  if (_optionSlots is EqualUnmodifiableListView) return _optionSlots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_optionSlots);
}


/// Create a copy of MenuInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuInfoCopyWith<_MenuInfo> get copyWith => __$MenuInfoCopyWithImpl<_MenuInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuInfo&&(identical(other.menuNameEN, menuNameEN) || other.menuNameEN == menuNameEN)&&(identical(other.hot, hot) || other.hot == hot)&&(identical(other.iced, iced) || other.iced == iced)&&(identical(other.groupNameEN, groupNameEN) || other.groupNameEN == groupNameEN)&&(identical(other.categoryNameEN, categoryNameEN) || other.categoryNameEN == categoryNameEN)&&(identical(other.thumbnailImageUrl, thumbnailImageUrl) || other.thumbnailImageUrl == thumbnailImageUrl)&&const DeepCollectionEquality().equals(other._optionSlots, _optionSlots));
}


@override
int get hashCode => Object.hash(runtimeType,menuNameEN,hot,iced,groupNameEN,categoryNameEN,thumbnailImageUrl,const DeepCollectionEquality().hash(_optionSlots));

@override
String toString() {
  return 'MenuInfo(menuNameEN: $menuNameEN, hot: $hot, iced: $iced, groupNameEN: $groupNameEN, categoryNameEN: $categoryNameEN, thumbnailImageUrl: $thumbnailImageUrl, optionSlots: $optionSlots)';
}


}

/// @nodoc
abstract mixin class _$MenuInfoCopyWith<$Res> implements $MenuInfoCopyWith<$Res> {
  factory _$MenuInfoCopyWith(_MenuInfo value, $Res Function(_MenuInfo) _then) = __$MenuInfoCopyWithImpl;
@override @useResult
$Res call({
 String menuNameEN, bool hot, bool iced, String groupNameEN, String categoryNameEN, String? thumbnailImageUrl, List<MenuOptionSlot> optionSlots
});




}
/// @nodoc
class __$MenuInfoCopyWithImpl<$Res>
    implements _$MenuInfoCopyWith<$Res> {
  __$MenuInfoCopyWithImpl(this._self, this._then);

  final _MenuInfo _self;
  final $Res Function(_MenuInfo) _then;

/// Create a copy of MenuInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? menuNameEN = null,Object? hot = null,Object? iced = null,Object? groupNameEN = null,Object? categoryNameEN = null,Object? thumbnailImageUrl = freezed,Object? optionSlots = null,}) {
  return _then(_MenuInfo(
menuNameEN: null == menuNameEN ? _self.menuNameEN : menuNameEN // ignore: cast_nullable_to_non_nullable
as String,hot: null == hot ? _self.hot : hot // ignore: cast_nullable_to_non_nullable
as bool,iced: null == iced ? _self.iced : iced // ignore: cast_nullable_to_non_nullable
as bool,groupNameEN: null == groupNameEN ? _self.groupNameEN : groupNameEN // ignore: cast_nullable_to_non_nullable
as String,categoryNameEN: null == categoryNameEN ? _self.categoryNameEN : categoryNameEN // ignore: cast_nullable_to_non_nullable
as String,thumbnailImageUrl: freezed == thumbnailImageUrl ? _self.thumbnailImageUrl : thumbnailImageUrl // ignore: cast_nullable_to_non_nullable
as String?,optionSlots: null == optionSlots ? _self._optionSlots : optionSlots // ignore: cast_nullable_to_non_nullable
as List<MenuOptionSlot>,
  ));
}


}

// dart format on
