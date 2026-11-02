import 'package:flutter/material.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../auth/data/auth_failure.dart';

/// Валідатор поля діалогу; [values] – поточні значення всіх полів форми.
typedef DialogValidator = String? Function(String? value, List<String> values);

/// Поле діалогу: мітка, валідатор, чи це пароль, початкове значення.
class DialogField {
  final String label;
  final DialogValidator validator;
  final bool isPassword;
  final String? initialValue;

  const DialogField({
    required this.label,
    required this.validator,
    this.isPassword = false,
    this.initialValue,
  });
}

/// Діалог із формою для коротких змін профілю (ім'я, створення пароля).
/// Під час запиту поля й кнопки заблоковані, помилка показується в діалозі.
class ProfileFormDialog extends StatefulWidget {
  final String title;
  final List<DialogField> fields;
  final String submitLabel;
  final Future<void> Function(List<String> values) onSubmit;

  const ProfileFormDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.onSubmit,
    this.submitLabel = 'Зберегти',
  });

  /// Повертає true, якщо [onSubmit] завершився успішно.
  Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => this,
    );
    return result ?? false;
  }

  /// ФВ-4. Редагування імені.
  factory ProfileFormDialog.editName({
    required String? current,
    required Future<void> Function(String name) save,
  }) {
    return ProfileFormDialog(
      title: 'Особисті дані',
      fields: [
        DialogField(
          label: 'Ім’я та прізвище',
          initialValue: current,
          validator: (value, _) => Validators.name(value),
        ),
      ],
      onSubmit: (v) => save(v[0]),
    );
  }

  /// Створення пароля для акаунта Google (прив'язка способу входу).
  factory ProfileFormDialog.createPassword({
    required Future<void> Function(String password) save,
  }) {
    return ProfileFormDialog(
      title: 'Вхід за паролем',
      submitLabel: 'Створити',
      fields: [
        DialogField(
          label: 'Новий пароль',
          isPassword: true,
          validator: (value, _) => Validators.newPassword(value),
        ),
        DialogField(
          label: 'Підтвердження пароля',
          isPassword: true,
          validator: (value, values) => Validators.confirmPassword(() => values[0])(value),
        ),
      ],
      onSubmit: (v) => save(v[0]),
    );
  }

  @override
  State<ProfileFormDialog> createState() => _ProfileFormDialogState();
}

class _ProfileFormDialogState extends State<ProfileFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controllers = [
    for (final f in widget.fields) TextEditingController(text: f.initialValue),
  ];
  bool _loading = false;
  String? _error;

  List<String> get _values => [for (final c in _controllers) c.text];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.onSubmit(_values);
      if (mounted) Navigator.of(context).pop(true);
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < widget.fields.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                AppTextField(
                  label: widget.fields[i].label,
                  isPassword: widget.fields[i].isPassword,
                  controller: _controllers[i],
                  validator: (value) => widget.fields[i].validator(value, _values),
                  enabled: !_loading,
                  autofocus: i == 0,
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Скасувати'),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.submitLabel),
        ),
      ],
    );
  }
}
