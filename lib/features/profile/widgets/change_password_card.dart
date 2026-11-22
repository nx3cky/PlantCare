import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/settings_tile.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';

/// ФВ-4. Розгортна картка зміни пароля для акаунтів із входом за email.
/// Надсилає [ProfilePasswordChanged] і реагує на результат через BlocListener.
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

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<ProfileBloc>().add(ProfilePasswordChanged(
          currentPassword: _currentController.text,
          newPassword: _newController.text,
        ));
  }

  void _onResult(ProfileNotice notice) {
    if (notice.requiresRelogin) {
      _showReloginDialog();
    } else if (!notice.isError) {
      _formKey.currentState?.reset();
      _currentController.clear();
      _newController.clear();
      _confirmController.clear();
      setState(() => _expanded = false);
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
    if (relogin == true && mounted) context.read<AuthBloc>().add(const AuthLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (prev, curr) => curr.notice != prev.notice && curr.notice?.action == ProfileAction.password,
      listener: (_, state) => _onResult(state.notice!),
      buildWhen: (prev, curr) => prev.action != curr.action,
      builder: (context, state) {
        final loading = state.action == ProfileAction.password;
        return SettingsCard(
          highlighted: _expanded,
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: const Icon(Icons.lock, color: AppColors.primary),
                title: const Text('Зміна пароля', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                trailing: Icon(_expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: AppColors.muted),
                onTap: loading ? null : () => setState(() => _expanded = !_expanded),
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
                          enabled: !loading,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Новий пароль',
                          isPassword: true,
                          controller: _newController,
                          validator: (value) => value == _currentController.text && value!.isNotEmpty
                              ? 'Новий пароль має відрізнятися від поточного'
                              : Validators.newPassword(value),
                          enabled: !loading,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Підтвердження пароля',
                          isPassword: true,
                          controller: _confirmController,
                          validator: Validators.confirmPassword(() => _newController.text),
                          enabled: !loading,
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
                        PrimaryButton(label: 'Оновити пароль', isLoading: loading, onPressed: _submit),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
