import 'package:dio/dio.dart';
import 'package:flowhub/core/constants/index.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/exception/errors/error_response.dart';

class CommonInterceptor extends InterceptorsWrapper {
  CommonInterceptor();

  final List<String> formDataList = [];
  final List<String> urlRequiredFullResponseData = [];

  static Dio? dio;

  @override
  Future onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // if (!EndPoint.listPathNotRequireToken.contains(options.path)) {
    //   final token = await _userLocalDataSource.getToken();
    //   options.headers['Authorization'] = 'Bearer $token';
    //   options.headers['User-Agent'] = await _userLocalDataSource.getUserAgent();
    // }

    // if (formDataList.contains(options.path)) {
    //   options.headers['contentType'] = 'multipart/form-data';
    // } else {
    //   options.headers['accept'] = 'application/json';
    //   options.headers['contentType'] = 'application/json';
    //   options.headers['x-device-id'] = await _deviceDataSource.getDeviceId();
    // }

    handler.next(options);
  }

  /// Trigger when [statusCode] = 200
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    /// Response data is not json, throw [ServerException]
    if (response.data is! Map && response.data is! List) {
      /// Throw [ServerException] and catch it in [onError]
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.unknown,
          error: ServerException(
            statusCode: response.statusCode ?? -1,
            message: 'Something went wrong! Invalid response format.',
          ),
        ),
      );
      return;
    }

    /// If `path` inside [urlRequiredFullResponseData] list, return response with full response data.
    if (urlRequiredFullResponseData.contains(response.requestOptions.path)) {
      handler.next(
        Response(
          requestOptions: response.requestOptions,
          data: response.data,
          statusCode: response.statusCode,
          statusMessage: response.statusMessage,
          headers: response.headers,
          isRedirect: response.isRedirect,
          redirects: response.redirects,
          extra: response.extra,
        ),
      );
      return;
    }

    dynamic data;
    if (response.data is Map) {
      data = (response.data as Map<String, dynamic>)['data'];
    } else if (response.data is bool) {
      data = response.data as bool;
    } else {
      data = response.data;
    }

    if (data is! Map && data is! List && data is! bool) {
      /// Throw [ServerException] and catch it in [onError]
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.unknown,
          error: ServerException(
            statusCode: response.statusCode ?? -1,
            message: 'Invalid response format!',
          ),
        ),
      );
      return;
    }

    handler.next(
      Response(
        requestOptions: response.requestOptions,
        data: data,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        headers: response.headers,
        isRedirect: response.isRedirect,
        redirects: response.redirects,
        extra: response.extra,
      ),
    );
  }

  /// Trigger when [statusCode] != 200 or throw an [Exception]
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.error is BaseException) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: DioExceptionType.unknown,
          error: err,
        ),
      );
      return;
    }

    /// Not receive response from server, throw [NetworkException]
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.badCertificate ||
        err.type == DioExceptionType.badResponse ||
        err.type == DioExceptionType.connectionError) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          error: const NetworkException(message: 'Network error occurred'),
        ),
      );
      return;
    }

    /// Continue with a response

    final statusCode = err.response!.statusCode!;

    /// Response data is not json, throw [ServerException]
    if (err.response?.data is! Map) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: DioExceptionType.unknown,
          error: ServerException(statusCode: statusCode),
        ),
      );
      return;
    }

    ErrorResponse errorResponse = ErrorResponse.fromJson(
      err.response!.data ?? {},
    );
    errorResponse = errorResponse.copyWith(
      message: errorResponse.message.toString(),
      statusCode: statusCode,
    );

    String? message = errorResponse.message;
    if (message.isEmpty) {
      message = 'An error occurred! Please try again later.';
    }

    if (statusCode == HttpCode.unauthorized) {
      message = 'Unauthorized access! Please log in again.';
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: DioExceptionType.unknown,
        error: ServerException(message: message, statusCode: statusCode),
      ),
    );
  }
}
