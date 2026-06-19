// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'base_exception.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BaseException {

 String get message;
/// Create a copy of BaseException
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BaseExceptionCopyWith<BaseException> get copyWith => _$BaseExceptionCopyWithImpl<BaseException>(this as BaseException, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BaseException&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'BaseException(message: $message)';
}


}

/// @nodoc
abstract mixin class $BaseExceptionCopyWith<$Res>  {
  factory $BaseExceptionCopyWith(BaseException value, $Res Function(BaseException) _then) = _$BaseExceptionCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$BaseExceptionCopyWithImpl<$Res>
    implements $BaseExceptionCopyWith<$Res> {
  _$BaseExceptionCopyWithImpl(this._self, this._then);

  final BaseException _self;
  final $Res Function(BaseException) _then;

/// Create a copy of BaseException
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BaseException].
extension BaseExceptionPatterns on BaseException {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BaseException value)?  $default,{TResult Function( ServerException value)?  serverException,TResult Function( NetworkException value)?  networkException,TResult Function( CommonException value)?  commonException,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BaseException() when $default != null:
return $default(_that);case ServerException() when serverException != null:
return serverException(_that);case NetworkException() when networkException != null:
return networkException(_that);case CommonException() when commonException != null:
return commonException(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BaseException value)  $default,{required TResult Function( ServerException value)  serverException,required TResult Function( NetworkException value)  networkException,required TResult Function( CommonException value)  commonException,}){
final _that = this;
switch (_that) {
case _BaseException():
return $default(_that);case ServerException():
return serverException(_that);case NetworkException():
return networkException(_that);case CommonException():
return commonException(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BaseException value)?  $default,{TResult? Function( ServerException value)?  serverException,TResult? Function( NetworkException value)?  networkException,TResult? Function( CommonException value)?  commonException,}){
final _that = this;
switch (_that) {
case _BaseException() when $default != null:
return $default(_that);case ServerException() when serverException != null:
return serverException(_that);case NetworkException() when networkException != null:
return networkException(_that);case CommonException() when commonException != null:
return commonException(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message)?  $default,{TResult Function( int statusCode,  String message,  ErrorResponse errorResponse)?  serverException,TResult Function( String message)?  networkException,TResult Function( String message,  Object? error,  StackTrace? trace)?  commonException,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BaseException() when $default != null:
return $default(_that.message);case ServerException() when serverException != null:
return serverException(_that.statusCode,_that.message,_that.errorResponse);case NetworkException() when networkException != null:
return networkException(_that.message);case CommonException() when commonException != null:
return commonException(_that.message,_that.error,_that.trace);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message)  $default,{required TResult Function( int statusCode,  String message,  ErrorResponse errorResponse)  serverException,required TResult Function( String message)  networkException,required TResult Function( String message,  Object? error,  StackTrace? trace)  commonException,}) {final _that = this;
switch (_that) {
case _BaseException():
return $default(_that.message);case ServerException():
return serverException(_that.statusCode,_that.message,_that.errorResponse);case NetworkException():
return networkException(_that.message);case CommonException():
return commonException(_that.message,_that.error,_that.trace);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message)?  $default,{TResult? Function( int statusCode,  String message,  ErrorResponse errorResponse)?  serverException,TResult? Function( String message)?  networkException,TResult? Function( String message,  Object? error,  StackTrace? trace)?  commonException,}) {final _that = this;
switch (_that) {
case _BaseException() when $default != null:
return $default(_that.message);case ServerException() when serverException != null:
return serverException(_that.statusCode,_that.message,_that.errorResponse);case NetworkException() when networkException != null:
return networkException(_that.message);case CommonException() when commonException != null:
return commonException(_that.message,_that.error,_that.trace);case _:
  return null;

}
}

}

/// @nodoc


class _BaseException implements BaseException {
  const _BaseException({this.message = ''});
  

@override@JsonKey() final  String message;

/// Create a copy of BaseException
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BaseExceptionCopyWith<_BaseException> get copyWith => __$BaseExceptionCopyWithImpl<_BaseException>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BaseException&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'BaseException(message: $message)';
}


}

/// @nodoc
abstract mixin class _$BaseExceptionCopyWith<$Res> implements $BaseExceptionCopyWith<$Res> {
  factory _$BaseExceptionCopyWith(_BaseException value, $Res Function(_BaseException) _then) = __$BaseExceptionCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class __$BaseExceptionCopyWithImpl<$Res>
    implements _$BaseExceptionCopyWith<$Res> {
  __$BaseExceptionCopyWithImpl(this._self, this._then);

  final _BaseException _self;
  final $Res Function(_BaseException) _then;

/// Create a copy of BaseException
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_BaseException(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ServerException implements BaseException {
  const ServerException({this.statusCode = -1, this.message = '', this.errorResponse = const ErrorResponse()});
  

@JsonKey() final  int statusCode;
@override@JsonKey() final  String message;
@JsonKey() final  ErrorResponse errorResponse;

/// Create a copy of BaseException
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerExceptionCopyWith<ServerException> get copyWith => _$ServerExceptionCopyWithImpl<ServerException>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerException&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.message, message) || other.message == message)&&(identical(other.errorResponse, errorResponse) || other.errorResponse == errorResponse));
}


@override
int get hashCode => Object.hash(runtimeType,statusCode,message,errorResponse);

@override
String toString() {
  return 'BaseException.serverException(statusCode: $statusCode, message: $message, errorResponse: $errorResponse)';
}


}

