import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/data/repositories/garden_repository.dart';
import '../core/data/repositories/settings_repository.dart';
import '../core/services/analytics_service.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_snack_bar.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/journal/bloc/journal_bloc.dart';
import '../features/plants/bloc/plants_bloc.dart';
import '../features/profile/bloc/profile_bloc.dart';
import '../features/shell/navigation_cubit.dart';
import 'app_routes.dart';

/// Корінь застосунку: репозиторії (RepositoryProvider) і менеджери стану
/// (BlocProvider) розміщено над MaterialApp, тож вони доступні всім маршрутам –
/// і вкладкам, і екранам, відкритим поверх (деталі рослини, форми).
class PlantCareApp extends StatelessWidget {
  final AuthRepository authRepository;
  final GardenRepository gardenRepository;
  final SettingsRepository settingsRepository;

  const PlantCareApp({
    super.key,
    required this.authRepository,
    required this.gardenRepository,
    required this.settingsRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<GardenRepository>.value(value: gardenRepository),
        RepositoryProvider<SettingsRepository>.value(value: settingsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            lazy: false,
            create: (context) => AuthBloc(context.read<AuthRepository>())..add(const AuthSubscriptionRequested()),
          ),
          BlocProvider(
            create: (context) => ProfileBloc(
              auth: context.read<AuthRepository>(),
              settings: context.read<SettingsRepository>(),
            )..add(const ProfileSubscriptionRequested()),
          ),
          BlocProvider(
            create: (context) => PlantsBloc(
              garden: context.read<GardenRepository>(),
              settings: context.read<SettingsRepository>(),
            )..add(const PlantsSubscriptionRequested()),
          ),
          BlocProvider(
            create: (context) =>
                JournalBloc(garden: context.read<GardenRepository>())..add(const JournalSubscriptionRequested()),
          ),
          BlocProvider(create: (_) => NavigationCubit()),
        ],
        child: const _AppView(),
      ),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  /// Вхід або вихід: завантажити дані цього користувача, закрити екрани,
  /// відкриті поверх (реєстрація, деталі рослини), і повернутися на «Головну».
  void _onUserChanged(BuildContext context, AuthState state) {
    context.read<GardenRepository>().open(state.user?.uid);
    context.read<NavigationCubit>().select(AppTab.home);
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) => prev.user?.uid != curr.user?.uid,
          listener: _onUserChanged,
        ),
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) => curr.error != null && prev.error != curr.error,
          listener: (_, state) => _navigatorKey.currentContext?.showMessage(state.error!, isError: true),
        ),
      ],
      child: MaterialApp(
        title: 'Plant Care',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        navigatorKey: _navigatorKey,
        // Українські тексти системних віджетів: DatePicker, TimePicker, діалоги.
        locale: const Locale('uk'),
        supportedLocales: const [Locale('uk'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        initialRoute: AppRoutes.root,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        navigatorObservers: [
          if (Firebase.apps.isNotEmpty) AnalyticsService.instance.observer,
        ],
      ),
    );
  }
}
