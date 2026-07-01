// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'extraction_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExtractionProgress {

 int get code; Map<String, dynamic> get data;
/// Create a copy of ExtractionProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExtractionProgressCopyWith<ExtractionProgress> get copyWith => _$ExtractionProgressCopyWithImpl<ExtractionProgress>(this as ExtractionProgress, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExtractionProgress&&(identical(other.code, code) || other.code == code)&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,code,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'ExtractionProgress(code: $code, data: $data)';
}


}

/// @nodoc
abstract mixin class $ExtractionProgressCopyWith<$Res>  {
  factory $ExtractionProgressCopyWith(ExtractionProgress value, $Res Function(ExtractionProgress) _then) = _$ExtractionProgressCopyWithImpl;
@useResult
$Res call({
 int code, Map<String, dynamic> data
});




}
/// @nodoc
class _$ExtractionProgressCopyWithImpl<$Res>
    implements $ExtractionProgressCopyWith<$Res> {
  _$ExtractionProgressCopyWithImpl(this._self, this._then);

  final ExtractionProgress _self;
  final $Res Function(ExtractionProgress) _then;

/// Create a copy of ExtractionProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? data = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExtractionProgress].
extension ExtractionProgressPatterns on ExtractionProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExtractionProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExtractionProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExtractionProgress value)  $default,){
final _that = this;
switch (_that) {
case _ExtractionProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExtractionProgress value)?  $default,){
final _that = this;
switch (_that) {
case _ExtractionProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int code,  Map<String, dynamic> data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExtractionProgress() when $default != null:
return $default(_that.code,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int code,  Map<String, dynamic> data)  $default,) {final _that = this;
switch (_that) {
case _ExtractionProgress():
return $default(_that.code,_that.data);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int code,  Map<String, dynamic> data)?  $default,) {final _that = this;
switch (_that) {
case _ExtractionProgress() when $default != null:
return $default(_that.code,_that.data);case _:
  return null;

}
}

}

/// @nodoc


class _ExtractionProgress implements ExtractionProgress {
  const _ExtractionProgress({required this.code, required final  Map<String, dynamic> data}): _data = data;
  

@override final  int code;
 final  Map<String, dynamic> _data;
@override Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}


/// Create a copy of ExtractionProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExtractionProgressCopyWith<_ExtractionProgress> get copyWith => __$ExtractionProgressCopyWithImpl<_ExtractionProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExtractionProgress&&(identical(other.code, code) || other.code == code)&&const DeepCollectionEquality().equals(other._data, _data));
}


@override
int get hashCode => Object.hash(runtimeType,code,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'ExtractionProgress(code: $code, data: $data)';
}


}

/// @nodoc
abstract mixin class _$ExtractionProgressCopyWith<$Res> implements $ExtractionProgressCopyWith<$Res> {
  factory _$ExtractionProgressCopyWith(_ExtractionProgress value, $Res Function(_ExtractionProgress) _then) = __$ExtractionProgressCopyWithImpl;
@override @useResult
$Res call({
 int code, Map<String, dynamic> data
});




}
/// @nodoc
class __$ExtractionProgressCopyWithImpl<$Res>
    implements _$ExtractionProgressCopyWith<$Res> {
  __$ExtractionProgressCopyWithImpl(this._self, this._then);

  final _ExtractionProgress _self;
  final $Res Function(_ExtractionProgress) _then;

/// Create a copy of ExtractionProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? data = null,}) {
  return _then(_ExtractionProgress(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int,data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
