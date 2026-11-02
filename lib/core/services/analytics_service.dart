import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Обгортка над Firebase Analytics: рекомендовані події (login, sign_up),
/// власні події застосунку та перегляди екранів.
/// Помилки аналітики не повинні ламати основний сценарій, тому лише логуються.
class AnalyticsService {
  AnalyticsService._();
  static final instance = AnalyticsService._();

  FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  /// Без ініціалізованого Firebase (наприклад, у віджет-тестах) події ігноруються.
  bool get _enabled => Firebase.apps.isNotEmpty;

  /// Логує переходи між маршрутами Navigator (screen_view).
  late final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logLogin(String method) =>
      _safe(() => _analytics.logLogin(loginMethod: method));

  Future<void> logSignUp(String method) =>
      _safe(() => _analytics.logSignUp(signUpMethod: method));

  Future<void> logScreenView(String screenName) =>
      _safe(() => _analytics.logScreenView(screenName: screenName));

  Future<void> logEvent(String name, [Map<String, Object>? parameters]) =>
      _safe(() => _analytics.logEvent(name: name, parameters: parameters));

  Future<void> _safe(Future<void> Function() action) async {
    if (!_enabled) return;
    try {
      await action();
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }
}
