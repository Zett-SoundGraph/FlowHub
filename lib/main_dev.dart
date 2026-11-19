import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flowhub/core/di/di.dart';
import 'package:flowhub/core/env/env.dart';
import 'package:flowhub/core/theme/app_theme.dart';
import 'package:flowhub/core/utils/mqtt_order_audit_logger.dart';
import 'package:flowhub/data/platform/flow_updater_service.dart';

import 'presentation/screens/flowhub_screen/flowhub_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator(Env.dev());
  await MqttOrderAuditLogger.init();

  // Don't await it before runApp: if FlowUpdater is missing, startup must not
  // wait. The SDK keeps reconnecting in the background either way.
  final FlowUpdaterService updater = getIt<FlowUpdaterService>();
  unawaited(updater.connect());
  runApp(const FlowHubApp());
  // UI is up: report ready for FlowUpdater's IPC_READY health check once the
  // first frame is drawn (same timing as FlowKioskApp).
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => unawaited(updater.markReady()),
  );
}

class FlowHubApp extends StatelessWidget {
  const FlowHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      // FlowHub is a fixed-layout kiosk display, not a general reading app — the
      // device's accessibility text-size setting must not resize any text,
      // or the Figma-matched pixel layout drifts out of alignment.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: child!,
      ),
      home: const FlowHubMainScreen(),
    );
  }
}
