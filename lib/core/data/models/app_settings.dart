import 'package:equatable/equatable.dart';

/// Порядок сортування каталогу рослин.
enum PlantSort {
  name('За назвою'),
  nextWatering('За наступним поливом'),
  newest('Спочатку нові');

  final String label;

  const PlantSort(this.label);
}

/// Налаштування застосунку, що зберігаються на пристрої (SharedPreferences).
class AppSettings extends Equatable {
  final bool remindersEnabled;

  /// Час щоденного нагадування, «09:00».
  final String reminderTime;
  final PlantSort plantSort;

  /// Каталог у вигляді сітки (GridView) чи списку (ListView).
  final bool plantsAsGrid;

  const AppSettings({
    this.remindersEnabled = true,
    this.reminderTime = '09:00',
    this.plantSort = PlantSort.name,
    this.plantsAsGrid = true,
  });

  AppSettings copyWith({
    bool? remindersEnabled,
    String? reminderTime,
    PlantSort? plantSort,
    bool? plantsAsGrid,
  }) {
    return AppSettings(
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      plantSort: plantSort ?? this.plantSort,
      plantsAsGrid: plantsAsGrid ?? this.plantsAsGrid,
    );
  }

  @override
  List<Object?> get props => [remindersEnabled, reminderTime, plantSort, plantsAsGrid];
}
