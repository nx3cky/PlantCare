import '../../utils/date_format.dart';
import 'care_entry.dart';
import 'plant.dart';

/// Розклад догляду рослини, обчислений з її правил і журналу (ФВ-9 з ЛР2):
/// наступна процедура = остання виконана (або дата появи рослини) + інтервал.
class CareSchedule {
  final Plant plant;
  final DateTime today;
  final DateTime lastWatered;
  final DateTime? lastFertilized;

  /// Сьогоднішні записи поливу й підживлення (для відмітки «виконано»).
  final CareEntry? wateredToday;
  final CareEntry? fertilizedToday;

  const CareSchedule._({
    required this.plant,
    required this.today,
    required this.lastWatered,
    required this.lastFertilized,
    required this.wateredToday,
    required this.fertilizedToday,
  });

  /// [entries] – записи журналу (будь-яких рослин, у будь-якому порядку).
  factory CareSchedule.of(Plant plant, Iterable<CareEntry> entries, DateTime today) {
    CareEntry? lastWater, lastFeed;
    for (final e in entries) {
      if (e.plantId != plant.id) continue;
      if (e.type == CareType.watering &&
          (lastWater == null || e.performedAt.isAfter(lastWater.performedAt))) {
        lastWater = e;
      } else if (e.type == CareType.fertilizing &&
          (lastFeed == null || e.performedAt.isAfter(lastFeed.performedAt))) {
        lastFeed = e;
      }
    }
    bool isToday(CareEntry? e) => e != null && DateFormatUa.daysBetween(e.performedAt, today) == 0;
    return CareSchedule._(
      plant: plant,
      today: today,
      lastWatered: lastWater?.performedAt ?? plant.acquiredAt,
      lastFertilized: lastFeed?.performedAt ??
          (plant.fertilizingIntervalDays == null ? null : plant.acquiredAt),
      wateredToday: isToday(lastWater) ? lastWater : null,
      fertilizedToday: isToday(lastFeed) ? lastFeed : null,
    );
  }

  DateTime get nextWatering =>
      DateFormatUa.addDays(lastWatered, plant.wateringIntervalDays);

  DateTime? get nextFertilizing => plant.fertilizingIntervalDays == null
      ? null
      : DateFormatUa.addDays(lastFertilized!, plant.fertilizingIntervalDays!);

  /// Днів до поливу: 0 – сьогодні, від'ємне – прострочено.
  int get daysToWatering => DateFormatUa.daysBetween(today, nextWatering);

  int? get daysToFertilizing =>
      nextFertilizing == null ? null : DateFormatUa.daysBetween(today, nextFertilizing!);

  bool get needsWater => daysToWatering <= 0;

  bool get isOverdue => daysToWatering < 0 || (daysToFertilizing ?? 0) < 0;

  /// Процедури на сьогодні: настав термін або вже виконано сьогодні.
  List<CareTask> get todayTasks => [
        if (daysToWatering <= 0 || wateredToday != null)
          CareTask(schedule: this, type: CareType.watering, daysLeft: daysToWatering, doneEntry: wateredToday),
        if (daysToFertilizing != null && (daysToFertilizing! <= 0 || fertilizedToday != null))
          CareTask(
            schedule: this,
            type: CareType.fertilizing,
            daysLeft: daysToFertilizing!,
            doneEntry: fertilizedToday,
          ),
      ];
}

/// Процедура догляду на сьогодні для списку на головному екрані.
class CareTask {
  final CareSchedule schedule;
  final CareType type;

  /// Днів до терміну на момент обчислення: 0 – сьогодні, від'ємне – прострочено.
  final int daysLeft;

  /// Запис журналу, якщо процедуру вже виконано сьогодні.
  final CareEntry? doneEntry;

  const CareTask({
    required this.schedule,
    required this.type,
    required this.daysLeft,
    this.doneEntry,
  });

  Plant get plant => schedule.plant;

  bool get done => doneEntry != null;

  bool get overdue => !done && daysLeft < 0;

  int get interval =>
      type == CareType.watering ? plant.wateringIntervalDays : plant.fertilizingIntervalDays ?? 0;

  String get action => type == CareType.watering ? 'Полити' : 'Підживити';

  String get subtitle {
    if (done) return 'Виконано о ${DateFormatUa.time(doneEntry!.performedAt)}';
    if (overdue) return 'Прострочено на ${DateFormatUa.days(-daysLeft)}';
    final period = type == CareType.watering ? 'кожні' : 'раз на';
    return '${plant.location} · $period ${DateFormatUa.days(interval)}';
  }
}
