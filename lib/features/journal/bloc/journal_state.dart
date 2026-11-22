part of 'journal_bloc.dart';

enum JournalStatus { loading, ready, failure }

/// Записи одного дня для групування журналу.
typedef JournalDay = ({DateTime day, List<CareEntry> entries});

final class JournalState extends Equatable {
  final JournalStatus status;
  final List<CareEntry> entries;
  final List<Plant> plants;
  final CareType? type;
  final String? plantId;
  final DateTime? month;
  final String query;
  final DateTime today;

  JournalState({
    required this.status,
    this.entries = const [],
    this.plants = const [],
    this.type,
    this.plantId,
    this.month,
    this.query = '',
    required this.today,
  });

  late final Map<String, Plant> plantsById = {for (final p in plants) p.id: p};

  bool get hasFilters => type != null || plantId != null || month != null || query.isNotEmpty;

  /// Записи після фільтрів і пошуку (від новіших до старіших).
  late final List<CareEntry> visibleEntries = () {
    final q = query.trim().toLowerCase();
    return entries.where((e) {
      if (type != null && e.type != type) return false;
      if (plantId != null && e.plantId != plantId) return false;
      if (month != null && (e.performedAt.year != month!.year || e.performedAt.month != month!.month)) {
        return false;
      }
      if (q.isEmpty) return true;
      final plantName = plantsById[e.plantId]?.name.toLowerCase() ?? '';
      return plantName.contains(q) || e.notes.toLowerCase().contains(q) || e.type.label.toLowerCase().contains(q);
    }).toList();
  }();

  /// Записи, згруповані за днями: «Сьогодні», «Вчора», …
  late final List<JournalDay> days = () {
    final result = <JournalDay>[];
    for (final e in visibleEntries) {
      final day = DateFormatUa.dayOf(e.performedAt);
      if (result.isEmpty || result.last.day != day) {
        result.add((day: day, entries: [e]));
      } else {
        result.last.entries.add(e);
      }
    }
    return result;
  }();

  /// Місяці, за які є записи (для фільтра «Жовтень 2026»).
  late final List<DateTime> months = {
    for (final e in entries) DateTime(e.performedAt.year, e.performedAt.month),
  }.toList();

  JournalState copyWith({
    JournalStatus? status,
    List<CareEntry>? entries,
    List<Plant>? plants,
    CareType? Function()? type,
    String? Function()? plantId,
    DateTime? Function()? month,
    String? query,
    DateTime? today,
  }) {
    return JournalState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      plants: plants ?? this.plants,
      type: type != null ? type() : this.type,
      plantId: plantId != null ? plantId() : this.plantId,
      month: month != null ? month() : this.month,
      query: query ?? this.query,
      today: today ?? this.today,
    );
  }

  @override
  List<Object?> get props => [status, entries, plants, type, plantId, month, query, today];
}
