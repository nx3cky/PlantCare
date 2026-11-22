import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../bloc/profile_bloc.dart';

/// Валідатор поля діалогу; [values] – поточні значення всіх полів форми.
typedef DialogValidator = String? Function(String? value, List<String> values);

/// Поле діалогу: мітка, валідатор, чи це пароль, початкове значення.
class DialogField {
  final String label;
  final DialogValidator validator;
  final bool isPassword;
  final String? initialValue;

  const DialogField({required this.label, required this.validator, this.isPassword = false, this.initialValue});
}

/// Діалог із формою для коротких змін профілю (ім'я, створення пароля).
/// Надсилає подію в [ProfileBloc] і слухає результат операції [action]:
/// під час запиту поля заблоковані, помилка показується в діалозі,
/// а після успіху діалог закривається.
class ProfileFormDialog extends StatefulWidget {
  final String title;
  final List<DialogField> fields;
  final String submitLabel;
  final ProfileAction action;
  final ProfileEvent Function(List<String> values) toEvent;

  const ProfileFormDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.action,
    required this.toEvent,
    this.submitLabel = 'Зберегти',
  });

  /// Повертає true, якщо операцію виконано успішно.
  Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(context: context, barrierDismissible: false, builder: (_) => this);
    return result ?? false;
  }

  /// ФВ-4. Редагування імені.
  factory ProfileFormDialog.editName({required String? current}) => ProfileFormDialog(
        title: 'Особисті дані',
        action: ProfileAction.name,
        fields: [
          DialogField(
            label: 'Ім’я та прізвище',
            initialValue: current,
            validator: (value, _) => Validators.name(value),
          ),
        ],
        toEvent: (v) => ProfileNameChanged(v[0]),
      );

  /// Створення пароля для акаунта Google (прив'язка способу входу).
  factory ProfileFormDialog.createPassword() => ProfileFormDialog(
        title: 'Вхід за паролем',
        submitLabel: 'Створити',
        action: ProfileAction.createPassword,
        fields: [
          DialogField(label: 'Новий пароль', isPassword: true, validator: (value, _) => Validators.newPassword(value)),
          DialogField(
            label: 'Підтвердження пароля',
            isPassword: true,
            validator: (value, values) => Validators.confirmPassword(() => values[0])(value),
          ),
        ],
        toEvent: (v) => ProfilePasswordCreated(v[0]),
      );

  @override
  State<ProfileFormDialog> createState() => _ProfileFormDialogState();
}

class _ProfileFormDialogState extends State<ProfileFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controllers = [for (final f in widget.fields) TextEditingController(text: f.initialValue)];
  String? _error;

  List<String> get _values => [for (final c in _controllers) c.text];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    context.read<ProfileBloc>().add(widget.toEvent(_values));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (prev, curr) => curr.notice != prev.notice && curr.notice?.action == widget.action,
      listener: (context, state) {
        final notice = state.notice!;
        notice.isError ? setState(() => _error = notice.message) : Navigator.of(context).pop(true);
      },
      buildWhen: (prev, curr) => prev.action != curr.action,
      builder: (context, state) {
        final loading = state.action == widget.action;
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
                      enabled: !loading,
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
              onPressed: loading ? null : () => Navigator.of(context).pop(false),
              child: const Text('Скасувати'),
            ),
            FilledButton(
              onPressed: loading ? null : _submit,
              child: loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(widget.submitLabel),
            ),
          ],
        );
      },
    );
  }
}
