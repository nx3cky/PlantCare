import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/data/models/care_entry.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/care_type_style.dart';
import '../../core/utils/date_format.dart';
import 'bloc/journal_bloc.dart';
import 'care_actions.dart';
import 'widgets/care_entry_card.dart';
import 'widgets/care_entry_sheet.dart';

/// ФВ-8, ФВ-9. Журнал догляду: записи згруповані за днями (для кожного дня –
/// заголовок SliverToBoxAdapter і SliverList), фільтри за типом процедури,
/// рослиною та місяцем, пошук; свайп видаляє запис із можливістю скасування.
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  // Відкрите поле пошуку – ефемерний стан екрана.
  bool _searching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-entry',
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimaryContainer,
        onPressed: () => CareEntrySheet.show(context, plantId: context.read<JournalBloc>().state.plantId),
        icon: const Icon(Icons.add),
        label: const Text('Новий запис', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: BlocBuilder<JournalBloc, JournalState>(
          builder: (context, state) {
            final bloc = context.read<JournalBloc>();
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text('Журнал догляду', style: TextStyle(fontSize: 26, color: AppColors.text)),
                        ),
                        IconButton(
                          tooltip: 'Пошук',
                          onPressed: () {
                            if (_searching) bloc.add(const JournalQueryChanged(''));
                            setState(() => _searching = !_searching);
                          },
                          icon: Icon(_searching ? Icons.search_off : Icons.search),
                        ),
                        IconButton(
                          tooltip: 'Скинути фільтри',
                          onPressed: state.hasFilters
                              ? () {
                                  setState(() => _searching = false);
                                  bloc.add(const JournalFiltersReset());
                                }
                              : null,
                          icon: const Icon(Icons.filter_alt_off),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_searching)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: TextField(
                        autofocus: true,
                        onChanged: (q) => bloc.add(JournalQueryChanged(q)),
                        decoration: const InputDecoration(
                          hintText: 'Рослина, процедура або нотатка',
                          prefixIcon: Icon(Icons.search),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(child: _TypeChips(selected: state.type)),
                SliverToBoxAdapter(child: _PlantAndMonthFilters(state: state)),
                if (state.status == JournalStatus.loading)
                  const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                else if (state.days.isEmpty)
                  SliverFillRemaining(hasScrollBody: false, child: _EmptyJournal(filtered: state.entries.isNotEmpty))
                else
                  for (final day in state.days) ..._daySlivers(context, state, day),
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _daySlivers(BuildContext context, JournalState state, JournalDay day) => [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              DateFormatUa.dayHeader(day.day, state.today).toUpperCase(),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.muted),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.separated(
            itemCount: day.entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _dismissible(context, state, day.entries[i]),
          ),
        ),
      ];

  Widget _dismissible(BuildContext context, JournalState state, CareEntry entry) {
    final plant = state.plantsById[entry.plantId];
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(color: AppColors.errorContainer, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete, color: AppColors.error),
      ),
      onDismissed: (_) => CareActions.delete(context, entry, plantName: plant?.name),
      child: CareEntryCard(
        entry: entry,
        plant: plant,
        onTap: () => CareEntrySheet.show(context, entry: entry),
      ),
    );
  }
}

/// Чипи типів процедур у горизонтальному ListView.
class _TypeChips extends StatelessWidget {
  final CareType? selected;

  const _TypeChips({required this.selected});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<JournalBloc>();
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ChoiceChip(
            label: const Text('Усі'),
            selected: selected == null,
            onSelected: (_) => bloc.add(const JournalTypeFilterChanged(null)),
          ),
          for (final t in CareType.values) ...[
            const SizedBox(width: 8),
            ChoiceChip(
              avatar: Icon(t.icon, color: t.color, size: 18),
              label: Text(t.label),
              selected: selected == t,
              showCheckmark: false,
              onSelected: (sel) => bloc.add(JournalTypeFilterChanged(sel ? t : null)),
            ),
          ],
        ],
      ),
    );
  }
}

/// «Рослина: усі» і «Жовтень 2026» – меню вибору рослини та місяця.
class _PlantAndMonthFilters extends StatelessWidget {
  final JournalState state;

  const _PlantAndMonthFilters({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<JournalBloc>();
    final plant = state.plantId == null ? null : state.plantsById[state.plantId];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          Flexible(
            child: PopupMenuButton<String>(
              tooltip: 'Рослина',
              onSelected: (id) => bloc.add(JournalPlantFilterChanged(id.isEmpty ? null : id)),
              itemBuilder: (_) => [
                const PopupMenuItem(value: '', child: Text('Усі рослини')),
                for (final p in state.plants) PopupMenuItem(value: p.id, child: Text(p.name)),
              ],
              child: _DropdownChip(
                icon: Icons.eco,
                label: plant == null ? 'Рослина: усі' : plant.name,
                active: plant != null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: PopupMenuButton<int>(
              tooltip: 'Місяць',
              onSelected: (i) => bloc.add(JournalMonthFilterChanged(i < 0 ? null : state.months[i])),
              itemBuilder: (_) => [
                const PopupMenuItem(value: -1, child: Text('Увесь час')),
                for (var i = 0; i < state.months.length; i++)
                  PopupMenuItem(value: i, child: Text(DateFormatUa.monthYear(state.months[i]))),
              ],
              child: _DropdownChip(
                icon: Icons.calendar_month,
                label: state.month == null ? 'Увесь час' : DateFormatUa.monthYear(state.month!),
                active: state.month != null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _DropdownChip({required this.icon, required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: active ? AppColors.secondaryContainer : null,
        border: Border.all(color: active ? AppColors.secondaryContainer : AppColors.outlineStrong),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.muted),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          const Icon(Icons.arrow_drop_down, color: AppColors.muted),
        ],
      ),
    );
  }
}

class _EmptyJournal extends StatelessWidget {
  final bool filtered;

  const _EmptyJournal({required this.filtered});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(filtered ? Icons.search_off : Icons.article_outlined, size: 56, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(filtered ? 'Записів не знайдено' : 'Журнал порожній',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            filtered ? 'Змініть фільтри або скиньте їх' : 'Відмічайте процедури догляду кнопкою «Новий запис»',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
