import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/crash_reporting.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_format.dart';
import '../../core/widgets/app_snack_bar.dart';
import '../../core/widgets/avatar_picker_dialog.dart';
import '../../core/widgets/settings_tile.dart';
import '../../core/widgets/user_avatar.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/data/app_user.dart';
import '../journal/bloc/journal_bloc.dart';
import '../plants/bloc/plants_bloc.dart';
import 'bloc/profile_bloc.dart';
import 'widgets/change_password_card.dart';
import 'widgets/profile_form_dialog.dart';

/// ФВ-4. Профіль: дані акаунта, зміна імені, фото й пароля, способи входу,
/// налаштування нагадувань (зберігаються на пристрої) і вихід.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Помилки діалогів показуються в самих діалогах, а пароля – у картці.
  static bool _showAsSnackBar(ProfileNotice n) =>
      !(n.isError && (n.action == ProfileAction.name || n.action == ProfileAction.createPassword)) &&
      !n.requiresRelogin;

  Future<void> _changePhoto(BuildContext context, AppUser user) async {
    final bloc = context.read<ProfileBloc>();
    final url = await AvatarPickerDialog.show(context, currentUrl: user.photoUrl);
    if (url != null) bloc.add(ProfilePhotoChanged(url));
  }

  Future<void> _pickReminderTime(BuildContext context, String current) async {
    final bloc = context.read<ProfileBloc>();
    final parts = current.split(':');
    final time = await showTimePicker(
      context: context,
      helpText: 'Час щоденного нагадування',
      initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
    );
    if (time == null) return;
    String two(int v) => v.toString().padLeft(2, '0');
    bloc.add(ProfileReminderTimeChanged('${two(time.hour)}:${two(time.minute)}'));
  }

  Future<void> _sendTestError(BuildContext context) async {
    await CrashReporting.sendTestError();
    if (!context.mounted) return;
    context.showMessage(CrashReporting.isSupported
        ? 'Тестову помилку надіслано в Crashlytics'
        : 'Crashlytics не підтримується у веб-версії');
  }

  Future<void> _logout(BuildContext context) async {
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
    if (confirmed == true && context.mounted) context.read<AuthBloc>().add(const AuthLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (prev, curr) => curr.notice != null && prev.notice != curr.notice,
      listener: (context, state) {
        final notice = state.notice!;
        if (_showAsSnackBar(notice)) context.showMessage(notice.message, isError: notice.isError);
      },
      builder: (context, state) {
        final user = state.user;
        // Без користувача AuthGate одразу покаже екран входу.
        if (user == null) return const SizedBox.shrink();
        final bloc = context.read<ProfileBloc>();
        final busy = state.action != null;
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Профіль', style: TextStyle(fontSize: 26, color: AppColors.text))),
                  IconButton(
                    tooltip: 'Вийти',
                    onPressed: busy ? null : () => _logout(context),
                    icon: const Icon(Icons.logout, color: AppColors.error),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Header(user: user, loadingPhoto: state.action == ProfileAction.photo, onEditPhoto: () => _changePhoto(context, user)),
              const SizedBox(height: 20),
              const _SectionLabel('ОБЛІКОВИЙ ЗАПИС'),
              SettingsTile(
                icon: Icons.person,
                title: 'Особисті дані',
                subtitle: 'Ім’я, що бачать інші',
                onTap: () => ProfileFormDialog.editName(current: user.displayName).show(context),
              ),
              const SizedBox(height: 10),
              if (user.hasPassword) ...[
                const ChangePasswordCard(),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 10),
              const _SectionLabel('СПОСОБИ ВХОДУ'),
              _ProviderTile(
                icon: Icons.mail,
                title: 'Email і пароль',
                linked: user.hasPassword,
                actionLabel: 'Створити',
                enabled: !busy,
                onLink: () => ProfileFormDialog.createPassword().show(context),
              ),
              const SizedBox(height: 10),
              _ProviderTile(
                icon: Icons.account_circle,
                title: 'Google',
                linked: user.hasGoogle,
                actionLabel: 'Прив’язати',
                busy: state.action == ProfileAction.google,
                enabled: !busy,
                onLink: () => bloc.add(const ProfileGoogleLinkRequested()),
              ),
              const SizedBox(height: 20),
              const _SectionLabel('НАЛАШТУВАННЯ'),
              SettingsTile(
                icon: Icons.notifications,
                title: 'Нагадування про догляд',
                subtitle: state.settings.remindersEnabled
                    ? 'Щодня о ${state.settings.reminderTime} · змінити час'
                    : 'Вимкнено',
                onTap: () => _pickReminderTime(context, state.settings.reminderTime),
                trailing: Switch(
                  value: state.settings.remindersEnabled,
                  onChanged: (v) => bloc.add(ProfileRemindersToggled(v)),
                ),
              ),
              const SizedBox(height: 20),
              const _SectionLabel('ДІАГНОСТИКА'),
              SettingsTile(
                icon: Icons.bug_report,
                title: 'Надіслати тестову помилку',
                subtitle: 'Перевірка Firebase Crashlytics',
                onTap: () => _sendTestError(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final AppUser user;
  final bool loadingPhoto;
  final VoidCallback onEditPhoto;

  const _Header({required this.user, required this.loadingPhoto, required this.onEditPhoto});

  @override
  Widget build(BuildContext context) {
    final name = user.displayName?.trim();
    // Статистика – зі станів PlantsBloc і JournalBloc (context.select
    // перебудовує заголовок лише при зміні кількості).
    final plants = context.select<PlantsBloc, int>((b) => b.state.plants.length);
    final entries = context.select<JournalBloc, int>((b) => b.state.entries.length);
    return Row(
      children: [
        loadingPhoto
            ? const SizedBox(width: 84, height: 84, child: Center(child: CircularProgressIndicator()))
            : UserAvatar(
                initials: UserAvatar.initialsOf(name, user.email),
                photoUrl: user.photoUrl,
                size: 80,
                onEditPhoto: onEditPhoto,
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
              Text(
                '$plants ${DateFormatUa.plural(plants, 'рослина', 'рослини', 'рослин')} · '
                '$entries ${DateFormatUa.plural(entries, 'запис', 'записи', 'записів')} у журналі',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProviderTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool linked;
  final String actionLabel;
  final VoidCallback onLink;
  final bool busy;
  final bool enabled;

  const _ProviderTile({
    required this.icon,
    required this.title,
    required this.linked,
    required this.actionLabel,
    required this.onLink,
    this.busy = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      icon: icon,
      title: title,
      subtitle: linked ? 'Підключено' : 'Не підключено',
      trailing: linked
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : busy
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
              : TextButton(onPressed: enabled ? onLink : null, child: Text(actionLabel)),
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
