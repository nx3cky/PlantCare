import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/data/repositories/local_garden_repository.dart';
import 'core/data/repositories/settings_repository.dart';
import 'core/services/crash_reporting.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await CrashReporting.init();
  // Локальне key-value сховище: значення завантажуються в пам'ять один раз.
  final prefs = await SharedPreferences.getInstance();

  runApp(PlantCareApp(
    authRepository: FirebaseAuthRepository(),
    gardenRepository: LocalGardenRepository(prefs),
    settingsRepository: SettingsRepository(prefs),
  ));
}
