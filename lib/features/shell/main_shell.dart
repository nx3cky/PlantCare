import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/analytics_service.dart';
import '../home/home_screen.dart';
import '../journal/journal_screen.dart';
import '../plants/plants_screen.dart';
import '../profile/profile_screen.dart';
import 'navigation_cubit.dart';

/// Основний каркас після входу: нижня навігація на 4 розділи.
/// Поточна вкладка зберігається в [NavigationCubit], тож її можуть
/// змінювати й інші екрани (головна, деталі рослини).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView(context.read<NavigationCubit>().state.name);
  }

  @override
  Widget build(BuildContext context) {
    // Вкладки IndexedStack не є маршрутами Navigator, тож перегляд логуємо вручну.
    return BlocConsumer<NavigationCubit, AppTab>(
      listener: (_, tab) => AnalyticsService.instance.logScreenView(tab.name),
      builder: (context, tab) => Scaffold(
        body: IndexedStack(
          index: tab.index,
          children: const [HomeScreen(), PlantsScreen(), JournalScreen(), ProfileScreen()],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab.index,
          onDestinationSelected: (i) => context.read<NavigationCubit>().select(AppTab.values[i]),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Головна'),
            NavigationDestination(icon: Icon(Icons.eco_outlined), selectedIcon: Icon(Icons.eco), label: 'Рослини'),
            NavigationDestination(
                icon: Icon(Icons.article_outlined), selectedIcon: Icon(Icons.article), label: 'Журнал'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Профіль'),
          ],
        ),
      ),
    );
  }
}
