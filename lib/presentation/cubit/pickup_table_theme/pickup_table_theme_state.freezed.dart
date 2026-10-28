// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pickup_table_theme_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PickupTableThemeState {

 PickupTableThemeBackground get background;// Line style is no longer exposed in the UI (dark+fill was confirmed
// as the only combination going forward) — defaulted straight to fill.
 PickupTableThemeStyle get style; PickupTableThemeDotStyle get dotStyle; PickupTableThemeBackgroundImage get backgroundImage;// The palette editor's current 9 colors (Brew/Call/Call-Expired/
// QR-Highlight/Background) — starts at [background]'s stock preset
// (PickupTableThemeColorRegistry) every time [background] is picked,
// then diverges as the operator tweaks individual swatches. Required
// (no @Default) — PickupTableThemeCubit's constructor always seeds
// this explicitly, same as background/style/dotStyle above.
 PickupTableThemeColorOverrides get colors;// Same "FlowHub's own local record, not a live readback" caveat as
// PickupTableThemeState.appliedSelection.
 PickupTableThemeSelection? get appliedSelection; bool get isSending;
/// Create a copy of PickupTableThemeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PickupTableThemeStateCopyWith<PickupTableThemeState> get copyWith => _$PickupTableThemeStateCopyWithImpl<PickupTableThemeState>(this as PickupTableThemeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PickupTableThemeState&&(identical(other.background, background) || other.background == background)&&(identical(other.style, style) || other.style == style)&&(identical(other.dotStyle, dotStyle) || other.dotStyle == dotStyle)&&(identical(other.backgroundImage, backgroundImage) || other.backgroundImage == backgroundImage)&&(identical(other.colors, colors) || other.colors == colors)&&(identical(other.appliedSelection, appliedSelection) || other.appliedSelection == appliedSelection)&&(identical(other.isSending, isSending) || other.isSending == isSending));
}


@override
int get hashCode => Object.hash(runtimeType,background,style,dotStyle,backgroundImage,colors,appliedSelection,isSending);

@override
String toString() {
  return 'PickupTableThemeState(background: $background, style: $style, dotStyle: $dotStyle, backgroundImage: $backgroundImage, colors: $colors, appliedSelection: $appliedSelection, isSending: $isSending)';
}


}

/// @nodoc
abstract mixin class $PickupTableThemeStateCopyWith<$Res>  {
  factory $PickupTableThemeStateCopyWith(PickupTableThemeState value, $Res Function(PickupTableThemeState) _then) = _$PickupTableThemeStateCopyWithImpl;
@useResult
$Res call({
 PickupTableThemeBackground background, PickupTableThemeStyle style, PickupTableThemeDotStyle dotStyle, PickupTableThemeBackgroundImage backgroundImage, PickupTableThemeColorOverrides colors, PickupTableThemeSelection? appliedSelection, bool isSending
});




}
/// @nodoc
class _$PickupTableThemeStateCopyWithImpl<$Res>
    implements $PickupTableThemeStateCopyWith<$Res> {
  _$PickupTableThemeStateCopyWithImpl(this._self, this._then);

  final PickupTableThemeState _self;
  final $Res Function(PickupTableThemeState) _then;

/// Create a copy of PickupTableThemeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? background = null,Object? style = null,Object? dotStyle = null,Object? backgroundImage = null,Object? colors = null,Object? appliedSelection = freezed,Object? isSending = null,}) {
  return _then(_self.copyWith(
background: null == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as PickupTableThemeBackground,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as PickupTableThemeStyle,dotStyle: null == dotStyle ? _self.dotStyle : dotStyle // ignore: cast_nullable_to_non_nullable
as PickupTableThemeDotStyle,backgroundImage: null == backgroundImage ? _self.backgroundImage : backgroundImage // ignore: cast_nullable_to_non_nullable
as PickupTableThemeBackgroundImage,colors: null == colors ? _self.colors : colors // ignore: cast_nullable_to_non_nullable
as PickupTableThemeColorOverrides,appliedSelection: freezed == appliedSelection ? _self.appliedSelection : appliedSelection // ignore: cast_nullable_to_non_nullable
as PickupTableThemeSelection?,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PickupTableThemeState].
extension PickupTableThemeStatePatterns on PickupTableThemeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PickupTableThemeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PickupTableThemeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PickupTableThemeState value)  $default,){
final _that = this;
switch (_that) {
case _PickupTableThemeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PickupTableThemeState value)?  $default,){
final _that = this;
switch (_that) {
case _PickupTableThemeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PickupTableThemeBackground background,  PickupTableThemeStyle style,  PickupTableThemeDotStyle dotStyle,  PickupTableThemeBackgroundImage backgroundImage,  PickupTableThemeColorOverrides colors,  PickupTableThemeSelection? appliedSelection,  bool isSending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PickupTableThemeState() when $default != null:
return $default(_that.background,_that.style,_that.dotStyle,_that.backgroundImage,_that.colors,_that.appliedSelection,_that.isSending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PickupTableThemeBackground background,  PickupTableThemeStyle style,  PickupTableThemeDotStyle dotStyle,  PickupTableThemeBackgroundImage backgroundImage,  PickupTableThemeColorOverrides colors,  PickupTableThemeSelection? appliedSelection,  bool isSending)  $default,) {final _that = this;
switch (_that) {
case _PickupTableThemeState():
return $default(_that.background,_that.style,_that.dotStyle,_that.backgroundImage,_that.colors,_that.appliedSelection,_that.isSending);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PickupTableThemeBackground background,  PickupTableThemeStyle style,  PickupTableThemeDotStyle dotStyle,  PickupTableThemeBackgroundImage backgroundImage,  PickupTableThemeColorOverrides colors,  PickupTableThemeSelection? appliedSelection,  bool isSending)?  $default,) {final _that = this;
switch (_that) {
case _PickupTableThemeState() when $default != null:
return $default(_that.background,_that.style,_that.dotStyle,_that.backgroundImage,_that.colors,_that.appliedSelection,_that.isSending);case _:
  return null;

}
}

}

