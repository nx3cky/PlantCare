import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/data/models/plant.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_format.dart';
import '../../core/widgets/app_snack_bar.dart';
import '../../core/widgets/plant_image.dart';
import 'bloc/plants_bloc.dart';
import 'widgets/form_parts.dart';

/// ФВ-7 (Create, Update). Форма нової рослини або редагування існуючої.
/// Значення полів – ефемерний стан форми (StatefulWidget); у стан застосунку
/// рослина потрапляє лише після «Зберегти» через подію [PlantSaved].
class PlantFormScreen extends StatefulWidget {
  /// null – створення нової рослини.
  final Plant? plant;

  const PlantFormScreen({super.key, this.plant});

  @override
  State<PlantFormScreen> createState() => _PlantFormScreenState();
}

class _PlantFormScreenState extends State<PlantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Plant _initial = widget.plant ?? Plant(id: '', name: '', acquiredAt: DateFormatUa.dayOf(DateTime.now()));
  late final _nameController = TextEditingController(text: _initial.name);
  late final _speciesController = TextEditingController(text: _initial.species);
  late final _notesController = TextEditingController(text: _initial.notes);
  late String? _image = _initial.image;
  late String _location = _initial.location;
  late DateTime _acquiredAt = _initial.acquiredAt;
  late int _watering = _initial.wateringIntervalDays;
  late int _feeding = _initial.fertilizingIntervalDays ?? 0;
  late LightLevel _light = _initial.light;
  late RangeValues _temperature =
      RangeValues(_initial.temperatureMin.toDouble(), _initial.temperatureMax.toDouble());

  bool get _isNew => widget.plant == null;

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Plant _buildPlant() => _initial.copyWith(
        name: _nameController.text.trim(),
        species: _speciesController.text.trim(),
        location: _location,
        image: () => _image,
        acquiredAt: _acquiredAt,
        wateringIntervalDays: _watering,
        fertilizingIntervalDays: () => _feeding == 0 ? null : _feeding,
        light: _light,
        temperatureMin: _temperature.start.round(),
        temperatureMax: _temperature.end.round(),
        notes: _notesController.text.trim(),
      );

  bool get _dirty => _buildPlant() != _initial;

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final plant = _buildPlant();
    context.read<PlantsBloc>().add(PlantSaved(plant));
    Navigator.of(context).pop();
    context.showMessage(_isNew ? 'Рослину «${plant.name}» додано' : 'Зміни збережено');
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _acquiredAt,
      firstDate: DateTime(2000),
      lastDate: now,
      helpText: 'Дата появи рослини',
    );
    if (date != null) setState(() => _acquiredAt = date);
  }

  Future<void> _pickPhoto() async {
    final image = await PlantPhotoPicker.show(context, selected: _image);
    if (image != null) setState(() => _image = image);
  }

  void _notAvailable(String source) =>
      context.showMessage('$source стане доступною після інтеграції image_picker і Firebase Storage');

  /// Закриття форми зі змінами – з підтвердженням.
  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Скасувати зміни?'),
        content: const Text('Введені дані не буде збережено.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Продовжити')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Скасувати зміни')),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _dirty ? _confirmDiscard() : Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          leading: IconButton(
            tooltip: 'Закрити',
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(_isNew ? 'Нова рослина' : 'Редагування', style: const TextStyle(fontSize: 24)),
          actions: [
            TextButton(
              onPressed: _save,
              child: const Text('Зберегти', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              const Text('Фото рослини',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.muted)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _PhotoPreview(image: _image, onTap: _pickPhoto),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PhotoSourceTile(icon: Icons.photo_camera, label: 'Камера', onTap: () => _notAvailable('Камера')),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PhotoSourceTile(icon: Icons.image, label: 'Галерея', onTap: () => _notAvailable('Галерея')),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                autofocus: _isNew,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Назва *'),
                style: const TextStyle(fontSize: 17),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) {
                  final text = v?.trim() ?? '';
                  if (text.isEmpty) return 'Введіть назву рослини';
                  if (text.length < 2) return 'Назва має містити щонайменше 2 символи';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _speciesController,
                decoration: const InputDecoration(labelText: 'Вид (латинська назва)'),
                style: const TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _location,
                      decoration: const InputDecoration(labelText: 'Розташування'),
                      items: [for (final l in Plant.locations) DropdownMenuItem(value: l, child: Text(l))],
                      onChanged: (v) => setState(() => _location = v ?? _location),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Дата появи',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(DateFormatUa.date(_acquiredAt), style: const TextStyle(fontSize: 17)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Правила догляду', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              CareRuleRow(
                icon: Icons.water_drop,
                color: AppColors.water,
                background: AppColors.waterContainer,
                title: 'Полив',
                trailing: IntervalStepper(value: _watering, onChanged: (v) => setState(() => _watering = v)),
              ),
              CareRuleRow(
                icon: Icons.science,
                color: AppColors.primary,
                background: const Color(0xFFD4EDD0),
                title: 'Підживлення',
                trailing: IntervalStepper(
                  value: _feeding,
                  min: 0,
                  max: 120,
                  onChanged: (v) => setState(() => _feeding = v),
                ),
              ),
              CareRuleRow(
                icon: Icons.wb_sunny,
                color: AppColors.sun,
                background: const Color(0xFFFFE9C7),
                title: 'Освітлення',
                trailing: const SizedBox.shrink(),
              ),
              SegmentedButton<LightLevel>(
                segments: [
                  for (final l in LightLevel.values) ButtonSegment(value: l, label: Text(l.label)),
                ],
                selected: {_light},
                onSelectionChanged: (s) => setState(() => _light = s.first),
              ),
              CareRuleRow(
                icon: Icons.thermostat,
                color: AppColors.error,
                background: const Color(0xFFFDE0DE),
                title: 'Температура',
                trailing: Text(
                  '${_temperature.start.round()}–${_temperature.end.round()} °C',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              RangeSlider(
                values: _temperature,
                min: 5,
                max: 35,
                divisions: 30,
                labels: RangeLabels('${_temperature.start.round()} °C', '${_temperature.end.round()} °C'),
                onChanged: (v) => setState(() => _temperature = v),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Нотатки', alignLabelWithHint: true),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  final String? image;
  final VoidCallback onTap;

  const _PhotoPreview({required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 104,
        height: 104,
        child: Stack(
          children: [
            PlantImage(image, width: 104, height: 104, borderRadius: BorderRadius.circular(16)),
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(image == null ? Icons.add : Icons.edit, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
