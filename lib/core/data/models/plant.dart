import 'package:equatable/equatable.dart';

/// Вимоги до освітлення (з ЛР2: shade, diffused, direct).
enum LightLevel {
  shade('Тінь', 'Подалі від вікна'),
  diffused('Розсіяне', 'Без прямого сонця'),
  direct('Пряме', 'Південне вікно');

  final String label;
  final String hint;

  const LightLevel(this.label, this.hint);
}

/// Рослина користувача з правилами догляду (об'єкт даних 3.2 з ЛР2).
/// Дати останніх процедур не зберігаються тут: їх обчислює [CareSchedule]
/// з журналу, тож видалення запису автоматично «повертає» розклад.
class Plant extends Equatable {
  static const locations = [
    'Вітальня', 'Спальня', 'Кухня', 'Кабінет', 'Балкон', 'Ванна', 'Інше',
  ];

  final String id;
  final String name;
  final String species;
  final String location;

  /// Шлях до asset-зображення або HTTPS-посилання; null – без фото.
  final String? image;
  final DateTime acquiredAt;
  final int wateringIntervalDays;

  /// null – рослина не потребує підживлення.
  final int? fertilizingIntervalDays;
  final LightLevel light;
  final int temperatureMin;
  final int temperatureMax;
  final String notes;

  const Plant({
    required this.id,
    required this.name,
    this.species = '',
    this.location = 'Вітальня',
    this.image,
    required this.acquiredAt,
    this.wateringIntervalDays = 7,
    this.fertilizingIntervalDays,
    this.light = LightLevel.diffused,
    this.temperatureMin = 18,
    this.temperatureMax = 26,
    this.notes = '',
  });

  Plant copyWith({
    String? name,
    String? species,
    String? location,
    String? Function()? image,
    DateTime? acquiredAt,
    int? wateringIntervalDays,
    int? Function()? fertilizingIntervalDays,
    LightLevel? light,
    int? temperatureMin,
    int? temperatureMax,
    String? notes,
  }) {
    return Plant(
      id: id,
      name: name ?? this.name,
      species: species ?? this.species,
      location: location ?? this.location,
      image: image != null ? image() : this.image,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      wateringIntervalDays: wateringIntervalDays ?? this.wateringIntervalDays,
      fertilizingIntervalDays:
          fertilizingIntervalDays != null ? fertilizingIntervalDays() : this.fertilizingIntervalDays,
      light: light ?? this.light,
      temperatureMin: temperatureMin ?? this.temperatureMin,
      temperatureMax: temperatureMax ?? this.temperatureMax,
      notes: notes ?? this.notes,
    );
  }

  /// Копія з новим ідентифікатором (під час створення рослини).
  Plant withId(String newId) => Plant.fromJson({...toJson(), 'id': newId});

  factory Plant.fromJson(Map<String, dynamic> json) => Plant(
        id: json['id'] as String,
        name: json['name'] as String,
        species: json['species'] as String? ?? '',
        location: json['location'] as String? ?? 'Інше',
        image: json['image'] as String?,
        acquiredAt: DateTime.parse(json['acquiredAt'] as String),
        wateringIntervalDays: json['wateringIntervalDays'] as int,
        fertilizingIntervalDays: json['fertilizingIntervalDays'] as int?,
        light: LightLevel.values.byName(json['light'] as String),
        temperatureMin: json['temperatureMin'] as int? ?? 18,
        temperatureMax: json['temperatureMax'] as int? ?? 26,
        notes: json['notes'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'species': species,
        'location': location,
        'image': image,
        'acquiredAt': acquiredAt.toIso8601String(),
        'wateringIntervalDays': wateringIntervalDays,
        'fertilizingIntervalDays': fertilizingIntervalDays,
        'light': light.name,
        'temperatureMin': temperatureMin,
        'temperatureMax': temperatureMax,
        'notes': notes,
      };

  @override
  List<Object?> get props => [
        id, name, species, location, image, acquiredAt, wateringIntervalDays,
        fertilizingIntervalDays, light, temperatureMin, temperatureMax, notes,
      ];
}
