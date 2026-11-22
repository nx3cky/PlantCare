import 'package:equatable/equatable.dart';

/// Тип процедури догляду (з ЛР2: watering, fertilizing, repotting, spraying, pruning, other).
enum CareType {
  watering('Полив'),
  fertilizing('Підживлення'),
  pruning('Обрізка'),
  repotting('Пересадка'),
  spraying('Обприскування'),
  other('Інше');

  final String label;

  const CareType(this.label);

  /// Процедури з періодичністю, від яких залежить розклад рослини.
  bool get isScheduled => this == watering || this == fertilizing;
}

/// Запис журналу догляду (об'єкт даних 3.3 з ЛР2).
class CareEntry extends Equatable {
  final String id;
  final String plantId;
  final CareType type;
  final DateTime performedAt;
  final String notes;

  /// Фото стану рослини після процедури (asset або HTTPS), необов'язкове.
  final String? photo;

  const CareEntry({
    required this.id,
    required this.plantId,
    required this.type,
    required this.performedAt,
    this.notes = '',
    this.photo,
  });

  CareEntry copyWith({
    String? plantId,
    CareType? type,
    DateTime? performedAt,
    String? notes,
    String? Function()? photo,
  }) {
    return CareEntry(
      id: id,
      plantId: plantId ?? this.plantId,
      type: type ?? this.type,
      performedAt: performedAt ?? this.performedAt,
      notes: notes ?? this.notes,
      photo: photo != null ? photo() : this.photo,
    );
  }

  factory CareEntry.fromJson(Map<String, dynamic> json) => CareEntry(
        id: json['id'] as String,
        plantId: json['plantId'] as String,
        type: CareType.values.byName(json['type'] as String),
        performedAt: DateTime.parse(json['performedAt'] as String),
        notes: json['notes'] as String? ?? '',
        photo: json['photo'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'plantId': plantId,
        'type': type.name,
        'performedAt': performedAt.toIso8601String(),
        'notes': notes,
        'photo': photo,
      };

  @override
  List<Object?> get props => [id, plantId, type, performedAt, notes, photo];
}
