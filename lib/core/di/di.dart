import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:flowhub/core/constants/index.dart';
import 'package:flowhub/core/di/di.config.dart';
import 'package:flowhub/core/di/service_locator.dart';
import 'package:flowhub/core/env/env.dart';
import 'package:flowhub/data/network/common_interceptor.dart';
import 'package:flowhub/data/network/rest_client.dart';
import 'package:flowhub/domain/repositories/menu_repository.dart';

export 'package:flowhub/core/di/service_locator.dart';

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> setupLocator(Env env) async {
  // Starts background subnet detection (see LocalSubnetResolver) — not
  // awaited: NetworkConstants.cayeMachineIp/mqttBrokerHost/labelPrinterIp
  // fall back to the currently-deployed site's subnet until this resolves,
  // so nothing here needs to block on it (each of those connections already
  // retries on its own and picks up the corrected value automatically).
  LocalSubnetResolver.resolve();

  // Resolves whether this build is the leader or a follower unit from its
  // own IP — must happen before anything reads NetworkConstants.mqttDeviceId
  // (MQTT doesn't connect until FlowHubCubit initializes post-runApp, but
  // resolving it this early keeps the identity settled before DI wiring).
  await FlowHubIdentity.resolve();

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

  getIt.registerSingleton<Dio>(dio);
  getIt.registerSingleton<RestClient>(RestClient(dio, baseUrl: env.apiUrl));
  getIt.registerSingleton<Env>(env);
  $initGetIt(getIt);

  // MenuRepository loads menu/option data over the network (Google Sheet
  // CSV fetches) — deliberately NOT awaited here. Unlike the old bundled
  // recipe.csv (instant local read), this can take up to several times
  // NetworkConstants' 60s timeout if the device has no route to the
  // internet, which would otherwise block the splash screen from ever
  // reaching runApp(). It loads in the background instead; the UI already
  // tolerates menu lookups returning null/empty until it finishes.
  unawaited(getIt<MenuRepository>().load());
}
