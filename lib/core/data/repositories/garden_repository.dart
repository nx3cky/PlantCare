import 'package:equatable/equatable.dart';

import '../models/care_entry.dart';
import '../models/plant.dart';

/// Знімок даних користувача: рослини та журнал догляду.
class Garden extends Equatable {
  /// UID власника; null – користувач не увійшов.
  final String? userId;
  final List<Plant> plants;
  final List<CareEntry> entries;

  const Garden({this.userId, this.plants = const [], this.entries = const []});

  static const empty = Garden();

  @override
  List<Object?> get props => [userId, plants, entries];
}

/// Контракт доступу до рослин і журналу догляду. BLoC працюють лише з цим
/// інтерфейсом, тож локальну реалізацію можна замінити на Cloud Firestore
/// без змін у логіці стану та інтерфейсі.
abstract interface class GardenRepository {
  /// Поточний знімок одразу після підписки та кожен наступний після змін.
  Stream<Garden> watch();

  Garden get current;

  /// Завантажує дані користувача [userId] (null – вихід із акаунта).
  Future<void> open(String? userId);

  /// Створює або оновлює рослину (за [Plant.id]).
  Future<void> savePlant(Plant plant);

  /// Видаляє рослину разом з її записами журналу (каскадно).
  Future<void> deletePlant(String plantId);

  /// Створює або оновлює запис журналу (за [CareEntry.id]).
  Future<void> saveEntry(CareEntry entry);

  Future<void> deleteEntry(String entryId);

  /// Унікальний ідентифікатор для нової рослини чи запису.
  String newId();
}
