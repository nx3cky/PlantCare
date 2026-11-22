import '../models/care_entry.dart';
import '../models/plant.dart';
import '../repositories/garden_repository.dart';

/// Hardcoded-колекція для першого входу: 7 рослин і журнал за останній місяць.
/// Дати відраховуються від поточного дня, тож на головному екрані завжди є
/// прострочений полив, полив і підживлення на сьогодні.
abstract final class DemoGarden {
  static Garden build(String userId, DateTime now) {
    // Календарна арифметика через конструктор DateTime: subtract(Duration)
    // через перехід на зимовий час зсунув би дату на годину – і на добу.
    DateTime at(int daysAgo, int hour, int minute) =>
        DateTime(now.year, now.month, now.day - daysAgo, hour, minute);

    final plants = [
      Plant(
        id: 'monstera',
        name: 'Монстера',
        species: 'Monstera deliciosa',
        location: 'Вітальня',
        image: 'assets/images/monstera.jpg',
        acquiredAt: DateTime(2026, 3, 12),
        wateringIntervalDays: 7,
        fertilizingIntervalDays: 30,
        light: LightLevel.diffused,
        temperatureMin: 18,
        temperatureMax: 27,
        notes: 'Протирати листя від пилу раз на тиждень',
      ),
      Plant(
        id: 'ficus',
        name: 'Фікус',
        species: 'Ficus elastica',
        location: 'Спальня',
        image: 'assets/images/ficus.jpg',
        acquiredAt: DateTime(2025, 11, 2),
        wateringIntervalDays: 10,
        fertilizingIntervalDays: 30,
        light: LightLevel.diffused,
        temperatureMin: 16,
        temperatureMax: 25,
        notes: 'Не переставляти – скидає листя',
      ),
      Plant(
        id: 'chloro',
        name: 'Хлорофітум',
        species: 'Chlorophytum comosum',
        location: 'Кухня',
        image: 'assets/images/chloro.jpg',
        acquiredAt: DateTime(2026, 5, 20),
        wateringIntervalDays: 5,
        fertilizingIntervalDays: 30,
        light: LightLevel.diffused,
        temperatureMin: 15,
        temperatureMax: 26,
      ),
      Plant(
        id: 'spathiphyllum',
        name: 'Спатифілум',
        species: 'Spathiphyllum wallisii',
        location: 'Вітальня',
        image: 'assets/images/spathiphyllum.png',
        acquiredAt: DateTime(2026, 1, 15),
        wateringIntervalDays: 4,
        fertilizingIntervalDays: 21,
        light: LightLevel.shade,
        temperatureMin: 18,
        temperatureMax: 25,
        notes: 'Поливати відстояною водою кімнатної температури',
      ),
      Plant(
        id: 'zamio',
        name: 'Заміокулькас',
        species: 'Zamioculcas zamiifolia',
        location: 'Кабінет',
        image: 'assets/images/zamio.jpg',
        acquiredAt: DateTime(2026, 10, 4),
        wateringIntervalDays: 14,
        fertilizingIntervalDays: 30,
        light: LightLevel.diffused,
        temperatureMin: 18,
        temperatureMax: 26,
        notes: 'Не переливати – ґрунт має повністю просихати між поливами',
      ),
      Plant(
        id: 'sansevieria',
        name: 'Сансев’єрія',
        species: 'Sansevieria trifasciata',
        location: 'Спальня',
        image: 'assets/images/sansevieria.jpg',
        acquiredAt: DateTime(2025, 8, 30),
        wateringIntervalDays: 21,
        fertilizingIntervalDays: 60,
        light: LightLevel.shade,
        temperatureMin: 15,
        temperatureMax: 30,
      ),
      Plant(
        id: 'echeveria',
        name: 'Ехеверія',
        species: 'Echeveria elegans',
        location: 'Балкон',
        image: 'assets/images/echeveria.jpg',
        acquiredAt: DateTime(2026, 6, 8),
        wateringIntervalDays: 10,
        light: LightLevel.direct,
        temperatureMin: 10,
        temperatureMax: 30,
        notes: 'Поливати по краю горщика, не на розетку',
      ),
    ];

    var n = 0;
    CareEntry e(String plantId, CareType type, DateTime when, [String notes = '', String? photo]) =>
        CareEntry(id: 'demo${n++}', plantId: plantId, type: type, performedAt: when, notes: notes, photo: photo);

    final entries = [
      // Сьогодні
      e('zamio', CareType.repotting, at(0, 10, 30), 'Новий горщик Ø18 см, ґрунт для сукулентів',
          'assets/images/zamio.jpg'),
      e('spathiphyllum', CareType.watering, at(0, 9, 5), '400 мл відстояної води'),
      // Вчора
      e('ficus', CareType.watering, at(1, 18, 20), '600 мл'),
      e('monstera', CareType.spraying, at(1, 18, 5), 'Листя протерто від пилу'),
      e('chloro', CareType.pruning, at(1, 11, 47), 'Видалено 3 сухі листки'),
      // Раніше
      e('spathiphyllum', CareType.fertilizing, at(5, 19, 10), 'Добриво для квітучих, 5 мл'),
      e('zamio', CareType.watering, at(5, 9, 30), '300 мл, ґрунт повністю просох'),
      e('echeveria', CareType.watering, at(5, 8, 50), '100 мл по краю горщика'),
      e('chloro', CareType.watering, at(6, 9, 15), '300 мл'),
      e('monstera', CareType.watering, at(7, 9, 12), '500 мл'),
      e('sansevieria', CareType.watering, at(9, 20, 0), '250 мл'),
      e('monstera', CareType.fertilizing, at(10, 18, 40), 'Рідке добриво для листяних, 5 мл'),
      e('chloro', CareType.fertilizing, at(12, 18, 30), 'Рідке добриво, 3 мл'),
      e('chloro', CareType.watering, at(11, 9, 0), '300 мл'),
      e('ficus', CareType.watering, at(11, 19, 5), '600 мл'),
      e('monstera', CareType.watering, at(14, 9, 0), '500 мл'),
      e('spathiphyllum', CareType.watering, at(4, 8, 45), '400 мл'),
      e('spathiphyllum', CareType.spraying, at(8, 20, 15), 'Обприскано листя'),
      e('echeveria', CareType.watering, at(15, 9, 20), '100 мл'),
      e('zamio', CareType.fertilizing, at(3, 17, 0), 'Добриво для сукулентів, 2 мл'),
      e('ficus', CareType.fertilizing, at(30, 18, 0), 'Рідке добриво для листяних, 5 мл'),
      e('sansevieria', CareType.fertilizing, at(34, 18, 0), 'Добриво для сукулентів, 2 мл'),
      e('ficus', CareType.pruning, at(26, 12, 10), 'Сформовано крону, обрізано верхівку'),
      e('monstera', CareType.repotting, at(40, 11, 0), 'Горщик Ø24 см, дренаж із керамзиту'),
    ]..sort((a, b) => b.performedAt.compareTo(a.performedAt));

    return Garden(userId: userId, plants: plants, entries: entries);
  }
}
