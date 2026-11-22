import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../demo/demo_garden.dart';
import '../models/care_entry.dart';
import '../models/plant.dart';
import 'garden_repository.dart';

/// Локальна реалізація [GardenRepository]: рослини та журнал кожного
/// користувача зберігаються як JSON-рядки в SharedPreferences.
/// Під час першого входу користувача колекція заповнюється демо-даними.
/// У наступних ЛР її замінить реалізація на Cloud Firestore.
class LocalGardenRepository implements GardenRepository {
  static String _plantsKey(String userId) => 'garden.$userId.plants';
  static String _entriesKey(String userId) => 'garden.$userId.entries';

  final SharedPreferences _prefs;
  final DateTime Function() _now;
  final _changes = StreamController<Garden>.broadcast();
  final _random = Random();
  Garden _garden = Garden.empty;

  LocalGardenRepository(this._prefs, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  @override
  Garden get current => _garden;

  @override
  Stream<Garden> watch() {
    // Кожен підписник спершу отримує поточний знімок, потім – зміни.
    late final StreamController<Garden> controller;
    StreamSubscription<Garden>? subscription;
    controller = StreamController<Garden>(
      onListen: () {
        controller.add(_garden);
        subscription = _changes.stream.listen(controller.add);
      },
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<void> open(String? userId) async {
    if (userId == _garden.userId) return;
    if (userId == null) return _emit(Garden.empty);

    final plantsJson = _prefs.getString(_plantsKey(userId));
    if (plantsJson == null) {
      // Перший вхід на цьому пристрої – демонстраційна колекція.
      final demo = DemoGarden.build(userId, _now());
      await _persist(demo);
      return _emit(demo);
    }
    final entriesJson = _prefs.getString(_entriesKey(userId)) ?? '[]';
    _emit(Garden(
      userId: userId,
      plants: [
        for (final p in jsonDecode(plantsJson) as List) Plant.fromJson(p as Map<String, dynamic>),
      ],
      entries: _sorted([
        for (final e in jsonDecode(entriesJson) as List) CareEntry.fromJson(e as Map<String, dynamic>),
      ]),
    ));
  }

  @override
  Future<void> savePlant(Plant plant) {
    final plants = [..._garden.plants];
    final i = plants.indexWhere((p) => p.id == plant.id);
    i < 0 ? plants.add(plant) : plants[i] = plant;
    return _update(Garden(userId: _garden.userId, plants: plants, entries: _garden.entries));
  }

  @override
  Future<void> deletePlant(String plantId) => _update(Garden(
        userId: _garden.userId,
        plants: _garden.plants.where((p) => p.id != plantId).toList(),
        entries: _garden.entries.where((e) => e.plantId != plantId).toList(),
      ));

  @override
  Future<void> saveEntry(CareEntry entry) {
    final entries = [..._garden.entries];
    final i = entries.indexWhere((e) => e.id == entry.id);
    i < 0 ? entries.add(entry) : entries[i] = entry;
    return _update(Garden(userId: _garden.userId, plants: _garden.plants, entries: _sorted(entries)));
  }

  @override
  Future<void> deleteEntry(String entryId) => _update(Garden(
        userId: _garden.userId,
        plants: _garden.plants,
        entries: _garden.entries.where((e) => e.id != entryId).toList(),
      ));

  @override
  String newId() =>
      '${_now().microsecondsSinceEpoch.toRadixString(36)}${_random.nextInt(1 << 20).toRadixString(36)}';

  Future<void> _update(Garden garden) async {
    if (garden.userId == null) throw StateError('Немає активного користувача');
    _emit(garden);
    await _persist(garden);
  }

  Future<void> _persist(Garden garden) async {
    final userId = garden.userId!;
    await _prefs.setString(_plantsKey(userId), jsonEncode([for (final p in garden.plants) p.toJson()]));
    await _prefs.setString(_entriesKey(userId), jsonEncode([for (final e in garden.entries) e.toJson()]));
  }

  void _emit(Garden garden) {
    _garden = garden;
    _changes.add(garden);
  }

  /// Журнал зберігається від новіших записів до старіших.
  static List<CareEntry> _sorted(List<CareEntry> entries) =>
      entries..sort((a, b) => b.performedAt.compareTo(a.performedAt));
}
