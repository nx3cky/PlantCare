import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/data/mock_data.dart';
import '../../core/services/crash_reporting.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_snack_bar.dart';
import '../../core/widgets/avatar_picker_dialog.dart';
import '../../core/widgets/settings_tile.dart';
import '../../core/widgets/user_avatar.dart';
import '../auth/data/auth_failure.dart';
import '../auth/data/auth_repository.dart';
import 'widgets/change_password_card.dart';
import 'widgets/profile_form_dialog.dart';

/// ФВ-4. Профіль: дані акаунта з Firebase Auth, зміна імені, фото й пароля,
/// способи входу, нагадування (заглушка до ЛР з FCM) і вихід.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repository = AuthRepository.instance;
  bool _remindersEnabled = true;

  /// Дія, що зараз виконується (для індикатора на відповідному пункті).
  String? _busy;

  Future<void> _run(String key, Future<void> Function() action, String success) async {
    if (_busy != null) return;
    setState(() => _busy = key);
    try {
      await action();
      if (mounted) context.showMessage(success);
    } on AuthFailure catch (e) {
      if (mounted) context.showMessage(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _editName(User user) async {
    final saved = await ProfileFormDialog.editName(
      current: user.displayName,
      save: _repository.updateDisplayName,
    ).show(context);
    if (saved && mounted) context.showMessage('Ім’я оновлено');
  }

  Future<void> _changePhoto(User user) async {
    final url = await AvatarPickerDialog.show(context, currentUrl: user.photoURL);
    if (url == null || !mounted) return;
    await _run('photo', () => _repository.updatePhotoUrl(url), 'Фото профілю оновлено');
  }

  Future<void> _createPassword() async {
    final saved = await ProfileFormDialog.createPassword(save: _repository.linkPassword).show(context);
    if (saved && mounted) context.showMessage('Тепер можна входити і за email та паролем');
  }

  Future<void> _sendTestError() async {
    await CrashReporting.sendTestError();
    if (!mounted) return;
    context.showMessage(CrashReporting.isSupported
        ? 'Тестову помилку надіслано в Crashlytics'
        : 'Crashlytics не підтримується у веб-версії');
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Вийти з акаунта?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Скасувати')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Вийти')),
        ],
      ),
    );
    if (confirmed != true) return;
    // Після виходу AuthGate сам покаже екран входу.
    await _run('logout', _repository.signOut, 'Ви вийшли з акаунта');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _repository.userChanges(),
      initialData: _repository.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        // Без користувача AuthGate одразу покаже екран входу.
        if (user == null) return const SizedBox.shrink();
        final providers = AuthRepository.providersOf(user);
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
                    onPressed: _busy == null ? _logout : null,
                    icon: const Icon(Icons.logout, color: AppColors.error),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildHeader(user),
              const SizedBox(height: 20),
              const _SectionLabel('ОБЛІКОВИЙ ЗАПИС'),
              SettingsTile(
                icon: Icons.person,
                title: 'Особисті дані',
                subtitle: 'Ім’я, що бачать інші',
                onTap: () => _editName(user),
              ),
              const SizedBox(height: 10),
              if (providers.contains(AuthRepository.passwordProvider)) ...[
                const ChangePasswordCard(),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 10),
              const _SectionLabel('СПОСОБИ ВХОДУ'),
              _buildProviderTile(
                icon: Icons.mail,
                title: 'Email і пароль',
                linked: providers.contains(AuthRepository.passwordProvider),
                actionLabel: 'Створити',
                onLink: _createPassword,
              ),
              const SizedBox(height: 10),
              _buildProviderTile(
                icon: Icons.account_circle,
                title: 'Google',
                linked: providers.contains(AuthRepository.googleProvider),
                actionLabel: 'Прив’язати',
                busy: _busy == 'google',
                onLink: () => _run('google', _repository.linkGoogle, 'Google прив’язано до акаунта'),
              ),
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
              const SizedBox(height: 20),
              const _SectionLabel('ДІАГНОСТИКА'),
              SettingsTile(
                icon: Icons.bug_report,
                title: 'Надіслати тестову помилку',
                subtitle: 'Перевірка Firebase Crashlytics',
                onTap: _sendTestError,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(User user) {
    final name = user.displayName?.trim();
    return Row(
      children: [
        _busy == 'photo'
            ? const SizedBox(width: 84, height: 84, child: Center(child: CircularProgressIndicator()))
            : UserAvatar(
                initials: UserAvatar.initialsOf(name, user.email),
                photoUrl: user.photoURL,
                size: 80,
                onEditPhoto: () => _changePhoto(user),
              ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (name?.isNotEmpty ?? false) ? name! : 'Без імені',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(user.email ?? '', style: const TextStyle(fontSize: 14, color: AppColors.muted)),
              const SizedBox(height: 4),
              // Статистика потребує Cloud Firestore – поки заглушка.
              const Text(
                '${MockUser.plantsCount} рослин · ${MockUser.journalCount} записів у журналі',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProviderTile({
    required IconData icon,
    required String title,
    required bool linked,
    required String actionLabel,
    required VoidCallback onLink,
    bool busy = false,
  }) {
    return SettingsTile(
      icon: icon,
      title: title,
      subtitle: linked ? 'Підключено' : 'Не підключено',
      trailing: linked
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : busy
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
              : TextButton(onPressed: _busy == null ? onLink : null, child: Text(actionLabel)),
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
