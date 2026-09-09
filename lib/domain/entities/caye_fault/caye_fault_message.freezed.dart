// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'caye_fault_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CayeFaultMessage {

 String get eventId; int get version; List<CayeFaultEntry> get errors;
/// Create a copy of CayeFaultMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CayeFaultMessageCopyWith<CayeFaultMessage> get copyWith => _$CayeFaultMessageCopyWithImpl<CayeFaultMessage>(this as CayeFaultMessage, _$identity);

  /// Serializes this CayeFaultMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CayeFaultMessage&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.errors, errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,version,const DeepCollectionEquality().hash(errors));

@override
String toString() {
  return 'CayeFaultMessage(eventId: $eventId, version: $version, errors: $errors)';
}


}

/// @nodoc
abstract mixin class $CayeFaultMessageCopyWith<$Res>  {
  factory $CayeFaultMessageCopyWith(CayeFaultMessage value, $Res Function(CayeFaultMessage) _then) = _$CayeFaultMessageCopyWithImpl;
@useResult
$Res call({
 String eventId, int version, List<CayeFaultEntry> errors
});




}
/// @nodoc
class _$CayeFaultMessageCopyWithImpl<$Res>
    implements $CayeFaultMessageCopyWith<$Res> {
  _$CayeFaultMessageCopyWithImpl(this._self, this._then);

  final CayeFaultMessage _self;
  final $Res Function(CayeFaultMessage) _then;

/// Create a copy of CayeFaultMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventId = null,Object? version = null,Object? errors = null,}) {
  return _then(_self.copyWith(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<CayeFaultEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [CayeFaultMessage].
extension CayeFaultMessagePatterns on CayeFaultMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CayeFaultMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CayeFaultMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CayeFaultMessage value)  $default,){
final _that = this;
switch (_that) {
case _CayeFaultMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CayeFaultMessage value)?  $default,){
final _that = this;
switch (_that) {
case _CayeFaultMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String eventId,  int version,  List<CayeFaultEntry> errors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CayeFaultMessage() when $default != null:
return $default(_that.eventId,_that.version,_that.errors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String eventId,  int version,  List<CayeFaultEntry> errors)  $default,) {final _that = this;
switch (_that) {
case _CayeFaultMessage():
return $default(_that.eventId,_that.version,_that.errors);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String eventId,  int version,  List<CayeFaultEntry> errors)?  $default,) {final _that = this;
switch (_that) {
case _CayeFaultMessage() when $default != null:
return $default(_that.eventId,_that.version,_that.errors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CayeFaultMessage implements CayeFaultMessage {
  const _CayeFaultMessage({this.eventId = '', this.version = 0, final  List<CayeFaultEntry> errors = const []}): _errors = errors;
  factory _CayeFaultMessage.fromJson(Map<String, dynamic> json) => _$CayeFaultMessageFromJson(json);

@override@JsonKey() final  String eventId;
@override@JsonKey() final  int version;
 final  List<CayeFaultEntry> _errors;
@override@JsonKey() List<CayeFaultEntry> get errors {
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_errors);
}


/// Create a copy of CayeFaultMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CayeFaultMessageCopyWith<_CayeFaultMessage> get copyWith => __$CayeFaultMessageCopyWithImpl<_CayeFaultMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CayeFaultMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CayeFaultMessage&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other._errors, _errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventId,version,const DeepCollectionEquality().hash(_errors));

@override
String toString() {
  return 'CayeFaultMessage(eventId: $eventId, version: $version, errors: $errors)';
}


}

/// @nodoc
abstract mixin class _$CayeFaultMessageCopyWith<$Res> implements $CayeFaultMessageCopyWith<$Res> {
  factory _$CayeFaultMessageCopyWith(_CayeFaultMessage value, $Res Function(_CayeFaultMessage) _then) = __$CayeFaultMessageCopyWithImpl;
@override @useResult
$Res call({
 String eventId, int version, List<CayeFaultEntry> errors
});




}
/// @nodoc
class __$CayeFaultMessageCopyWithImpl<$Res>
    implements _$CayeFaultMessageCopyWith<$Res> {
  __$CayeFaultMessageCopyWithImpl(this._self, this._then);

  final _CayeFaultMessage _self;
  final $Res Function(_CayeFaultMessage) _then;

/// Create a copy of CayeFaultMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventId = null,Object? version = null,Object? errors = null,}) {
  return _then(_CayeFaultMessage(
eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<CayeFaultEntry>,
  ));
}


}


/// @nodoc
mixin _$CayeFaultEntry {

 String get code; int get status; String get summary;
/// Create a copy of CayeFaultEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CayeFaultEntryCopyWith<CayeFaultEntry> get copyWith => _$CayeFaultEntryCopyWithImpl<CayeFaultEntry>(this as CayeFaultEntry, _$identity);

  /// Serializes this CayeFaultEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CayeFaultEntry&&(identical(other.code, code) || other.code == code)&&(identical(other.status, status) || other.status == status)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,status,summary);

@override
String toString() {
  return 'CayeFaultEntry(code: $code, status: $status, summary: $summary)';
}


}

/// @nodoc
abstract mixin class $CayeFaultEntryCopyWith<$Res>  {
  factory $CayeFaultEntryCopyWith(CayeFaultEntry value, $Res Function(CayeFaultEntry) _then) = _$CayeFaultEntryCopyWithImpl;
@useResult
$Res call({
 String code, int status, String summary
});




}
/// @nodoc
class _$CayeFaultEntryCopyWithImpl<$Res>
    implements $CayeFaultEntryCopyWith<$Res> {
  _$CayeFaultEntryCopyWithImpl(this._self, this._then);

  final CayeFaultEntry _self;
  final $Res Function(CayeFaultEntry) _then;

/// Create a copy of CayeFaultEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? status = null,Object? summary = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CayeFaultEntry].
extension CayeFaultEntryPatterns on CayeFaultEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CayeFaultEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CayeFaultEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CayeFaultEntry value)  $default,){
final _that = this;
switch (_that) {
case _CayeFaultEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CayeFaultEntry value)?  $default,){
final _that = this;
switch (_that) {
case _CayeFaultEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  int status,  String summary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CayeFaultEntry() when $default != null:
return $default(_that.code,_that.status,_that.summary);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  int status,  String summary)  $default,) {final _that = this;
switch (_that) {
case _CayeFaultEntry():
return $default(_that.code,_that.status,_that.summary);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  int status,  String summary)?  $default,) {final _that = this;
switch (_that) {
case _CayeFaultEntry() when $default != null:
return $default(_that.code,_that.status,_that.summary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CayeFaultEntry implements CayeFaultEntry {
  const _CayeFaultEntry({this.code = '', this.status = 0, this.summary = ''});
  factory _CayeFaultEntry.fromJson(Map<String, dynamic> json) => _$CayeFaultEntryFromJson(json);

@override@JsonKey() final  String code;
@override@JsonKey() final  int status;
@override@JsonKey() final  String summary;

/// Create a copy of CayeFaultEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CayeFaultEntryCopyWith<_CayeFaultEntry> get copyWith => __$CayeFaultEntryCopyWithImpl<_CayeFaultEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CayeFaultEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CayeFaultEntry&&(identical(other.code, code) || other.code == code)&&(identical(other.status, status) || other.status == status)&&(identical(other.summary, summary) || other.summary == summary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,status,summary);

@override
String toString() {
  return 'CayeFaultEntry(code: $code, status: $status, summary: $summary)';
}


}

/// @nodoc
abstract mixin class _$CayeFaultEntryCopyWith<$Res> implements $CayeFaultEntryCopyWith<$Res> {
  factory _$CayeFaultEntryCopyWith(_CayeFaultEntry value, $Res Function(_CayeFaultEntry) _then) = __$CayeFaultEntryCopyWithImpl;
@override @useResult
$Res call({
 String code, int status, String summary
});




}
/// @nodoc
class __$CayeFaultEntryCopyWithImpl<$Res>
    implements _$CayeFaultEntryCopyWith<$Res> {
  __$CayeFaultEntryCopyWithImpl(this._self, this._then);

  final _CayeFaultEntry _self;
  final $Res Function(_CayeFaultEntry) _then;

/// Create a copy of CayeFaultEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? status = null,Object? summary = null,}) {
  return _then(_CayeFaultEntry(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
