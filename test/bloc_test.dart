import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plant_care/core/data/models/app_settings.dart';
import 'package:plant_care/core/data/models/care_entry.dart';
import 'package:plant_care/core/data/models/plant.dart';
import 'package:plant_care/core/data/repositories/local_garden_repository.dart';
import 'package:plant_care/core/data/repositories/settings_repository.dart';
import 'package:plant_care/features/auth/bloc/login_bloc.dart';
import 'package:plant_care/features/journal/bloc/journal_bloc.dart';
import 'package:plant_care/features/plants/bloc/plants_bloc.dart';

import 'helpers.dart';

/// Фіксована дата, щоб розклад догляду в тестах не залежав від дня запуску.
final _now = DateTime(2026, 10, 4, 12);
DateTime _clock() => _now;

void main() {
  late SharedPreferences prefs;
  late LocalGardenRepository garden;
  late SettingsRepository settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    garden = LocalGardenRepository(prefs, now: _clock);
    settings = SettingsRepository(prefs);
    await garden.open('u1');
  });

  group('LoginBloc', () {
    blocTest<LoginBloc, LoginState>(
      'emits [Loading, Success] for valid credentials',
      build: () => LoginBloc(FakeAuthRepository()),
      wait: const Duration(milliseconds: 50),
      act: (bloc) => bloc.add(const LoginSubmitted('test@example.com', 'password123')),
      expect: () => [const LoginLoading(LoginMethod.email), const LoginSuccess()],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [Loading, Failure] for a wrong password',
      build: () => LoginBloc(FakeAuthRepository()),
      wait: const Duration(milliseconds: 50),
      act: (bloc) => bloc.add(const LoginSubmitted('test@example.com', '123')),
      expect: () => [const LoginLoading(LoginMethod.email), const LoginFailure('Невірний email або пароль.')],
    );
  });

  group('PlantsBloc', () {
    PlantsBloc build() => PlantsBloc(garden: garden, settings: settings, now: _clock);

    test('loads demo plants and computes today tasks', () async {
      final bloc = build()..add(const PlantsSubscriptionRequested());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.status, PlantsStatus.ready);
      expect(bloc.state.plants, hasLength(7));
      // Прострочений полив хлорофітуму – першим у списку.
      expect(bloc.state.todayTasks.first.plant.name, 'Хлорофітум');
      expect(bloc.state.overdueCount, 1);
      await bloc.close();
    });

    test('filters, sorts and persists the sort order', () async {
      final bloc = build()..add(const PlantsSubscriptionRequested());
      await Future<void>.delayed(Duration.zero);
      bloc
        ..add(const PlantsLocationFilterChanged('Вітальня'))
        ..add(const PlantsSortChanged(PlantSort.nextWatering));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.visiblePlants.map((p) => p.name), ['Монстера', 'Спатифілум']);
      expect(settings.load().plantSort, PlantSort.nextWatering);
      await bloc.close();
    });

    test('creates, updates and deletes a plant with its journal', () async {
      final bloc = build()..add(const PlantsSubscriptionRequested());
      await Future<void>.delayed(Duration.zero);

      bloc.add(PlantSaved(Plant(id: '', name: 'Алое', acquiredAt: DateTime(2026, 10, 1))));
      await Future<void>.delayed(Duration.zero);
      final aloe = bloc.state.plants.singleWhere((p) => p.name == 'Алое');
      expect(aloe.id, isNotEmpty);

      bloc.add(PlantSaved(aloe.copyWith(wateringIntervalDays: 14)));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.byId(aloe.id)!.wateringIntervalDays, 14);

      bloc.add(const PlantDeleted('monstera'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.byId('monstera'), isNull);
      expect(bloc.state.entries.where((e) => e.plantId == 'monstera'), isEmpty);
      await bloc.close();
    });
  });

  group('JournalBloc', () {
    test('groups entries by day and filters by type', () async {
      final bloc = JournalBloc(garden: garden, now: _clock)..add(const JournalSubscriptionRequested());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.days.first.day, DateTime(2026, 10, 4));
      bloc.add(const JournalTypeFilterChanged(CareType.repotting));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.visibleEntries.every((e) => e.type == CareType.repotting), isTrue);
      await bloc.close();
    });

    test('watering entry moves the next watering date; undo restores it', () async {
      final plants = PlantsBloc(garden: garden, settings: settings, now: _clock)
        ..add(const PlantsSubscriptionRequested());
      final journal = JournalBloc(garden: garden, now: _clock)..add(const JournalSubscriptionRequested());
      await Future<void>.delayed(Duration.zero);
      final chloro = plants.state.byId('chloro')!;
      expect(plants.state.scheduleOf(chloro).daysToWatering, -1);

      final entry = CareEntry(id: 'w1', plantId: 'chloro', type: CareType.watering, performedAt: _now);
      journal.add(JournalEntrySaved(entry));
      await Future<void>.delayed(Duration.zero);
      expect(plants.state.scheduleOf(chloro).daysToWatering, 5);

      journal.add(JournalEntryDeleted(entry));
      await Future<void>.delayed(Duration.zero);
      expect(plants.state.scheduleOf(chloro).daysToWatering, -1);
      await plants.close();
      await journal.close();
    });
  });

  test('LocalGardenRepository keeps data between app launches', () async {
    await garden.saveEntry(CareEntry(id: 'x', plantId: 'ficus', type: CareType.spraying, performedAt: _now));
    // «Перезапуск»: новий репозиторій читає ті самі SharedPreferences.
    final restarted = LocalGardenRepository(prefs, now: _clock);
    await restarted.open('u1');
    expect(restarted.current.entries.any((e) => e.id == 'x'), isTrue);
    expect(restarted.current.plants, hasLength(7));
  });
}
