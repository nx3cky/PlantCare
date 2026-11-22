part of 'profile_bloc.dart';

/// Операція профілю, що виконується або щойно завершилась.
enum ProfileAction { name, photo, password, createPassword, google, reminders }

/// Одноразове повідомлення про результат операції (SnackBar або текст у діалозі).
/// [id] робить кожне повідомлення унікальним, навіть з тим самим текстом.
final class ProfileNotice extends Equatable {
  final int id;
  final ProfileAction action;
  final String message;
  final bool isError;

  /// Firebase вимагає повторного входу перед зміною пароля.
  final bool requiresRelogin;

  const ProfileNotice(this.id, this.action, this.message, {this.isError = false, this.requiresRelogin = false});

  @override
  List<Object?> get props => [id, action, message, isError, requiresRelogin];
}

final class ProfileState extends Equatable {
  final AppUser? user;
  final AppSettings settings;
  final ProfileAction? action;
  final ProfileNotice? notice;

  const ProfileState({this.user, required this.settings, this.action, this.notice});

  ProfileState copyWith({
    AppUser? Function()? user,
    AppSettings? settings,
    ProfileAction? Function()? action,
    ProfileNotice? notice,
  }) {
    return ProfileState(
      user: user != null ? user() : this.user,
      settings: settings ?? this.settings,
      action: action != null ? action() : this.action,
      notice: notice ?? this.notice,
    );
  }

  @override
  List<Object?> get props => [user, settings, action, notice];
}
