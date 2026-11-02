import 'package:flutter/material.dart';

import '../../core/services/analytics_service.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import 'placeholder_screen.dart';

/// Основний каркас після входу: нижня навігація на 4 розділи.
class MainShell extends StatefulWidget {
  static const homeTab = 0;
  static const profileTab = 3;

  final int initialTab;

  const MainShell({super.key, this.initialTab = homeTab});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _tabNames = ['home', 'plants', 'journal', 'profile'];

  late int _index = widget.initialTab;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView(_tabNames[_index]);
  }

  // Вкладки IndexedStack не є маршрутами Navigator, тож перегляд логуємо вручну.
  void _selectTab(int index) {
    if (index == _index) return;
    setState(() => _index = index);
    AnalyticsService.instance.logScreenView(_tabNames[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onOpenTab: _selectTab),
          const PlaceholderScreen(title: 'Рослини', icon: Icons.eco),
          const PlaceholderScreen(title: 'Журнал', icon: Icons.article),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Головна'),
          NavigationDestination(icon: Icon(Icons.eco_outlined), selectedIcon: Icon(Icons.eco), label: 'Рослини'),
          NavigationDestination(icon: Icon(Icons.article_outlined), selectedIcon: Icon(Icons.article), label: 'Журнал'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Профіль'),
        ],
      ),
    );
  }
}
