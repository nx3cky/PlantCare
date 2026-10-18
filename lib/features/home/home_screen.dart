import 'package:flutter/material.dart';

import '../../core/data/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/care_task_card.dart';
import '../../core/widgets/plant_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/user_avatar.dart';

/// Головний екран: привітання, пошук, лічильники, догляд на сьогодні, мої рослини.
class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onOpenTab;

  const HomeScreen({super.key, required this.onOpenTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Hardcoded-дані замість запиту до сервера.
  static const String _userName = MockUser.firstName;
  static const int _plantsCount = MockUser.plantsCount;

  final Set<int> _doneTasks = {};

  int get _overdueCount => [
        for (var i = 0; i < todayTasks.length; i++)
          if (todayTasks[i].overdue && !_doneTasks.contains(i)) i,
      ].length;

  void _toggleTask(int index) {
    setState(() {
      if (!_doneTasks.remove(index)) _doneTasks.add(index);
    });
  }

  void _showNotImplemented(String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what – буде реалізовано в наступних ЛР')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Додати рослину',
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimaryContainer,
        onPressed: () => _showNotImplemented('Додавання рослини'),
        child: const Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            _buildGreeting(),
            const SizedBox(height: 16),
            SearchBar(
              hintText: 'Пошук рослин або процедур',
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: const WidgetStatePropertyAll(AppColors.surfaceVariant),
              leading: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.search, color: AppColors.muted),
              ),
              trailing: [
                IconButton(
                  tooltip: 'Фільтри',
                  onPressed: () => _showNotImplemented('Фільтри'),
                  icon: const Icon(Icons.tune, color: AppColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: StatCard(title: 'Рослин', value: _plantsCount, icon: Icons.eco, iconColor: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'Сьогодні',
                    value: todayTasks.length - _doneTasks.length,
                    icon: Icons.water_drop,
                    iconColor: AppColors.water,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'Прострочено',
                    value: _overdueCount,
                    icon: Icons.warning_rounded,
                    iconColor: AppColors.error,
                    alert: _overdueCount > 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SectionHeader(title: 'Догляд на сьогодні', actionLabel: 'Усі', onAction: () => widget.onOpenTab(2)),
            const SizedBox(height: 4),
            for (var i = 0; i < todayTasks.length; i++) ...[
              CareTaskCard(task: todayTasks[i], done: _doneTasks.contains(i), onToggle: () => _toggleTask(i)),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
            SectionHeader(title: 'Мої рослини', actionLabel: 'Каталог', onAction: () => widget.onOpenTab(1)),
            const SizedBox(height: 4),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: myPlants.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) => PlantCard(
                  plant: myPlants[i],
                  onTap: () => _showNotImplemented('Картка «${myPlants[i].name}»'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Доброго ранку,', style: TextStyle(fontSize: 15, color: AppColors.muted)),
              Text(
                _userName,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.text),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Сповіщення',
          onPressed: () => _showNotImplemented('Сповіщення'),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceVariant,
            fixedSize: const Size(48, 48),
          ),
          icon: const Badge(
            smallSize: 8,
            child: Icon(Icons.notifications, color: AppColors.text),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => widget.onOpenTab(3),
          child: const UserAvatar(initials: MockUser.initials),
        ),
      ],
    );
  }
}
