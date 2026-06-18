import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:kds/core/constants/index.dart';
import 'package:kds/core/di/di.config.dart';
import 'package:kds/core/env/env.dart';
import 'package:kds/data/network/common_interceptor.dart';
import 'package:kds/data/network/rest_client.dart';

final getIt = GetIt.asNewInstance()..allowReassignment = true;

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> setupLocator(Env env) async {
  Dio dio = Dio();
  dio.interceptors.add(CommonInterceptor());
  dio.options
    ..connectTimeout = (NetworkConstants.connectionTimeout)
    ..receiveTimeout = (NetworkConstants.receiveTimeout)
    ..sendTimeout = (NetworkConstants.sendTimeout)
    ..headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    }
    ..followRedirects = false;

  getIt.registerSingleton(() => dio);

  getIt.registerSingleton(() => RestClient(dio, baseUrl: env.apiUrl));
  $initGetIt(getIt);
}
