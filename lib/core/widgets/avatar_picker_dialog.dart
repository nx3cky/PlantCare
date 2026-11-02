import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/validators.dart';

/// Вибір фото профілю: готові аватари з HTTPS-посиланнями або власне
/// посилання з попереднім переглядом. Повертає вибране посилання або null.
/// Завантаження власних файлів у сховище – у ЛР6.
class AvatarPickerDialog extends StatefulWidget {
  final String? currentUrl;

  const AvatarPickerDialog({super.key, this.currentUrl});

  static const presets = <String>[
    'https://api.dicebear.com/9.x/adventurer/png?seed=Monstera&size=256',
    'https://api.dicebear.com/9.x/adventurer/png?seed=Ficus&size=256',
    'https://api.dicebear.com/9.x/adventurer/png?seed=Aloe&size=256',
    'https://api.dicebear.com/9.x/adventurer/png?seed=Cactus&size=256',
    'https://api.dicebear.com/9.x/adventurer/png?seed=Fern&size=256',
    'https://api.dicebear.com/9.x/adventurer/png?seed=Orchid&size=256',
  ];

  static Future<String?> show(BuildContext context, {String? currentUrl}) {
    return showDialog<String>(
      context: context,
      builder: (_) => AvatarPickerDialog(currentUrl: currentUrl),
    );
  }

  @override
  State<AvatarPickerDialog> createState() => _AvatarPickerDialogState();
}

class _AvatarPickerDialogState extends State<AvatarPickerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _urlController = TextEditingController(
    text: AvatarPickerDialog.presets.contains(widget.currentUrl) ? '' : widget.currentUrl,
  );
  late String? _selected = widget.currentUrl;
  bool _customMode = false;
  String? _preview;
  bool _previewFailed = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _showPreview() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _preview = _urlController.text.trim();
      _previewFailed = false;
    });
  }

  void _save() {
    if (_customMode) {
      if (_preview == null || _previewFailed) return;
      Navigator.of(context).pop(_preview);
    } else if (_selected != null) {
      Navigator.of(context).pop(_selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _customMode
        ? _preview != null && !_previewFailed
        : _selected != null && _selected != widget.currentUrl;

    return AlertDialog(
      title: const Text('Фото профілю'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Готові')),
                  ButtonSegment(value: true, label: Text('Посилання')),
                ],
                selected: {_customMode},
                onSelectionChanged: (s) => setState(() => _customMode = s.first),
              ),
              const SizedBox(height: 16),
              if (_customMode) _buildCustom() else _buildPresets(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Скасувати')),
        FilledButton(onPressed: canSave ? _save : null, child: const Text('Зберегти')),
      ],
    );
  }

  Widget _buildPresets() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        for (final url in AvatarPickerDialog.presets)
          GestureDetector(
            onTap: () => setState(() => _selected = url),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _selected == url ? AppColors.primary : Colors.transparent,
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.primaryContainer,
                foregroundImage: NetworkImage(url),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCustom() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            validator: Validators.photoUrl,
            decoration: InputDecoration(
              labelText: 'HTTPS-посилання на зображення',
              suffixIcon: IconButton(
                tooltip: 'Переглянути',
                icon: const Icon(Icons.visibility),
                onPressed: _showPreview,
              ),
            ),
            onChanged: (_) => setState(() => _preview = null),
            onFieldSubmitted: (_) => _showPreview(),
          ),
          const SizedBox(height: 16),
          Center(
            child: _preview == null
                ? const Text('Натисніть 👁, щоб переглянути фото',
                    style: TextStyle(color: AppColors.muted))
                : ClipOval(
                    child: Image.network(
                      _preview!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : const SizedBox(
                              width: 120,
                              height: 120,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                      errorBuilder: (_, _, _) {
                        if (!_previewFailed) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => mounted ? setState(() => _previewFailed = true) : null,
                          );
                        }
                        return const SizedBox(
                          width: 120,
                          height: 120,
                          child: Center(
                            child: Text('Не вдалося\nзавантажити',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.error)),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
