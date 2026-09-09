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

 String get menuName; OrderStatus get status; double get progress; List<String> get logs; bool get isExtracting; bool get isError; String? get errorCode; String get currentStage;// Real per-order customer selections, from a real kiosk order — e.g.
// 'ICED'/'HOT', 'MD'/'LG', and the exact options+quantities picked.
// Empty for orders with no real data yet (e.g. the dev test-order
// button), in which case the UI falls back to the menu's static
// default-recipe resolution instead.
 String get skuNo; String get temp; String get size; List<SelectedOption> get selectedOptions;// Estimated-time gauge phase tracking (see GetRecipeTimingUseCase) — ALL
// production types use this same estimated-duration engine, not real
// hardware telemetry (Caye's own 0x24 packets only carry meaningful
// values for straight espresso, so they're display-text-only now — see
// _applyProgressToSubItem). The leader's periodic tick interpolates
// `progress` between phaseStartProgress and phaseTargetProgress over
// phaseDurationSeconds: the Nudof phase starts at label-DETACH (no real
// signal exists at all for it), the Caye phase starts at Caye's real
// 0x22 status=1 signal, and both hold just below their target until a
// real signal (Caye 0x22 status=3, or the QR complete scan for the
// final 1.0) snaps the value exactly. Null phaseStartedAt means no
// phase is currently active (e.g. still Pending, or already finalized).
 DateTime? get phaseStartedAt; double get phaseStartProgress; double get phaseTargetProgress; int get phaseDurationSeconds;// Bottom-bar-message-worthy production event — see ProductionStage.
 ProductionStage get stage;
/// Create a copy of SubItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubItemCopyWith<SubItem> get copyWith => _$SubItemCopyWithImpl<SubItem>(this as SubItem, _$identity);

  /// Serializes this SubItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubItem&&(identical(other.menuName, menuName) || other.menuName == menuName)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&const DeepCollectionEquality().equals(other.logs, logs)&&(identical(other.isExtracting, isExtracting) || other.isExtracting == isExtracting)&&(identical(other.isError, isError) || other.isError == isError)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.currentStage, currentStage) || other.currentStage == currentStage)&&(identical(other.skuNo, skuNo) || other.skuNo == skuNo)&&(identical(other.temp, temp) || other.temp == temp)&&(identical(other.size, size) || other.size == size)&&const DeepCollectionEquality().equals(other.selectedOptions, selectedOptions)&&(identical(other.phaseStartedAt, phaseStartedAt) || other.phaseStartedAt == phaseStartedAt)&&(identical(other.phaseStartProgress, phaseStartProgress) || other.phaseStartProgress == phaseStartProgress)&&(identical(other.phaseTargetProgress, phaseTargetProgress) || other.phaseTargetProgress == phaseTargetProgress)&&(identical(other.phaseDurationSeconds, phaseDurationSeconds) || other.phaseDurationSeconds == phaseDurationSeconds)&&(identical(other.stage, stage) || other.stage == stage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,menuName,status,progress,const DeepCollectionEquality().hash(logs),isExtracting,isError,errorCode,currentStage,skuNo,temp,size,const DeepCollectionEquality().hash(selectedOptions),phaseStartedAt,phaseStartProgress,phaseTargetProgress,phaseDurationSeconds,stage);

@override
String toString() {
  return 'SubItem(menuName: $menuName, status: $status, progress: $progress, logs: $logs, isExtracting: $isExtracting, isError: $isError, errorCode: $errorCode, currentStage: $currentStage, skuNo: $skuNo, temp: $temp, size: $size, selectedOptions: $selectedOptions, phaseStartedAt: $phaseStartedAt, phaseStartProgress: $phaseStartProgress, phaseTargetProgress: $phaseTargetProgress, phaseDurationSeconds: $phaseDurationSeconds, stage: $stage)';
}


}

