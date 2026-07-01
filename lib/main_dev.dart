import 'package:flutter/material.dart';
import 'package:kds/core/di/di.dart';
import 'package:kds/core/env/env.dart';
import 'package:kds/core/theme/app_theme.dart';

import 'presentation/screens/kds_screen/kds_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator(Env.dev());
  runApp(const KdsApp());
}

class KdsApp extends StatelessWidget {
  const KdsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const KdsMainScreen(),
    );
  }
}
