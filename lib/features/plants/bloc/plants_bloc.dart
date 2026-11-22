import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/models/app_settings.dart';
import '../../../core/data/models/care_entry.dart';
import '../../../core/data/models/care_schedule.dart';
import '../../../core/data/models/plant.dart';
import '../../../core/data/repositories/garden_repository.dart';
import '../../../core/data/repositories/settings_repository.dart';

part 'plants_event.dart';
part 'plants_state.dart';

/// Каталог рослин (ФВ-7, ФВ-9): завантаження списку, пошук, фільтри,
/// сортування, створення, редагування й видалення, «нещодавно переглянуті».
/// Розклад догляду рахується з журналу, тому BLoC отримує і записи.
class PlantsBloc extends Bloc<PlantsEvent, PlantsState> {
  static const maxRecent = 5;

  final GardenRepository _garden;
  final SettingsRepository _settings;
  final DateTime Function() _now;

  PlantsBloc({
    required this._garden,
    required SettingsRepository settings,
    DateTime Function()? now,
  })  : _settings = settings,
        _now = now ?? DateTime.now,
        super(PlantsState.initial(settings.load(), (now ?? DateTime.now)())) {
    on<PlantsSubscriptionRequested>(_onSubscriptionRequested);
    on<PlantsQueryChanged>((e, emit) => emit(state.copyWith(query: e.query)));
    on<PlantsLocationFilterChanged>((e, emit) => emit(state.copyWith(location: () => e.location)));
    on<PlantsNeedsCareFilterToggled>((e, emit) => emit(state.copyWith(onlyNeedsCare: !state.onlyNeedsCare)));
    on<PlantsSortChanged>(_onSortChanged);
    on<PlantsViewModeToggled>(_onViewModeToggled);
    on<PlantSaved>(_onPlantSaved);
    on<PlantDeleted>(_onPlantDeleted);
    on<PlantViewed>(_onPlantViewed);
    on<PlantsRecentCleared>(_onRecentCleared);
  }

  Future<void> _onSubscriptionRequested(PlantsSubscriptionRequested event, Emitter<PlantsState> emit) {
    return emit.forEach<Garden>(
      _garden.watch(),
      onData: (garden) => state.copyWith(
        status: garden.userId == null ? PlantsStatus.loading : PlantsStatus.ready,
        userId: () => garden.userId,
        plants: garden.plants,
        entries: garden.entries,
        recentIds: garden.userId == null ? const [] : _settings.recentPlants(garden.userId!),
        today: _now(),
      ),
      onError: (error, _) => state.copyWith(status: PlantsStatus.failure, error: '$error'),
    );
  }

  Future<void> _onSortChanged(PlantsSortChanged event, Emitter<PlantsState> emit) async {
    final settings = _settings.load().copyWith(plantSort: event.sort);
    emit(state.copyWith(sort: event.sort));
    await _settings.save(settings);
  }

  Future<void> _onViewModeToggled(PlantsViewModeToggled event, Emitter<PlantsState> emit) async {
    final asGrid = !state.asGrid;
    emit(state.copyWith(asGrid: asGrid));
    await _settings.save(_settings.load().copyWith(plantsAsGrid: asGrid));
  }

  /// Створення (новий id) або оновлення існуючої рослини.
  Future<void> _onPlantSaved(PlantSaved event, Emitter<PlantsState> emit) async {
    final plant = event.plant.id.isEmpty ? event.plant.withId(_garden.newId()) : event.plant;
    await _garden.savePlant(plant);
  }

  Future<void> _onPlantDeleted(PlantDeleted event, Emitter<PlantsState> emit) async {
    await _garden.deletePlant(event.plantId);
    final recent = state.recentIds.where((id) => id != event.plantId).toList();
    emit(state.copyWith(recentIds: recent));
    if (state.userId != null) await _settings.saveRecentPlants(state.userId!, recent);
  }

  Future<void> _onPlantViewed(PlantViewed event, Emitter<PlantsState> emit) async {
    final recent = [event.plantId, ...state.recentIds.where((id) => id != event.plantId)].take(maxRecent).toList();
    emit(state.copyWith(recentIds: recent));
    if (state.userId != null) await _settings.saveRecentPlants(state.userId!, recent);
  }

  Future<void> _onRecentCleared(PlantsRecentCleared event, Emitter<PlantsState> emit) async {
    emit(state.copyWith(recentIds: const []));
    if (state.userId != null) await _settings.saveRecentPlants(state.userId!, const []);
  }
}
