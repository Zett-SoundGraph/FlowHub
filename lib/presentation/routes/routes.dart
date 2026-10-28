import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flowhub/presentation/routes/route_name.dart';
import 'package:flowhub/presentation/screens/flowhub_screen/flowhub_main_screen.dart';

abstract class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: RouteName.home,
        builder: (BuildContext context, GoRouterState state) {
          return const FlowHubMainScreen();
        },
      ),
    ],
  );
}
