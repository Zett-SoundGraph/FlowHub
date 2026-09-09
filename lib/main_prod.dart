import 'package:flutter/material.dart';
import 'package:flowhub/core/di/di.dart';
import 'package:flowhub/core/env/env.dart';
import 'package:flowhub/core/theme/app_theme.dart';

import 'presentation/screens/kds_screen/kds_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator(Env.prod());
  runApp(const KdsApp());
}

class KdsApp extends StatelessWidget {
  const KdsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      // KDS is a fixed-layout kiosk display, not a general reading app — the
      // device's accessibility text-size setting must not resize any text,
      // or the Figma-matched pixel layout drifts out of alignment.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: child!,
      ),
      home: const KdsMainScreen(),
    );
  }
}
