import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/settings_tile.dart';
import '../../auth/data/auth_failure.dart';
import '../../auth/data/auth_repository.dart';

/// ФВ-4. Розгортна картка зміни пароля для акаунтів із входом за email.
class ChangePasswordCard extends StatefulWidget {
  const ChangePasswordCard({super.key});

  @override
  State<ChangePasswordCard> createState() => _ChangePasswordCardState();
}

class _ChangePasswordCardState extends State<ChangePasswordCard> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _expanded = false;
  bool _loading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await AuthRepository.instance.changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
      if (!mounted) return;
      _formKey.currentState!.reset();
      _currentController.clear();
      _newController.clear();
      _confirmController.clear();
      setState(() => _expanded = false);
      context.showMessage('Пароль успішно змінено');
    } on AuthFailure catch (e) {
      if (!mounted) return;
      if (e.requiresRecentLogin) {
        await _showReloginDialog();
      } else {
        context.showMessage(e.message, isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Firebase повернув requires-recent-login: пропонуємо увійти повторно.
  Future<void> _showReloginDialog() async {
    final relogin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.lock_clock, color: AppColors.primary),
        title: const Text('Потрібен повторний вхід'),
        content: const Text(
          'З міркувань безпеки змінити пароль можна лише після нещодавнього входу. '
          'Увійдіть знову й повторіть операцію.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Пізніше')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Увійти знову')),
        ],
      ),
    );
    if (relogin == true) await AuthRepository.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      highlighted: _expanded,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: const Icon(Icons.lock, color: AppColors.primary),
            title: const Text('Зміна пароля', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            trailing: Icon(
              _expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: AppColors.muted,
            ),
            onTap: _loading ? null : () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'Поточний пароль',
                      isPassword: true,
                      controller: _currentController,
                      validator: Validators.password,
                      enabled: !_loading,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Новий пароль',
                      isPassword: true,
                      controller: _newController,
                      validator: (value) => value == _currentController.text && value!.isNotEmpty
                          ? 'Новий пароль має відрізнятися від поточного'
                          : Validators.newPassword(value),
                      enabled: !_loading,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Підтвердження пароля',
                      isPassword: true,
                      controller: _confirmController,
                      validator: Validators.confirmPassword(() => _newController.text),
                      enabled: !_loading,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: AppColors.muted),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text('Не менше 6 символів, паролі мають збігатися',
                              style: TextStyle(fontSize: 13, color: AppColors.muted)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    PrimaryButton(label: 'Оновити пароль', isLoading: _loading, onPressed: _submit),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
