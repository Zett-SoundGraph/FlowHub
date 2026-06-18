import 'package:flutter/material.dart';
import 'package:kds/presentation/routes/routes.dart';
import 'package:kds/presentation/theme/system_theme.dart';

class KdsApp extends StatelessWidget {
  const KdsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SystemTheme(
      themeMode: ThemeMode.light,
      child: MaterialApp.router(
        title: 'FlowHub KDS',
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
