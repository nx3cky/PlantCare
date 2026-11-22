part of 'profile_bloc.dart';

sealed class ProfileEvent {
  const ProfileEvent();
}

/// Завантаження профілю та стеження за його змінами.
final class ProfileSubscriptionRequested extends ProfileEvent {
  const ProfileSubscriptionRequested();
}

final class ProfileNameChanged extends ProfileEvent {
  final String name;

  const ProfileNameChanged(this.name);
}

final class ProfilePhotoChanged extends ProfileEvent {
  final String url;

  const ProfilePhotoChanged(this.url);
}

final class ProfilePasswordChanged extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  const ProfilePasswordChanged({required this.currentPassword, required this.newPassword});
}

/// Створення пароля для акаунта, зареєстрованого через Google.
final class ProfilePasswordCreated extends ProfileEvent {
  final String password;

  const ProfilePasswordCreated(this.password);
}

final class ProfileGoogleLinkRequested extends ProfileEvent {
  const ProfileGoogleLinkRequested();
}

final class ProfileRemindersToggled extends ProfileEvent {
  final bool enabled;

  const ProfileRemindersToggled(this.enabled);
}

/// Час нагадування у форматі «HH:mm».
final class ProfileReminderTimeChanged extends ProfileEvent {
  final String time;

  const ProfileReminderTimeChanged(this.time);
}
