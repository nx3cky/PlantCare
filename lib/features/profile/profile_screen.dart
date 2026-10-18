import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/data/mock_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/settings_tile.dart';
import '../../core/widgets/user_avatar.dart';

/// Профіль користувача: дані акаунта, зміна пароля, налаштування нагадувань.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _passwordExpanded = true;
  bool _remindersEnabled = true;

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _logout() {
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Профіль', style: TextStyle(fontSize: 26, color: AppColors.text)),
              ),
              IconButton(
                tooltip: 'Вийти',
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              UserAvatar(
                initials: MockUser.initials,
                size: 80,
                onEditPhoto: () => _showMessage('Зміна фото – буде реалізовано пізніше'),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(MockUser.fullName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text(MockUser.email, style: TextStyle(fontSize: 14, color: AppColors.muted)),
                    SizedBox(height: 4),
                    Text(
                      '${MockUser.plantsCount} рослин · ${MockUser.journalCount} записів у журналі',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _SectionLabel('ОБЛІКОВИЙ ЗАПИС'),
          SettingsTile(
            icon: Icons.person,
            title: 'Особисті дані',
            onTap: () => _showMessage('Редагування даних – буде реалізовано пізніше'),
          ),
          const SizedBox(height: 10),
          _buildPasswordCard(),
          const SizedBox(height: 20),
          const _SectionLabel('НАЛАШТУВАННЯ'),
          SettingsTile(
            icon: Icons.notifications,
            title: 'Нагадування про догляд',
            subtitle: 'Щодня о 09:00',
            trailing: Switch(
              value: _remindersEnabled,
              onChanged: (v) => setState(() => _remindersEnabled = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordCard() {
    return SettingsCard(
      highlighted: _passwordExpanded,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: const Icon(Icons.lock, color: AppColors.primary),
            title: const Text('Зміна пароля', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            trailing: Icon(
              _passwordExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: AppColors.muted,
            ),
            onTap: () => setState(() => _passwordExpanded = !_passwordExpanded),
          ),
          if (_passwordExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppTextField(label: 'Поточний пароль', isPassword: true, initialValue: 'oldpass1'),
                  const SizedBox(height: 12),
                  const AppTextField(label: 'Новий пароль', isPassword: true, initialValue: 'newpass123'),
                  const SizedBox(height: 12),
                  const AppTextField(label: 'Підтвердження пароля', isPassword: true, initialValue: 'newpass123'),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.check, size: 16, color: AppColors.primary),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text('Не менше 6 символів, паролі збігаються',
                            style: TextStyle(fontSize: 13, color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    label: 'Оновити пароль',
                    onPressed: () {
                      setState(() => _passwordExpanded = false);
                      _showMessage('Пароль успішно змінено');
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: AppColors.muted),
      ),
    );
  }
}
