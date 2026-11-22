part of 'journal_bloc.dart';

sealed class JournalEvent {
  const JournalEvent();
}

final class JournalSubscriptionRequested extends JournalEvent {
  const JournalSubscriptionRequested();
}

/// Чип типу процедури; null – «Усі».
final class JournalTypeFilterChanged extends JournalEvent {
  final CareType? type;

  const JournalTypeFilterChanged(this.type);
}

/// Фільтр за рослиною; null – усі рослини.
final class JournalPlantFilterChanged extends JournalEvent {
  final String? plantId;

  const JournalPlantFilterChanged(this.plantId);
}

/// Фільтр за місяцем (перше число місяця); null – за весь час.
final class JournalMonthFilterChanged extends JournalEvent {
  final DateTime? month;

  const JournalMonthFilterChanged(this.month);
}

final class JournalQueryChanged extends JournalEvent {
  final String query;

  const JournalQueryChanged(this.query);
}

final class JournalFiltersReset extends JournalEvent {
  const JournalFiltersReset();
}

/// Створення (порожній id), редагування або відновлення запису.
final class JournalEntrySaved extends JournalEvent {
  final CareEntry entry;

  const JournalEntrySaved(this.entry);
}

final class JournalEntryDeleted extends JournalEvent {
  final CareEntry entry;

  const JournalEntryDeleted(this.entry);
}
