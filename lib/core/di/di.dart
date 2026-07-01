import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:kds/core/constants/index.dart';
import 'package:kds/core/di/di.config.dart';
import 'package:kds/core/di/service_locator.dart';
import 'package:kds/core/env/env.dart';
import 'package:kds/data/network/common_interceptor.dart';
import 'package:kds/data/network/rest_client.dart';
import 'package:kds/domain/repositories/recipe_repository.dart';

export 'package:kds/core/di/service_locator.dart';

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

  // RecipeRepository is a singleton — load CSV data during DI initialization.
  await getIt<RecipeRepository>().load();
}