/// @nodoc


class _PickupTableThemeState implements PickupTableThemeState {
  const _PickupTableThemeState({this.background = PickupTableThemeBackground.forestGreen, this.style = PickupTableThemeStyle.fill, this.dotStyle = PickupTableThemeDotStyle.standard, this.backgroundImage = PickupTableThemeBackgroundImage.menuImage, required this.colors, this.appliedSelection, this.isSending = false});
  

@override@JsonKey() final  PickupTableThemeBackground background;
// Line style is no longer exposed in the UI (dark+fill was confirmed
// as the only combination going forward) — defaulted straight to fill.
@override@JsonKey() final  PickupTableThemeStyle style;
@override@JsonKey() final  PickupTableThemeDotStyle dotStyle;
@override@JsonKey() final  PickupTableThemeBackgroundImage backgroundImage;
// The palette editor's current 9 colors (Brew/Call/Call-Expired/
// QR-Highlight/Background) — starts at [background]'s stock preset
// (PickupTableThemeColorRegistry) every time [background] is picked,
// then diverges as the operator tweaks individual swatches. Required
// (no @Default) — PickupTableThemeCubit's constructor always seeds
// this explicitly, same as background/style/dotStyle above.
@override final  PickupTableThemeColorOverrides colors;
// Same "FlowHub's own local record, not a live readback" caveat as
// PickupTableThemeState.appliedSelection.
@override final  PickupTableThemeSelection? appliedSelection;
@override@JsonKey() final  bool isSending;

/// Create a copy of PickupTableThemeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PickupTableThemeStateCopyWith<_PickupTableThemeState> get copyWith => __$PickupTableThemeStateCopyWithImpl<_PickupTableThemeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PickupTableThemeState&&(identical(other.background, background) || other.background == background)&&(identical(other.style, style) || other.style == style)&&(identical(other.dotStyle, dotStyle) || other.dotStyle == dotStyle)&&(identical(other.backgroundImage, backgroundImage) || other.backgroundImage == backgroundImage)&&(identical(other.colors, colors) || other.colors == colors)&&(identical(other.appliedSelection, appliedSelection) || other.appliedSelection == appliedSelection)&&(identical(other.isSending, isSending) || other.isSending == isSending));
}


@override
int get hashCode => Object.hash(runtimeType,background,style,dotStyle,backgroundImage,colors,appliedSelection,isSending);

@override
String toString() {
  return 'PickupTableThemeState(background: $background, style: $style, dotStyle: $dotStyle, backgroundImage: $backgroundImage, colors: $colors, appliedSelection: $appliedSelection, isSending: $isSending)';
}


}

/// @nodoc
abstract mixin class _$PickupTableThemeStateCopyWith<$Res> implements $PickupTableThemeStateCopyWith<$Res> {
  factory _$PickupTableThemeStateCopyWith(_PickupTableThemeState value, $Res Function(_PickupTableThemeState) _then) = __$PickupTableThemeStateCopyWithImpl;
@override @useResult
$Res call({
 PickupTableThemeBackground background, PickupTableThemeStyle style, PickupTableThemeDotStyle dotStyle, PickupTableThemeBackgroundImage backgroundImage, PickupTableThemeColorOverrides colors, PickupTableThemeSelection? appliedSelection, bool isSending
});




}
/// @nodoc
class __$PickupTableThemeStateCopyWithImpl<$Res>
    implements _$PickupTableThemeStateCopyWith<$Res> {
  __$PickupTableThemeStateCopyWithImpl(this._self, this._then);

  final _PickupTableThemeState _self;
  final $Res Function(_PickupTableThemeState) _then;

/// Create a copy of PickupTableThemeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? background = null,Object? style = null,Object? dotStyle = null,Object? backgroundImage = null,Object? colors = null,Object? appliedSelection = freezed,Object? isSending = null,}) {
  return _then(_PickupTableThemeState(
background: null == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as PickupTableThemeBackground,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as PickupTableThemeStyle,dotStyle: null == dotStyle ? _self.dotStyle : dotStyle // ignore: cast_nullable_to_non_nullable
as PickupTableThemeDotStyle,backgroundImage: null == backgroundImage ? _self.backgroundImage : backgroundImage // ignore: cast_nullable_to_non_nullable
as PickupTableThemeBackgroundImage,colors: null == colors ? _self.colors : colors // ignore: cast_nullable_to_non_nullable
as PickupTableThemeColorOverrides,appliedSelection: freezed == appliedSelection ? _self.appliedSelection : appliedSelection // ignore: cast_nullable_to_non_nullable
as PickupTableThemeSelection?,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
