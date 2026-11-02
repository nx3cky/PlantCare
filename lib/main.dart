import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app_routes.dart';
import 'core/services/analytics_service.dart';
import 'core/services/crash_reporting.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await CrashReporting.init();
  runApp(const PlantCareApp());
}

class PlantCareApp extends StatelessWidget {
  const PlantCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Care',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Стартовий маршрут '/' – AuthGate: вхід або головна за станом Firebase Auth.
      initialRoute: AppRoutes.root,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      navigatorObservers: [
        if (Firebase.apps.isNotEmpty) AnalyticsService.instance.observer,
      ],
    );
  }
}
