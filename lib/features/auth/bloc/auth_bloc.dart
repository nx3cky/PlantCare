import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/crash_reporting.dart';
import '../data/app_user.dart';
import '../data/auth_failure.dart';
import '../data/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Стан сеансу всього застосунку: хто увійшов і чи завершилося
/// відновлення сеансу після запуску. Слухає [AuthRepository.user].
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthState.unknown()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) {
    // emit.forEach тримає підписку, доки живе BLoC, і скасовує її в close().
    return emit.forEach<AppUser?>(
      _authRepository.user,
      onData: (user) {
        CrashReporting.setUser(user?.uid);
        return user == null ? const AuthState.unauthenticated() : AuthState.authenticated(user);
      },
      onError: (_, _) => const AuthState.unauthenticated(),
    );
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.signOut();
      // Новий стан прийде з потоку user (null).
    } on AuthFailure catch (e) {
      emit(state.copyWithError(e.message));
    }
  }
}
