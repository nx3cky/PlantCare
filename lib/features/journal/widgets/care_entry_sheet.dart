import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/models/care_entry.dart';
import '../../../core/data/models/plant.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/care_type_style.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../core/widgets/plant_image.dart';
import '../../plants/widgets/form_parts.dart';
import '../bloc/journal_bloc.dart';
import '../care_actions.dart';

enum _SheetResult { saved, deleted }

/// ФВ-8 (Create, Update, Delete). Нижня панель із формою запису журналу:
/// тип процедури, рослина, дата й час, нотатка, фото.
class CareEntrySheet extends StatefulWidget {
  final CareEntry? entry;
  final String? plantId;
  final List<Plant> plants;

  const CareEntrySheet._({this.entry, this.plantId, required this.plants});

  /// Новий запис (за потреби – для рослини [plantId]) або редагування [entry].
  static Future<void> show(BuildContext context, {CareEntry? entry, String? plantId}) async {
    final plants = context.read<JournalBloc>().state.plants;
    if (plants.isEmpty) {
      context.showMessage('Спершу додайте рослину до каталогу', isError: true);
      return;
    }
    final result = await showModalBottomSheet<_SheetResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => CareEntrySheet._(entry: entry, plantId: plantId, plants: plants),
    );
    if (!context.mounted) return;
    switch (result) {
      case _SheetResult.saved:
        context.showMessage(entry == null ? 'Запис додано до журналу' : 'Запис оновлено');
      case _SheetResult.deleted:
        final plant = plants.where((p) => p.id == entry!.plantId).firstOrNull;
        CareActions.delete(context, entry!, plantName: plant?.name);
      case null:
        break;
    }
  }

  @override
  State<CareEntrySheet> createState() => _CareEntrySheetState();
}

class _CareEntrySheetState extends State<CareEntrySheet> {
  late CareType _type = widget.entry?.type ?? CareType.watering;
  late String _plantId = widget.entry?.plantId ?? widget.plantId ?? widget.plants.first.id;
  late DateTime _date = widget.entry?.performedAt ?? DateTime.now();
  late String? _photo = widget.entry?.photo;
  late final _notesController = TextEditingController(text: widget.entry?.notes);

  bool get _isNew => widget.entry == null;

  Plant get _plant => widget.plants.firstWhere((p) => p.id == _plantId, orElse: () => widget.plants.first);

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _date = DateTime(date.year, date.month, date.day, _date.hour, _date.minute));
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_date));
    if (time != null) setState(() => _date = DateTime(_date.year, _date.month, _date.day, time.hour, time.minute));
  }

  Future<void> _pickPhoto() async {
    final photo = await PlantPhotoPicker.show(context, selected: _photo);
    if (photo != null) setState(() => _photo = photo);
  }

  void _save() {
    final entry = CareEntry(
      id: widget.entry?.id ?? '',
      plantId: _plantId,
      type: _type,
      performedAt: _date,
      notes: _notesController.text.trim(),
      photo: _photo,
    );
    context.read<JournalBloc>().add(JournalEntrySaved(entry));
    Navigator.pop(context, _SheetResult.saved);
  }

  /// «Наступний полив буде заплановано на …» для процедур із періодичністю.
  String? get _nextHint {
    final interval = switch (_type) {
      CareType.watering => _plant.wateringIntervalDays,
      CareType.fertilizing => _plant.fertilizingIntervalDays,
      _ => null,
    };
    if (interval == null) return null;
    final next = DateFormatUa.addDays(_date, interval);
    final what = _type == CareType.watering ? 'Наступний полив буде заплановано' : 'Наступне підживлення буде заплановано';
    return '$what на ${DateFormatUa.date(next)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(_isNew ? 'Новий запис' : 'Редагування запису',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                ),
                IconButton(tooltip: 'Закрити', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Тип процедури',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.muted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in CareType.values)
                  ChoiceChip(
                    avatar: Icon(t.icon, color: t.color, size: 18),
                    label: Text(t.label),
                    selected: _type == t,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _type = t),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _plantId,
              decoration: const InputDecoration(labelText: 'Рослина'),
              items: [
                for (final p in widget.plants)
                  DropdownMenuItem(
                    value: p.id,
                    child: Row(
                      children: [
                        PlantImage(p.image, width: 32, height: 32, borderRadius: BorderRadius.circular(16)),
                        const SizedBox(width: 12),
                        Text(p.name, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _plantId = v ?? _plantId),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Дата', suffixIcon: Icon(Icons.calendar_today)),
                      child: Text(DateFormatUa.date(_date), style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: _pickTime,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Час'),
                      child: Text(DateFormatUa.time(_date), style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Нотатка', hintText: 'Напр., 500 мл, ґрунт був сухий'),
            ),
            if (_photo != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  PlantImage(_photo, width: 64, height: 64, borderRadius: BorderRadius.circular(12)),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Фото до запису', style: TextStyle(color: AppColors.muted))),
                  IconButton(
                    tooltip: 'Прибрати фото',
                    onPressed: () => setState(() => _photo = null),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.photo_camera),
                      label: Text(_photo == null ? 'Додати фото' : 'Змінити фото', style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check),
                      label: const Text('Зберегти', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
            if (_nextHint case final hint?) ...[
              const SizedBox(height: 12),
              Center(child: Text(hint, style: const TextStyle(fontSize: 13, color: AppColors.muted))),
            ],
            if (!_isNew) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  onPressed: () => Navigator.pop(context, _SheetResult.deleted),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Видалити запис'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
