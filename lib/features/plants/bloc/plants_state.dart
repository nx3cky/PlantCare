part of 'plants_bloc.dart';

enum PlantsStatus { loading, ready, failure }

final class PlantsState extends Equatable {
  final PlantsStatus status;
  final String? userId;
  final List<Plant> plants;
  final List<CareEntry> entries;
  final String query;
  final String? location;
  final bool onlyNeedsCare;
  final PlantSort sort;
  final bool asGrid;
  final List<String> recentIds;

  /// Дата, відносно якої рахуються терміни догляду.
  final DateTime today;
  final String? error;

  PlantsState({
    required this.status,
    this.userId,
    required this.plants,
    required this.entries,
    this.query = '',
    this.location,
    this.onlyNeedsCare = false,
    required this.sort,
    required this.asGrid,
    this.recentIds = const [],
    required this.today,
    this.error,
  });

  factory PlantsState.initial(AppSettings settings, DateTime today) => PlantsState(
        status: PlantsStatus.loading,
        plants: const [],
        entries: const [],
        sort: settings.plantSort,
        asGrid: settings.plantsAsGrid,
        today: today,
      );

  /// Розклад догляду кожної рослини (обчислюється один раз на стан).
  late final Map<String, CareSchedule> schedules = {
    for (final p in plants) p.id: CareSchedule.of(p, entries, today),
  };

  CareSchedule scheduleOf(Plant plant) => schedules[plant.id] ?? CareSchedule.of(plant, entries, today);

  Plant? byId(String id) {
    for (final p in plants) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Каталог після пошуку, фільтрів і сортування.
  late final List<Plant> visiblePlants = () {
    final q = query.trim().toLowerCase();
    final result = plants.where((p) {
      if (location != null && p.location != location) return false;
      if (onlyNeedsCare && schedules[p.id]!.todayTasks.every((t) => t.done)) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.species.toLowerCase().contains(q) ||
          p.notes.toLowerCase().contains(q);
    }).toList();
    switch (sort) {
      case PlantSort.name:
        result.sort((a, b) => a.name.compareTo(b.name));
      case PlantSort.nextWatering:
        result.sort((a, b) => schedules[a.id]!.nextWatering.compareTo(schedules[b.id]!.nextWatering));
      case PlantSort.newest:
        result.sort((a, b) => b.acquiredAt.compareTo(a.acquiredAt));
    }
    return result;
  }();

  /// Розташування, що трапляються в колекції (для чипів-фільтрів).
  late final List<String> usedLocations = [
    for (final l in Plant.locations)
      if (plants.any((p) => p.location == l)) l,
  ];

  /// «Догляд на сьогодні»: спершу прострочене, потім на сьогодні, наприкінці виконане.
  late final List<CareTask> todayTasks = [
    for (final s in schedules.values) ...s.todayTasks,
  ]..sort((a, b) {
      int rank(CareTask t) => t.done ? 2 : (t.overdue ? 0 : 1);
      final r = rank(a).compareTo(rank(b));
      return r != 0 ? r : a.daysLeft.compareTo(b.daysLeft);
    });

  int get pendingTaskCount => todayTasks.where((t) => !t.done).length;

  int get overdueCount => todayTasks.where((t) => t.overdue).length;

  /// Рослини, найближчі до поливу (для горизонтального списку на головній).
  late final List<Plant> byNextWatering = [...plants]
    ..sort((a, b) => schedules[a.id]!.nextWatering.compareTo(schedules[b.id]!.nextWatering));

  late final List<Plant> recentPlants = [
    for (final id in recentIds)
      ?byId(id),
  ];

  PlantsState copyWith({
    PlantsStatus? status,
    String? Function()? userId,
    List<Plant>? plants,
    List<CareEntry>? entries,
    String? query,
    String? Function()? location,
    bool? onlyNeedsCare,
    PlantSort? sort,
    bool? asGrid,
    List<String>? recentIds,
    DateTime? today,
    String? error,
  }) {
    return PlantsState(
      status: status ?? this.status,
      userId: userId != null ? userId() : this.userId,
      plants: plants ?? this.plants,
      entries: entries ?? this.entries,
      query: query ?? this.query,
      location: location != null ? location() : this.location,
      onlyNeedsCare: onlyNeedsCare ?? this.onlyNeedsCare,
      sort: sort ?? this.sort,
      asGrid: asGrid ?? this.asGrid,
      recentIds: recentIds ?? this.recentIds,
      today: today ?? this.today,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [status, userId, plants, entries, query, location, onlyNeedsCare, sort, asGrid, recentIds, today, error];
}
