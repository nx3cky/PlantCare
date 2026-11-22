import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/data/models/app_settings.dart';
import '../../../core/data/repositories/settings_repository.dart';
import '../../auth/data/app_user.dart';
import '../../auth/data/auth_failure.dart';
import '../../auth/data/auth_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// ФВ-4. Профіль користувача: дані з [AuthRepository] (ім'я, email, фото,
/// способи входу) та локальні налаштування нагадувань із [SettingsRepository].
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository _auth;
  final SettingsRepository _settings;
  int _noticeId = 0;

  ProfileBloc({required AuthRepository auth, required SettingsRepository settings})
      : _auth = auth,
        _settings = settings,
        super(ProfileState(user: auth.currentUser, settings: settings.load())) {
    on<ProfileSubscriptionRequested>(_onSubscriptionRequested);
    on<ProfileNameChanged>((e, emit) => _run(emit, ProfileAction.name, () => _auth.updateDisplayName(e.name),
        'Ім’я оновлено'));
    on<ProfilePhotoChanged>((e, emit) => _run(emit, ProfileAction.photo, () => _auth.updatePhotoUrl(e.url),
        'Фото профілю оновлено'));
    on<ProfilePasswordChanged>((e, emit) => _run(
          emit,
          ProfileAction.password,
          () => _auth.changePassword(currentPassword: e.currentPassword, newPassword: e.newPassword),
          'Пароль успішно змінено',
        ));
    on<ProfilePasswordCreated>((e, emit) => _run(emit, ProfileAction.createPassword,
        () => _auth.linkPassword(e.password), 'Тепер можна входити і за email та паролем'));
    on<ProfileGoogleLinkRequested>((e, emit) => _run(emit, ProfileAction.google, _auth.linkGoogle,
        'Google прив’язано до акаунта'));
    on<ProfileRemindersToggled>(_onRemindersToggled);
    on<ProfileReminderTimeChanged>(_onReminderTimeChanged);
  }

  Future<void> _onSubscriptionRequested(ProfileSubscriptionRequested event, Emitter<ProfileState> emit) {
    return emit.forEach<AppUser?>(
      _auth.user,
      onData: (user) => state.copyWith(user: () => user),
    );
  }

  /// Виконує запит до репозиторію: поки він триває, [ProfileState.action]
  /// вказує, на якому елементі показати індикатор; результат – у [ProfileNotice].
  Future<void> _run(
    Emitter<ProfileState> emit,
    ProfileAction action,
    Future<void> Function() request,
    String success,
  ) async {
    if (state.action != null) return;
    emit(state.copyWith(action: () => action));
    try {
      await request();
      emit(state.copyWith(action: () => null, notice: ProfileNotice(++_noticeId, action, success)));
    } on AuthFailure catch (e) {
      emit(state.copyWith(
        action: () => null,
        notice: ProfileNotice(++_noticeId, action, e.message,
            isError: true, requiresRelogin: e.requiresRecentLogin),
      ));
    }
  }

  Future<void> _onRemindersToggled(ProfileRemindersToggled event, Emitter<ProfileState> emit) async {
    final settings = _settings.load().copyWith(remindersEnabled: event.enabled);
    emit(state.copyWith(settings: settings));
    await _settings.save(settings);
  }

  Future<void> _onReminderTimeChanged(ProfileReminderTimeChanged event, Emitter<ProfileState> emit) async {
    final settings = _settings.load().copyWith(reminderTime: event.time, remindersEnabled: true);
    emit(state.copyWith(
      settings: settings,
      notice: ProfileNotice(++_noticeId, ProfileAction.reminders, 'Нагадування щодня о ${event.time}'),
    ));
    await _settings.save(settings);
  }
}