/// @nodoc
abstract mixin class $ServerExceptionCopyWith<$Res> implements $BaseExceptionCopyWith<$Res> {
  factory $ServerExceptionCopyWith(ServerException value, $Res Function(ServerException) _then) = _$ServerExceptionCopyWithImpl;
@override @useResult
$Res call({
 int statusCode, String message, ErrorResponse errorResponse
});


$ErrorResponseCopyWith<$Res> get errorResponse;

}
/// @nodoc
class _$ServerExceptionCopyWithImpl<$Res>
    implements $ServerExceptionCopyWith<$Res> {
  _$ServerExceptionCopyWithImpl(this._self, this._then);

  final ServerException _self;
  final $Res Function(ServerException) _then;

/// Create a copy of BaseException
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? statusCode = null,Object? message = null,Object? errorResponse = null,}) {
  return _then(ServerException(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,errorResponse: null == errorResponse ? _self.errorResponse : errorResponse // ignore: cast_nullable_to_non_nullable
as ErrorResponse,
  ));
}

/// Create a copy of BaseException
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ErrorResponseCopyWith<$Res> get errorResponse {
  
  return $ErrorResponseCopyWith<$Res>(_self.errorResponse, (value) {
    return _then(_self.copyWith(errorResponse: value));
  });
}
}

/// @nodoc


class NetworkException implements BaseException {
  const NetworkException({this.message = ''});
  

@override@JsonKey() final  String message;

/// Create a copy of BaseException
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkExceptionCopyWith<NetworkException> get copyWith => _$NetworkExceptionCopyWithImpl<NetworkException>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkException&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'BaseException.networkException(message: $message)';
}


}

/// @nodoc
abstract mixin class $NetworkExceptionCopyWith<$Res> implements $BaseExceptionCopyWith<$Res> {
  factory $NetworkExceptionCopyWith(NetworkException value, $Res Function(NetworkException) _then) = _$NetworkExceptionCopyWithImpl;
@override @useResult
$Res call({
 String message
});




}
/// @nodoc
class _$NetworkExceptionCopyWithImpl<$Res>
    implements $NetworkExceptionCopyWith<$Res> {
  _$NetworkExceptionCopyWithImpl(this._self, this._then);

  final NetworkException _self;
  final $Res Function(NetworkException) _then;

/// Create a copy of BaseException
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(NetworkException(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CommonException implements BaseException {
  const CommonException({this.message = '', this.error, this.trace});
  

@override@JsonKey() final  String message;
 final  Object? error;
 final  StackTrace? trace;

/// Create a copy of BaseException
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommonExceptionCopyWith<CommonException> get copyWith => _$CommonExceptionCopyWithImpl<CommonException>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommonException&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.trace, trace) || other.trace == trace));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(error),trace);

@override
String toString() {
  return 'BaseException.commonException(message: $message, error: $error, trace: $trace)';
}


}

/// @nodoc
abstract mixin class $CommonExceptionCopyWith<$Res> implements $BaseExceptionCopyWith<$Res> {
  factory $CommonExceptionCopyWith(CommonException value, $Res Function(CommonException) _then) = _$CommonExceptionCopyWithImpl;
@override @useResult
$Res call({
 String message, Object? error, StackTrace? trace
});




}
/// @nodoc
class _$CommonExceptionCopyWithImpl<$Res>
    implements $CommonExceptionCopyWith<$Res> {
  _$CommonExceptionCopyWithImpl(this._self, this._then);

  final CommonException _self;
  final $Res Function(CommonException) _then;

/// Create a copy of BaseException
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? error = freezed,Object? trace = freezed,}) {
  return _then(CommonException(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error ,trace: freezed == trace ? _self.trace : trace // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}


}

// dart format on
