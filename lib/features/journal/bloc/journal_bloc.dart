import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/models/care_entry.dart';
import '../../../core/data/models/plant.dart';
import '../../../core/data/repositories/garden_repository.dart';
import '../../../core/utils/date_format.dart';

part 'journal_event.dart';
part 'journal_state.dart';

/// Журнал догляду (ФВ-8, ФВ-9): завантаження записів, фільтри за типом,
/// рослиною й місяцем, пошук, створення, редагування, видалення з відновленням.
class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final GardenRepository _garden;
  final DateTime Function() _now;

  JournalBloc({required this._garden, DateTime Function()? now})
      : _now = now ?? DateTime.now,
        super(JournalState(status: JournalStatus.loading, today: (now ?? DateTime.now)())) {
    on<JournalSubscriptionRequested>(_onSubscriptionRequested);
    on<JournalTypeFilterChanged>((e, emit) => emit(state.copyWith(type: () => e.type)));
    on<JournalPlantFilterChanged>((e, emit) => emit(state.copyWith(plantId: () => e.plantId)));
    on<JournalMonthFilterChanged>((e, emit) => emit(state.copyWith(month: () => e.month)));
    on<JournalQueryChanged>((e, emit) => emit(state.copyWith(query: e.query)));
    on<JournalFiltersReset>((e, emit) => emit(JournalState(
          status: state.status,
          entries: state.entries,
          plants: state.plants,
          today: state.today,
        )));
    on<JournalEntrySaved>(_onEntrySaved);
    on<JournalEntryDeleted>(_onEntryDeleted);
  }

  Future<void> _onSubscriptionRequested(JournalSubscriptionRequested event, Emitter<JournalState> emit) {
    return emit.forEach<Garden>(
      _garden.watch(),
      onData: (garden) {
        final plantId = state.plantId;
        return state.copyWith(
          status: garden.userId == null ? JournalStatus.loading : JournalStatus.ready,
          entries: garden.entries,
          plants: garden.plants,
          // Фільтр за видаленою рослиною скидається.
          plantId: () => garden.plants.any((p) => p.id == plantId) ? plantId : null,
          today: _now(),
        );
      },
      onError: (error, _) => state.copyWith(status: JournalStatus.failure),
    );
  }

  /// Новий запис (порожній id) або зміна існуючого; також відновлення
  /// видаленого запису через «Скасувати» у SnackBar.
  Future<void> _onEntrySaved(JournalEntrySaved event, Emitter<JournalState> emit) async {
    final entry = event.entry.id.isEmpty
        ? CareEntry(
            id: _garden.newId(),
            plantId: event.entry.plantId,
            type: event.entry.type,
            performedAt: event.entry.performedAt,
            notes: event.entry.notes,
            photo: event.entry.photo,
          )
        : event.entry;
    await _garden.saveEntry(entry);
  }

  Future<void> _onEntryDeleted(JournalEntryDeleted event, Emitter<JournalState> emit) =>
      _garden.deleteEntry(event.entry.id);
}
