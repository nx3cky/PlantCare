import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/app_routes.dart';
import '../../core/data/models/app_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_format.dart';
import 'bloc/plants_bloc.dart';
import 'widgets/plant_tiles.dart';

/// ФВ-7, ФВ-9. Каталог рослин: CustomScrollView зі слайверами –
/// SliverAppBar, пошук і фільтри (SliverToBoxAdapter), а самі рослини –
/// сіткою (SliverGrid) або списком (SliverList) на вибір користувача.
class PlantsScreen extends StatelessWidget {
  const PlantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-plant',
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.plantForm),
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimaryContainer,
        icon: const Icon(Icons.add),
        label: const Text('Рослина', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: BlocBuilder<PlantsBloc, PlantsState>(
        builder: (context, state) {
          final bloc = context.read<PlantsBloc>();
          final plants = state.visiblePlants;
          final needCare = state.plants.where((p) => state.scheduleOf(p).todayTasks.any((t) => !t.done)).length;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: AppColors.surface,
                surfaceTintColor: Colors.transparent,
                title: const Text('Мої рослини', style: TextStyle(fontSize: 26, color: AppColors.text)),
                actions: [
                  IconButton(
                    tooltip: state.asGrid ? 'Показати списком' : 'Показати сіткою',
                    onPressed: () => bloc.add(const PlantsViewModeToggled()),
                    icon: Icon(state.asGrid ? Icons.view_list : Icons.grid_view),
                  ),
                  PopupMenuButton<PlantSort>(
                    tooltip: 'Сортування',
                    icon: const Icon(Icons.sort),
                    initialValue: state.sort,
                    onSelected: (sort) => bloc.add(PlantsSortChanged(sort)),
                    itemBuilder: (_) => [
                      for (final s in PlantSort.values) CheckedPopupMenuItem(value: s, checked: s == state.sort, child: Text(s.label)),
                    ],
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: _SearchField(
                    query: state.query,
                    onChanged: (q) => bloc.add(PlantsQueryChanged(q)),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      FilterChip(
                        avatar: const Icon(Icons.water_drop, size: 18, color: AppColors.water),
                        label: Text('Потребують догляду ($needCare)'),
                        selected: state.onlyNeedsCare,
                        showCheckmark: false,
                        onSelected: (_) => bloc.add(const PlantsNeedsCareFilterToggled()),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Усі кімнати'),
                        selected: state.location == null,
                        onSelected: (_) => bloc.add(const PlantsLocationFilterChanged(null)),
                      ),
                      for (final l in state.usedLocations) ...[
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(l),
                          selected: state.location == l,
                          onSelected: (sel) => bloc.add(PlantsLocationFilterChanged(sel ? l : null)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Text(
                    '${plants.length} ${DateFormatUa.plural(plants.length, 'рослина', 'рослини', 'рослин')}'
                    ' · ${state.sort.label.toLowerCase()}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.muted),
                  ),
                ),
              ),
              if (state.status == PlantsStatus.loading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else if (plants.isEmpty)
                SliverFillRemaining(hasScrollBody: false, child: _EmptyCatalog(filtered: state.plants.isNotEmpty))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  sliver: state.asGrid
                      ? SliverGrid.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.74,
                          ),
                          itemCount: plants.length,
                          itemBuilder: (context, i) => PlantGridTile(
                            schedule: state.scheduleOf(plants[i]),
                            onTap: () => _open(context, plants[i].id),
                          ),
                        )
                      : SliverList.separated(
                          itemCount: plants.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, i) => PlantListTile(
                            schedule: state.scheduleOf(plants[i]),
                            onTap: () => _open(context, plants[i].id),
                          ),
                        ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _open(BuildContext context, String id) =>
      Navigator.of(context).pushNamed(AppRoutes.plantDetails, arguments: id);
}

/// Поле пошуку з власним контролером; синхронізується, якщо запит
/// змінено ззовні (пошук із головного екрана).
class _SearchField extends StatefulWidget {
  final String query;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.query, required this.onChanged});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final _controller = TextEditingController(text: widget.query);

  @override
  void didUpdateWidget(covariant _SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) _controller.text = widget.query;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Назва, вид або нотатка',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        suffixIcon: widget.query.isEmpty
            ? null
            : IconButton(
                tooltip: 'Очистити',
                icon: const Icon(Icons.close),
                onPressed: () => widget.onChanged(''),
              ),
      ),
    );
  }
}

class _EmptyCatalog extends StatelessWidget {
  final bool filtered;

  const _EmptyCatalog({required this.filtered});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(filtered ? Icons.search_off : Icons.eco, size: 56, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            filtered ? 'Нічого не знайдено' : 'Каталог порожній',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            filtered ? 'Змініть запит або фільтри' : 'Додайте першу рослину кнопкою «Рослина»',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
