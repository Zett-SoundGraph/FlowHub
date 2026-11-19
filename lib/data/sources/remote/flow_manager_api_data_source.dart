import 'package:dio/dio.dart';
import 'package:flowhub/core/constants/cloud_constants.dart';
import 'package:flowhub/core/constants/network.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:injectable/injectable.dart';

/// FlowManager's device REST API (`/api/v2/rest/...`, `x-api-key` auth).
///
/// Its own [Dio], not the shared RestClient: a different base URL and auth
/// header. Every call returns the `data` object of FlowManager's
/// `{status, retCode, retMsg, data}` envelope.
abstract interface class IFlowManagerApiDataSource {
  /// `GET /api/v2/rest/device/state?storeId=`
  Future<Map<String, dynamic>> getDeviceState(String storeId);

  /// `POST /api/v2/rest/store/version/update` with `{devices:[{deviceId}]}`
  /// (no versionId: each device gets its latest build).
  Future<Map<String, dynamic>> requestUpdate(List<String> deviceIds);
}

@Singleton(as: IFlowManagerApiDataSource)
class FlowManagerApiDataSource implements IFlowManagerApiDataSource {
  FlowManagerApiDataSource()
    : _dio = Dio(
        BaseOptions(
          baseUrl: CloudConstants.apiUrl,
          connectTimeout: NetworkConstants.connectionTimeout,
          receiveTimeout: NetworkConstants.receiveTimeout,
          sendTimeout: NetworkConstants.sendTimeout,
          headers: <String, dynamic>{'x-api-key': CloudConstants.apiKey},
        ),
      );

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> getDeviceState(String storeId) => _data(
    _dio.get<Map<String, dynamic>>(
      '/api/v2/rest/device/state',
      queryParameters: <String, dynamic>{'storeId': storeId},
    ),
  );

  @override
  Future<Map<String, dynamic>> requestUpdate(List<String> deviceIds) => _data(
    _dio.post<Map<String, dynamic>>(
      '/api/v2/rest/store/version/update',
      data: <String, dynamic>{
        'devices': <Map<String, dynamic>>[
          for (final String id in deviceIds) <String, dynamic>{'deviceId': id},
        ],
      },
    ),
  );

  /// 1. Fails fast when the API URL or key is not configured.
  /// 2. Unwraps `data`; a non-success envelope or HTTP error becomes a
  ///    [BaseException.serverException] with FlowManager's message.
  Future<Map<String, dynamic>> _data(
    Future<Response<Map<String, dynamic>>> request,
  ) async {
    if (!CloudConstants.isApiConfigured) {
      throw const BaseException(
        message: 'FLOW_MANAGER_API_URL / FLOW_MANAGER_API_KEY not set',
      );
    }
    try {
      final Response<Map<String, dynamic>> response = await request;
      final Map<String, dynamic> body =
          response.data ?? <String, dynamic>{};
      final Object? data = body['data'];
      if (data is Map<String, dynamic>) return data;
      throw BaseException.serverException(
        statusCode: response.statusCode ?? -1,
        message: body['retMsg']?.toString() ?? 'Empty response',
      );
    } on DioException catch (e) {
      final Object? body = e.response?.data;
      final String message = body is Map
          ? body['retMsg']?.toString() ?? e.message ?? ''
          : e.message ?? '';
      throw BaseException.serverException(
        statusCode: e.response?.statusCode ?? -1,
        message: message,
      );
    }
  }
}
