part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

final class AuthState extends Equatable {
  final AuthStatus status;
  final AppUser? user;

  /// Помилка виходу з акаунта (рідкісна – наприклад, немає мережі).
  final String? error;

  const AuthState._({required this.status, this.user, this.error});

  /// Сеанс ще відновлюється після запуску – показується заставка.
  const AuthState.unknown() : this._(status: AuthStatus.unknown);

  const AuthState.authenticated(AppUser user) : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated() : this._(status: AuthStatus.unauthenticated);

  AuthState copyWithError(String message) => AuthState._(status: status, user: user, error: message);

  @override
  List<Object?> get props => [status, user, error];
}
