import 'package:equatable/equatable.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/app_routes.dart';
import '../../core/data/models/care_entry.dart';
import '../../core/data/models/care_schedule.dart';
import '../../core/data/models/plant.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/care_type_style.dart';
import '../../core/utils/date_format.dart';
import '../../core/widgets/app_snack_bar.dart';
import '../../core/widgets/plant_image.dart';
import '../../core/widgets/section_header.dart';
import '../journal/bloc/journal_bloc.dart';
import '../journal/care_actions.dart';
import '../journal/widgets/care_entry_sheet.dart';
import '../shell/navigation_cubit.dart';
import 'bloc/plants_bloc.dart';
import 'widgets/care_rule_card.dart';
import 'widgets/plant_tiles.dart';

/// ФВ-7 (Read, Delete). Деталі рослини: фото у SliverAppBar, що згортається
/// під час прокручування, правила догляду, останні записи журналу,
/// відмітка поливу, редагування й видалення.
class PlantDetailsScreen extends StatefulWidget {
  final String plantId;

  const PlantDetailsScreen({super.key, required this.plantId});

  @override
  State<PlantDetailsScreen> createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> {
  static const _recentEntries = 3;

  @override
  void initState() {
    super.initState();
    context.read<PlantsBloc>().add(PlantViewed(widget.plantId));
  }

  Future<void> _delete(Plant plant, int entriesCount) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline, color: AppColors.error),
        title: Text('Видалити «${plant.name}»?'),
        content: Text(entriesCount == 0
            ? 'Рослину буде видалено з каталогу.'
            : 'Разом із рослиною буде видалено $entriesCount '
                '${DateFormatUa.plural(entriesCount, 'запис', 'записи', 'записів')} журналу догляду. '
                'Цю дію не можна скасувати.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Скасувати')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    context.read<PlantsBloc>().add(PlantDeleted(plant.id));
    Navigator.of(context).pop();
    context.showMessage('Рослину «${plant.name}» видалено');
  }

  void _openJournal(Plant plant) {
    context.read<JournalBloc>()
      ..add(const JournalFiltersReset())
      ..add(JournalPlantFilterChanged(plant.id));
    context.read<NavigationCubit>().select(AppTab.journal);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    // BlocSelector: екран перебудовується лише коли змінюється саме ця рослина
    // або її розклад (наприклад, після відмітки поливу чи редагування).
    return BlocSelector<PlantsBloc, PlantsState, _PlantData?>(
      selector: (state) {
        final plant = state.byId(widget.plantId);
        if (plant == null) return null;
        return _PlantData(
          plant,
          state.entries.where((e) => e.plantId == plant.id).toList(),
          DateFormatUa.dayOf(state.today),
        );
      },
      builder: (context, data) {
        if (data == null) return const Scaffold(body: Center(child: Text('Рослину не знайдено')));
        final plant = data.plant;
        final entries = data.entries;
        final schedule = CareSchedule.of(plant, entries, data.today);
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.surface,
                leading: Padding(
                  padding: const EdgeInsets.all(6),
                  child: _RoundButton(icon: Icons.arrow_back, tooltip: 'Назад', onPressed: () => Navigator.pop(context)),
                ),
                actions: [
                  _RoundButton(
                    icon: Icons.edit,
                    tooltip: 'Редагувати',
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.plantForm, arguments: plant),
                  ),
                  const SizedBox(width: 8),
                  _RoundButton(
                    icon: Icons.delete,
                    color: AppColors.error,
                    tooltip: 'Видалити',
                    onPressed: () => _delete(plant, entries.length),
                  ),
                  const SizedBox(width: 12),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: PlantImage(plant.image, width: double.infinity, height: double.infinity),
                ),
              ),
              SliverToBoxAdapter(child: _Header(schedule: schedule)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.05,
                  children: _ruleCards(schedule),
                ),
              ),
              if (plant.notes.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.sticky_note_2_outlined, color: AppColors.muted, size: 20),
                          const SizedBox(width: 10),
                          Expanded(child: Text(plant.notes, style: const TextStyle(fontSize: 14))),
                        ],
                      ),
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                sliver: SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Журнал догляду',
                    actionLabel: entries.isEmpty ? null : 'Усі записи',
                    onAction: () => _openJournal(plant),
                  ),
                ),
              ),
              if (entries.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 4, 20, 16),
                    child: Text('Записів ще немає', style: TextStyle(color: AppColors.muted)),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: entries.length.clamp(0, _recentEntries),
                  itemBuilder: (context, i) => _EntryRow(entry: entries[i], plant: plant),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                IconButton.filledTonal(
                  tooltip: 'Новий запис',
                  style: IconButton.styleFrom(fixedSize: const Size(56, 56)),
                  onPressed: () => CareEntrySheet.show(context, plantId: plant.id),
                  icon: const Icon(Icons.add, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: schedule.wateredToday == null
                        ? FilledButton.icon(
                            onPressed: () => CareActions.logNow(context, plant, CareType.watering),
                            icon: const Icon(Icons.water_drop),
                            label: const Text('Відмітити полив', style: TextStyle(fontSize: 17)),
                          )
                        : FilledButton.tonalIcon(
                            onPressed: null,
                            icon: const Icon(Icons.check),
                            label: Text('Полито о ${DateFormatUa.time(schedule.wateredToday!.performedAt)}',
                                style: const TextStyle(fontSize: 17)),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static List<Widget> _ruleCards(CareSchedule s) {
    final plant = s.plant;
    final feed = plant.fertilizingIntervalDays;
    return [
      CareRuleCard(
        icon: Icons.water_drop,
        title: 'Полив',
        value: 'кожні ${DateFormatUa.days(plant.wateringIntervalDays)}',
        note: 'Наступний: ${DateFormatUa.shortDate(s.nextWatering)}',
        color: AppColors.water,
        background: AppColors.waterContainer,
      ),
      CareRuleCard(
        icon: Icons.wb_sunny,
        title: 'Освітлення',
        value: plant.light.label.toLowerCase(),
        note: plant.light.hint,
        color: AppColors.sun,
        background: const Color(0xFFFFE9C7),
      ),
      CareRuleCard(
        icon: Icons.science,
        title: 'Підживлення',
        value: feed == null ? 'не потрібне' : 'раз на ${DateFormatUa.days(feed)}',
        note: feed == null ? '—' : 'Наступне: ${DateFormatUa.shortDate(s.nextFertilizing!)}',
        color: AppColors.primary,
        background: const Color(0xFFD4EDD0),
      ),
      CareRuleCard(
        icon: Icons.thermostat,
        title: 'Температура',
        value: '${plant.temperatureMin}–${plant.temperatureMax} °C',
        note: plant.temperatureMin < 15 ? 'Витримує прохолоду' : 'Без протягів',
        color: AppColors.error,
        background: const Color(0xFFFDE0DE),
      ),
    ];
  }
}

/// Частина стану PlantsBloc, потрібна екрану: Equatable порівнює списки
/// поелементно, тож BlocSelector не перебудовує екран через зміни інших рослин.
class _PlantData extends Equatable {
  final Plant plant;
  final List<CareEntry> entries;
  final DateTime today;

  const _PlantData(this.plant, this.entries, this.today);

  @override
  List<Object?> get props => [plant, entries, today];
}

class _Header extends StatelessWidget {
  final CareSchedule schedule;

  const _Header({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final plant = schedule.plant;
    Widget chip(String text, {Color bg = AppColors.secondaryContainer, Color fg = AppColors.onPrimaryContainer}) =>
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
          child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(plant.name, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
          if (plant.species.isNotEmpty)
            Text(plant.species, style: const TextStyle(fontSize: 16, color: AppColors.muted)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              chip(plant.location),
              WateringBadge(schedule),
              chip('З ${DateFormatUa.date(plant.acquiredAt)}', bg: AppColors.surfaceVariant, fg: AppColors.muted),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Правила догляду', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final CareEntry entry;
  final Plant plant;

  const _EntryRow({required this.entry, required this.plant});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: CareTypeIcon(entry.type, size: 44),
      title: Text(
        entry.notes.isEmpty ? entry.type.label : '${entry.type.label} · ${entry.notes}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(DateFormatUa.dateTime(entry.performedAt)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => CareEntrySheet.show(context, entry: entry),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color color;

  const _RoundButton({required this.icon, required this.tooltip, required this.onPressed, this.color = AppColors.text});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        fixedSize: const Size(44, 44),
      ),
      icon: Icon(icon, color: color),
    );
  }
}
