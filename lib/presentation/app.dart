import 'package:flutter/material.dart';
import 'package:flowhub/presentation/routes/routes.dart';
import 'package:flowhub/presentation/theme/system_theme.dart';

class FlowHubApp extends StatelessWidget {
  const FlowHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SystemTheme(
      themeMode: ThemeMode.light,
      child: MaterialApp.router(
        title: 'FlowHub',
        theme: ThemeData(primarySwatch: Colors.blue),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        // localizationsDelegates: context.localizationDelegates,
        // supportedLocales: context.supportedLocales,
        // locale: context.locale,
      ),
    );
  }
}
