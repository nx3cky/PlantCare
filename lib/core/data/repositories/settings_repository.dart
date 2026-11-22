import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

/// Налаштування застосунку та «нещодавно переглянуті» рослини
/// у key-value сховищі SharedPreferences: лише прості типи (bool, String,
/// `List<String>`), які мають пережити перезапуск застосунку.
class SettingsRepository {
  static const _remindersKey = 'settings.reminders_enabled';
  static const _reminderTimeKey = 'settings.reminder_time';
  static const _plantSortKey = 'settings.plant_sort';
  static const _plantsAsGridKey = 'settings.plants_as_grid';
  static String _recentKey(String userId) => 'recent_plants.$userId';

  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  /// Читання з кешу SharedPreferences синхронне – дані вже завантажені
  /// під час SharedPreferences.getInstance() у main().
  AppSettings load() {
    const defaults = AppSettings();
    final sort = _prefs.getString(_plantSortKey);
    return AppSettings(
      remindersEnabled: _prefs.getBool(_remindersKey) ?? defaults.remindersEnabled,
      reminderTime: _prefs.getString(_reminderTimeKey) ?? defaults.reminderTime,
      plantSort: PlantSort.values.asNameMap()[sort] ?? defaults.plantSort,
      plantsAsGrid: _prefs.getBool(_plantsAsGridKey) ?? defaults.plantsAsGrid,
    );
  }

  Future<void> save(AppSettings settings) async {
    await _prefs.setBool(_remindersKey, settings.remindersEnabled);
    await _prefs.setString(_reminderTimeKey, settings.reminderTime);
    await _prefs.setString(_plantSortKey, settings.plantSort.name);
    await _prefs.setBool(_plantsAsGridKey, settings.plantsAsGrid);
  }

  /// Ідентифікатори нещодавно переглянутих рослин користувача (новіші – першими).
  List<String> recentPlants(String userId) => _prefs.getStringList(_recentKey(userId)) ?? const [];

  Future<void> saveRecentPlants(String userId, List<String> ids) =>
      _prefs.setStringList(_recentKey(userId), ids);
}
