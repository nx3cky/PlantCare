import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/app_routes.dart';
import '../../core/data/models/care_schedule.dart';
import '../../core/data/models/plant.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_format.dart';
import '../../core/widgets/app_snack_bar.dart';
import '../../core/widgets/care_task_card.dart';
import '../../core/widgets/plant_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/user_avatar.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/data/app_user.dart';
import '../journal/bloc/journal_bloc.dart';
import '../journal/care_actions.dart';
import '../plants/bloc/plants_bloc.dart';
import '../shell/navigation_cubit.dart';

/// ФВ-6. Головний екран: привітання, пошук, лічильники, догляд на сьогодні,
/// рослини за найближчим поливом і нещодавно переглянуті.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openTab(BuildContext context, AppTab tab) => context.read<NavigationCubit>().select(tab);

  void _openPlant(BuildContext context, Plant plant) =>
      Navigator.of(context).pushNamed(AppRoutes.plantDetails, arguments: plant.id);

  void _toggleTask(BuildContext context, CareTask task) {
    if (task.done) {
      context.read<JournalBloc>().add(JournalEntryDeleted(task.doneEntry!));
      context.showMessage('Відмітку «${task.type.label} · ${task.plant.name}» скасовано');
    } else {
      CareActions.logNow(context, task.plant, task.type);
    }
  }

  void _search(BuildContext context, String query) {
    context.read<PlantsBloc>().add(PlantsQueryChanged(query));
    _openTab(context, AppTab.plants);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Додати рослину',
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimaryContainer,
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.plantForm),
        child: const Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        child: BlocBuilder<PlantsBloc, PlantsState>(
          builder: (context, state) {
            if (state.status == PlantsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            final tasks = state.todayTasks;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                const _Greeting(),
                const SizedBox(height: 16),
                SearchBar(
                  hintText: 'Пошук рослин',
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: const WidgetStatePropertyAll(AppColors.surfaceVariant),
                  leading: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.search, color: AppColors.muted),
                  ),
                  onSubmitted: (q) => _search(context, q),
                  trailing: [
                    IconButton(
                      tooltip: 'Фільтри',
                      onPressed: () => _openTab(context, AppTab.plants),
                      icon: const Icon(Icons.tune, color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Рослин',
                        value: state.plants.length,
                        icon: Icons.eco,
                        iconColor: AppColors.primary,
                        onTap: () => _openTab(context, AppTab.plants),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        title: 'Сьогодні',
                        value: state.pendingTaskCount,
                        icon: Icons.water_drop,
                        iconColor: AppColors.water,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        title: 'Прострочено',
                        value: state.overdueCount,
                        icon: Icons.warning_rounded,
                        iconColor: AppColors.error,
                        alert: state.overdueCount > 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SectionHeader(
                  title: 'Догляд на сьогодні',
                  actionLabel: 'Журнал',
                  onAction: () => _openTab(context, AppTab.journal),
                ),
                const SizedBox(height: 4),
                if (tasks.isEmpty)
                  const _EmptyHint('На сьогодні все зроблено – рослини доглянуті')
                else
                  for (final task in tasks) ...[
                    CareTaskCard(
                      task: task,
                      onToggle: () => _toggleTask(context, task),
                      onTap: () => _openPlant(context, task.plant),
                    ),
                    const SizedBox(height: 10),
                  ],
                const SizedBox(height: 8),
                SectionHeader(
                  title: 'Мої рослини',
                  actionLabel: 'Каталог',
                  onAction: () => _openTab(context, AppTab.plants),
                ),
                const SizedBox(height: 4),
                if (state.plants.isEmpty)
                  const _EmptyHint('Додайте першу рослину кнопкою «+»')
                else
                  _PlantStrip(plants: state.byNextWatering, state: state, onTap: (p) => _openPlant(context, p)),
                const SizedBox(height: 8),
                SectionHeader(
                  title: 'Нещодавно переглянуті',
                  actionLabel: state.recentPlants.isEmpty ? null : 'Очистити',
                  onAction: () => context.read<PlantsBloc>().add(const PlantsRecentCleared()),
                ),
                const SizedBox(height: 4),
                if (state.recentPlants.isEmpty)
                  const _EmptyHint('Відкрийте рослину, щоб вона з’явилася тут')
                else
                  _PlantStrip(plants: state.recentPlants, state: state, onTap: (p) => _openPlant(context, p)),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Горизонтальний список карток рослин (ListView.separated).
class _PlantStrip extends StatelessWidget {
  final List<Plant> plants;
  final PlantsState state;
  final ValueChanged<Plant> onTap;

  const _PlantStrip({required this.plants, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: plants.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final schedule = state.scheduleOf(plants[i]);
          return PlantCard(
            plant: plants[i],
            subtitle: 'Полив · ${DateFormatUa.relative(schedule.daysToWatering)}',
            alert: schedule.daysToWatering < 0,
            onTap: () => onTap(plants[i]),
          );
        },
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;

  const _EmptyHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(text, style: const TextStyle(fontSize: 14, color: AppColors.muted)),
    );
  }
}

/// Привітання з ім'ям і аватаром: перебудовується лише при зміні користувача.
class _Greeting extends StatelessWidget {
  const _Greeting();

  static String _greetingFor(DateTime now) => switch (now.hour) {
        >= 5 && < 12 => 'Доброго ранку,',
        >= 12 && < 18 => 'Доброго дня,',
        _ => 'Доброго вечора,',
      };

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, AppUser?>((bloc) => bloc.state.user);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greetingFor(DateTime.now()), style: const TextStyle(fontSize: 15, color: AppColors.muted)),
              Text(
                user?.firstName ?? '',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.text),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Сповіщення',
          onPressed: () => context.showMessage('Сповіщення з’являться разом із Firebase Cloud Messaging'),
          style: IconButton.styleFrom(backgroundColor: AppColors.surfaceVariant, fixedSize: const Size(48, 48)),
          icon: const Badge(smallSize: 8, child: Icon(Icons.notifications, color: AppColors.text)),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => context.read<NavigationCubit>().select(AppTab.profile),
          child: UserAvatar(
            initials: UserAvatar.initialsOf(user?.displayName, user?.email),
            photoUrl: user?.photoUrl,
          ),
        ),
      ],
    );
  }
}
