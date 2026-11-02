import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Підключення Firebase Crashlytics. Плагін підтримує Android, iOS і macOS,
/// тому у веб-версії звіти не надсилаються, а помилки лише виводяться в консоль.
abstract final class CrashReporting {
  static bool get isSupported => !kIsWeb;

  static Future<void> init() async {
    if (!isSupported) return;
    final crashlytics = FirebaseCrashlytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(true);

    // Помилки, перехоплені фреймворком Flutter (build, layout, paint).
    FlutterError.onError = crashlytics.recordFlutterFatalError;

    // Необроблені асинхронні помилки кореневого ізоляту поза Flutter.
    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Ідентифікатор користувача у звітах (uid Firebase Auth, без email і паролів).
  static Future<void> setUser(String? uid) async {
    if (!isSupported) return;
    await FirebaseCrashlytics.instance.setUserIdentifier(uid ?? '');
  }

  /// Нефатальна помилка: застосунок обробив її й продовжує роботу.
  static Future<void> recordError(Object error, StackTrace stack, {String? reason}) async {
    if (!isSupported) {
      debugPrint('Non-fatal: $error');
      return;
    }
    await FirebaseCrashlytics.instance.recordError(error, stack, reason: reason, fatal: false);
  }

  /// Тестова помилка для перевірки інтеграції (кнопка на екрані «Профіль»).
  static Future<void> sendTestError() async {
    if (isSupported) {
      FirebaseCrashlytics.instance.log('Test error button pressed on profile screen');
    }
    try {
      throw StateError('PlantCare: тестова помилка для Crashlytics');
    } catch (error, stack) {
      await recordError(error, stack, reason: 'Перевірка інтеграції Crashlytics');
    }
  }
}