/// @nodoc
abstract mixin class $SubItemCopyWith<$Res>  {
  factory $SubItemCopyWith(SubItem value, $Res Function(SubItem) _then) = _$SubItemCopyWithImpl;
@useResult
$Res call({
 String menuName, OrderStatus status, double progress, List<String> logs, bool isExtracting, bool isError, String? errorCode, String currentStage, String skuNo, String temp, String size, List<SelectedOption> selectedOptions, DateTime? phaseStartedAt, double phaseStartProgress, double phaseTargetProgress, int phaseDurationSeconds, ProductionStage stage
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
@pragma('vm:prefer-inline') @override $Res call({Object? menuName = null,Object? status = null,Object? progress = null,Object? logs = null,Object? isExtracting = null,Object? isError = null,Object? errorCode = freezed,Object? currentStage = null,Object? skuNo = null,Object? temp = null,Object? size = null,Object? selectedOptions = null,Object? phaseStartedAt = freezed,Object? phaseStartProgress = null,Object? phaseTargetProgress = null,Object? phaseDurationSeconds = null,Object? stage = null,}) {
  return _then(_self.copyWith(
menuName: null == menuName ? _self.menuName : menuName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as List<String>,isExtracting: null == isExtracting ? _self.isExtracting : isExtracting // ignore: cast_nullable_to_non_nullable
as bool,isError: null == isError ? _self.isError : isError // ignore: cast_nullable_to_non_nullable
as bool,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,currentStage: null == currentStage ? _self.currentStage : currentStage // ignore: cast_nullable_to_non_nullable
as String,skuNo: null == skuNo ? _self.skuNo : skuNo // ignore: cast_nullable_to_non_nullable
as String,temp: null == temp ? _self.temp : temp // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,selectedOptions: null == selectedOptions ? _self.selectedOptions : selectedOptions // ignore: cast_nullable_to_non_nullable
as List<SelectedOption>,phaseStartedAt: freezed == phaseStartedAt ? _self.phaseStartedAt : phaseStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,phaseStartProgress: null == phaseStartProgress ? _self.phaseStartProgress : phaseStartProgress // ignore: cast_nullable_to_non_nullable
as double,phaseTargetProgress: null == phaseTargetProgress ? _self.phaseTargetProgress : phaseTargetProgress // ignore: cast_nullable_to_non_nullable
as double,phaseDurationSeconds: null == phaseDurationSeconds ? _self.phaseDurationSeconds : phaseDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as ProductionStage,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String menuName,  OrderStatus status,  double progress,  List<String> logs,  bool isExtracting,  bool isError,  String? errorCode,  String currentStage,  String skuNo,  String temp,  String size,  List<SelectedOption> selectedOptions,  DateTime? phaseStartedAt,  double phaseStartProgress,  double phaseTargetProgress,  int phaseDurationSeconds,  ProductionStage stage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubItem() when $default != null:
return $default(_that.menuName,_that.status,_that.progress,_that.logs,_that.isExtracting,_that.isError,_that.errorCode,_that.currentStage,_that.skuNo,_that.temp,_that.size,_that.selectedOptions,_that.phaseStartedAt,_that.phaseStartProgress,_that.phaseTargetProgress,_that.phaseDurationSeconds,_that.stage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String menuName,  OrderStatus status,  double progress,  List<String> logs,  bool isExtracting,  bool isError,  String? errorCode,  String currentStage,  String skuNo,  String temp,  String size,  List<SelectedOption> selectedOptions,  DateTime? phaseStartedAt,  double phaseStartProgress,  double phaseTargetProgress,  int phaseDurationSeconds,  ProductionStage stage)  $default,) {final _that = this;
switch (_that) {
case _SubItem():
return $default(_that.menuName,_that.status,_that.progress,_that.logs,_that.isExtracting,_that.isError,_that.errorCode,_that.currentStage,_that.skuNo,_that.temp,_that.size,_that.selectedOptions,_that.phaseStartedAt,_that.phaseStartProgress,_that.phaseTargetProgress,_that.phaseDurationSeconds,_that.stage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String menuName,  OrderStatus status,  double progress,  List<String> logs,  bool isExtracting,  bool isError,  String? errorCode,  String currentStage,  String skuNo,  String temp,  String size,  List<SelectedOption> selectedOptions,  DateTime? phaseStartedAt,  double phaseStartProgress,  double phaseTargetProgress,  int phaseDurationSeconds,  ProductionStage stage)?  $default,) {final _that = this;
switch (_that) {
case _SubItem() when $default != null:
return $default(_that.menuName,_that.status,_that.progress,_that.logs,_that.isExtracting,_that.isError,_that.errorCode,_that.currentStage,_that.skuNo,_that.temp,_that.size,_that.selectedOptions,_that.phaseStartedAt,_that.phaseStartProgress,_that.phaseTargetProgress,_that.phaseDurationSeconds,_that.stage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubItem extends SubItem {
  const _SubItem({this.menuName = '', this.status = OrderStatus.pending, this.progress = 0.0, final  List<String> logs = const [], this.isExtracting = false, this.isError = false, this.errorCode, this.currentStage = 'Pending', this.skuNo = '', this.temp = '', this.size = '', final  List<SelectedOption> selectedOptions = const [], this.phaseStartedAt, this.phaseStartProgress = 0.0, this.phaseTargetProgress = 0.0, this.phaseDurationSeconds = 0, this.stage = ProductionStage.none}): _logs = logs,_selectedOptions = selectedOptions,super._();
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
// Real per-order customer selections, from a real kiosk order — e.g.
// 'ICED'/'HOT', 'MD'/'LG', and the exact options+quantities picked.
// Empty for orders with no real data yet (e.g. the dev test-order
// button), in which case the UI falls back to the menu's static
// default-recipe resolution instead.
@override@JsonKey() final  String skuNo;
@override@JsonKey() final  String temp;
@override@JsonKey() final  String size;
 final  List<SelectedOption> _selectedOptions;
@override@JsonKey() List<SelectedOption> get selectedOptions {
  if (_selectedOptions is EqualUnmodifiableListView) return _selectedOptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedOptions);
}

// Estimated-time gauge phase tracking (see GetRecipeTimingUseCase) — ALL
// production types use this same estimated-duration engine, not real
// hardware telemetry (Caye's own 0x24 packets only carry meaningful
// values for straight espresso, so they're display-text-only now — see
// _applyProgressToSubItem). The leader's periodic tick interpolates
// `progress` between phaseStartProgress and phaseTargetProgress over
// phaseDurationSeconds: the Nudof phase starts at label-DETACH (no real
// signal exists at all for it), the Caye phase starts at Caye's real
// 0x22 status=1 signal, and both hold just below their target until a
// real signal (Caye 0x22 status=3, or the QR complete scan for the
// final 1.0) snaps the value exactly. Null phaseStartedAt means no
// phase is currently active (e.g. still Pending, or already finalized).
@override final  DateTime? phaseStartedAt;
@override@JsonKey() final  double phaseStartProgress;
@override@JsonKey() final  double phaseTargetProgress;
@override@JsonKey() final  int phaseDurationSeconds;
// Bottom-bar-message-worthy production event — see ProductionStage.
@override@JsonKey() final  ProductionStage stage;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubItem&&(identical(other.menuName, menuName) || other.menuName == menuName)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&const DeepCollectionEquality().equals(other._logs, _logs)&&(identical(other.isExtracting, isExtracting) || other.isExtracting == isExtracting)&&(identical(other.isError, isError) || other.isError == isError)&&(identical(other.errorCode, errorCode) || other.errorCode == errorCode)&&(identical(other.currentStage, currentStage) || other.currentStage == currentStage)&&(identical(other.skuNo, skuNo) || other.skuNo == skuNo)&&(identical(other.temp, temp) || other.temp == temp)&&(identical(other.size, size) || other.size == size)&&const DeepCollectionEquality().equals(other._selectedOptions, _selectedOptions)&&(identical(other.phaseStartedAt, phaseStartedAt) || other.phaseStartedAt == phaseStartedAt)&&(identical(other.phaseStartProgress, phaseStartProgress) || other.phaseStartProgress == phaseStartProgress)&&(identical(other.phaseTargetProgress, phaseTargetProgress) || other.phaseTargetProgress == phaseTargetProgress)&&(identical(other.phaseDurationSeconds, phaseDurationSeconds) || other.phaseDurationSeconds == phaseDurationSeconds)&&(identical(other.stage, stage) || other.stage == stage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,menuName,status,progress,const DeepCollectionEquality().hash(_logs),isExtracting,isError,errorCode,currentStage,skuNo,temp,size,const DeepCollectionEquality().hash(_selectedOptions),phaseStartedAt,phaseStartProgress,phaseTargetProgress,phaseDurationSeconds,stage);

@override
String toString() {
  return 'SubItem(menuName: $menuName, status: $status, progress: $progress, logs: $logs, isExtracting: $isExtracting, isError: $isError, errorCode: $errorCode, currentStage: $currentStage, skuNo: $skuNo, temp: $temp, size: $size, selectedOptions: $selectedOptions, phaseStartedAt: $phaseStartedAt, phaseStartProgress: $phaseStartProgress, phaseTargetProgress: $phaseTargetProgress, phaseDurationSeconds: $phaseDurationSeconds, stage: $stage)';
}


}

/// @nodoc
abstract mixin class _$SubItemCopyWith<$Res> implements $SubItemCopyWith<$Res> {
  factory _$SubItemCopyWith(_SubItem value, $Res Function(_SubItem) _then) = __$SubItemCopyWithImpl;
@override @useResult
$Res call({
 String menuName, OrderStatus status, double progress, List<String> logs, bool isExtracting, bool isError, String? errorCode, String currentStage, String skuNo, String temp, String size, List<SelectedOption> selectedOptions, DateTime? phaseStartedAt, double phaseStartProgress, double phaseTargetProgress, int phaseDurationSeconds, ProductionStage stage
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
@override @pragma('vm:prefer-inline') $Res call({Object? menuName = null,Object? status = null,Object? progress = null,Object? logs = null,Object? isExtracting = null,Object? isError = null,Object? errorCode = freezed,Object? currentStage = null,Object? skuNo = null,Object? temp = null,Object? size = null,Object? selectedOptions = null,Object? phaseStartedAt = freezed,Object? phaseStartProgress = null,Object? phaseTargetProgress = null,Object? phaseDurationSeconds = null,Object? stage = null,}) {
  return _then(_SubItem(
menuName: null == menuName ? _self.menuName : menuName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,logs: null == logs ? _self._logs : logs // ignore: cast_nullable_to_non_nullable
as List<String>,isExtracting: null == isExtracting ? _self.isExtracting : isExtracting // ignore: cast_nullable_to_non_nullable
as bool,isError: null == isError ? _self.isError : isError // ignore: cast_nullable_to_non_nullable
as bool,errorCode: freezed == errorCode ? _self.errorCode : errorCode // ignore: cast_nullable_to_non_nullable
as String?,currentStage: null == currentStage ? _self.currentStage : currentStage // ignore: cast_nullable_to_non_nullable
as String,skuNo: null == skuNo ? _self.skuNo : skuNo // ignore: cast_nullable_to_non_nullable
as String,temp: null == temp ? _self.temp : temp // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,selectedOptions: null == selectedOptions ? _self._selectedOptions : selectedOptions // ignore: cast_nullable_to_non_nullable
as List<SelectedOption>,phaseStartedAt: freezed == phaseStartedAt ? _self.phaseStartedAt : phaseStartedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,phaseStartProgress: null == phaseStartProgress ? _self.phaseStartProgress : phaseStartProgress // ignore: cast_nullable_to_non_nullable
as double,phaseTargetProgress: null == phaseTargetProgress ? _self.phaseTargetProgress : phaseTargetProgress // ignore: cast_nullable_to_non_nullable
as double,phaseDurationSeconds: null == phaseDurationSeconds ? _self.phaseDurationSeconds : phaseDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as ProductionStage,
  ));
}


}

// dart format on
