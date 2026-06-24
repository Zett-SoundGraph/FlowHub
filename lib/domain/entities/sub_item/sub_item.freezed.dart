// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sub_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubItem {

 String get menuName; OrderStatus get status; double get progress; List<String> get logs; bool get isExtracting; bool get isError; String? get errorCode; String get currentStage;
/// Create a copy of SubItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubItemCopyWith<SubItem> get copyWith => _$SubItemCopyWithImpl<SubItem>(this as SubItem, _$identity);

  /// Serializes this SubItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubItem&&(identical(other.menuName, menuName) || other.menuName == menuName)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&const DeepCollectionEquality().equals(other.logs, logs)&&(identical(other.isExtracting, isExtracting) || other.isExtracting == isExtracting)&&(identical(other.isError, isError) || other.isError == isError)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.currentStage, currentStage) || other.currentStage == currentStage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,menuName,status,progress,const DeepCollectionEquality().hash(logs),isExtracting,isError,errorCode,currentStage);

@override
String toString() {
  return 'SubItem(menuName: $menuName, status: $status, progress: $progress, logs: $logs, isExtracting: $isExtracting, isError: $isError, errorCode: $errorCode, currentStage: $currentStage)';
}


}

/// @nodoc
abstract mixin class $SubItemCopyWith<$Res>  {
  factory $SubItemCopyWith(SubItem value, $Res Function(SubItem) _then) = _$SubItemCopyWithImpl;
@useResult
$Res call({
 String menuName, OrderStatus status, double progress, List<String> logs, bool isExtracting, bool isError, String? errorCode, String currentStage
});




}
/// @nodoc
class _$SubItemCopyWithImpl<$Res>
    implements $SubItemCopyWith<$Res> {
  _$SubItemCopyWithImpl(this._self, this._then);

  final SubItem _self;
  final $Res Function(SubItem) _then;

/// Create a copy of SubItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? menuName = null,Object? status = null,Object? progress = null,Object? logs = null,Object? isExtracting = null,Object? isError = null,Object? errorCode = freezed,Object? currentStage = null,}) {
  return _then(_self.copyWith(
menuName: null == menuName ? _self.menuName : menuName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as List<String>,isExtracting: null == isExtracting ? _self.isExtracting : isExtracting // ignore: cast_nullable_to_non_nullable
as bool,isError: null == isError ? _self.isError : isError // ignore: cast_nullable_to_non_nullable
as bool,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,currentStage: null == currentStage ? _self.currentStage : currentStage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SubItem].
extension SubItemPatterns on SubItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubItem value)  $default,){
final _that = this;
switch (_that) {
case _SubItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubItem value)?  $default,){
final _that = this;
switch (_that) {
case _SubItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String menuName,  OrderStatus status,  double progress,  List<String> logs,  bool isExtracting,  bool isError,  String? errorCode,  String currentStage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubItem() when $default != null:
return $default(_that.menuName,_that.status,_that.progress,_that.logs,_that.isExtracting,_that.isError,_that.errorCode,_that.currentStage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String menuName,  OrderStatus status,  double progress,  List<String> logs,  bool isExtracting,  bool isError,  String? errorCode,  String currentStage)  $default,) {final _that = this;
switch (_that) {
case _SubItem():
return $default(_that.menuName,_that.status,_that.progress,_that.logs,_that.isExtracting,_that.isError,_that.errorCode,_that.currentStage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String menuName,  OrderStatus status,  double progress,  List<String> logs,  bool isExtracting,  bool isError,  String? errorCode,  String currentStage)?  $default,) {final _that = this;
switch (_that) {
case _SubItem() when $default != null:
return $default(_that.menuName,_that.status,_that.progress,_that.logs,_that.isExtracting,_that.isError,_that.errorCode,_that.currentStage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubItem extends SubItem {
  const _SubItem({this.menuName = '', this.status = OrderStatus.pending, this.progress = 0.0, final  List<String> logs = const [], this.isExtracting = false, this.isError = false, this.errorCode, this.currentStage = 'Pending'}): _logs = logs,super._();
  factory _SubItem.fromJson(Map<String, dynamic> json) => _$SubItemFromJson(json);

@override@JsonKey() final  String menuName;
@override@JsonKey() final  OrderStatus status;
@override@JsonKey() final  double progress;
 final  List<String> _logs;
@override@JsonKey() List<String> get logs {
  if (_logs is EqualUnmodifiableListView) return _logs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_logs);
}

@override@JsonKey() final  bool isExtracting;
@override@JsonKey() final  bool isError;
@override final  String? errorCode;
@override@JsonKey() final  String currentStage;

/// Create a copy of SubItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubItemCopyWith<_SubItem> get copyWith => __$SubItemCopyWithImpl<_SubItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubItem&&(identical(other.menuName, menuName) || other.menuName == menuName)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&const DeepCollectionEquality().equals(other._logs, _logs)&&(identical(other.isExtracting, isExtracting) || other.isExtracting == isExtracting)&&(identical(other.isError, isError) || other.isError == isError)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.currentStage, currentStage) || other.currentStage == currentStage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,menuName,status,progress,const DeepCollectionEquality().hash(_logs),isExtracting,isError,errorCode,currentStage);

@override
String toString() {
  return 'SubItem(menuName: $menuName, status: $status, progress: $progress, logs: $logs, isExtracting: $isExtracting, isError: $isError, errorCode: $errorCode, currentStage: $currentStage)';
}


}

/// @nodoc
abstract mixin class _$SubItemCopyWith<$Res> implements $SubItemCopyWith<$Res> {
  factory _$SubItemCopyWith(_SubItem value, $Res Function(_SubItem) _then) = __$SubItemCopyWithImpl;
@override @useResult
$Res call({
 String menuName, OrderStatus status, double progress, List<String> logs, bool isExtracting, bool isError, String? errorCode, String currentStage
});




}
/// @nodoc
class __$SubItemCopyWithImpl<$Res>
    implements _$SubItemCopyWith<$Res> {
  __$SubItemCopyWithImpl(this._self, this._then);

  final _SubItem _self;
  final $Res Function(_SubItem) _then;

/// Create a copy of SubItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? menuName = null,Object? status = null,Object? progress = null,Object? logs = null,Object? isExtracting = null,Object? isError = null,Object? errorCode = freezed,Object? currentStage = null,}) {
  return _then(_SubItem(
menuName: null == menuName ? _self.menuName : menuName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,logs: null == logs ? _self._logs : logs // ignore: cast_nullable_to_non_nullable
as List<String>,isExtracting: null == isExtracting ? _self.isExtracting : isExtracting // ignore: cast_nullable_to_non_nullable
as bool,isError: null == isError ? _self.isError : isError // ignore: cast_nullable_to_non_nullable
as bool,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,currentStage: null == currentStage ? _self.currentStage : currentStage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
