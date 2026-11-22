part of 'plants_bloc.dart';

sealed class PlantsEvent {
  const PlantsEvent();
}

/// Підписка на рослини й журнал поточного користувача.
final class PlantsSubscriptionRequested extends PlantsEvent {
  const PlantsSubscriptionRequested();
}

final class PlantsQueryChanged extends PlantsEvent {
  final String query;

  const PlantsQueryChanged(this.query);
}

/// Фільтр за розташуванням; null – усі.
final class PlantsLocationFilterChanged extends PlantsEvent {
  final String? location;

  const PlantsLocationFilterChanged(this.location);
}

/// Лише рослини, яким сьогодні потрібен догляд.
final class PlantsNeedsCareFilterToggled extends PlantsEvent {
  const PlantsNeedsCareFilterToggled();
}

final class PlantsSortChanged extends PlantsEvent {
  final PlantSort sort;

  const PlantsSortChanged(this.sort);
}

/// Перемикання між сіткою (GridView) і списком (ListView).
final class PlantsViewModeToggled extends PlantsEvent {
  const PlantsViewModeToggled();
}

/// Створення (порожній id) або редагування рослини.
final class PlantSaved extends PlantsEvent {
  final Plant plant;

  const PlantSaved(this.plant);
}

/// Видалення рослини разом з її журналом.
final class PlantDeleted extends PlantsEvent {
  final String plantId;

  const PlantDeleted(this.plantId);
}

/// Відкрито екран деталей рослини.
final class PlantViewed extends PlantsEvent {
  final String plantId;

  const PlantViewed(this.plantId);
}

final class PlantsRecentCleared extends PlantsEvent {
  const PlantsRecentCleared();
}
