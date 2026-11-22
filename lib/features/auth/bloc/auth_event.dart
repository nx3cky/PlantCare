part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

/// Початок стеження за сеансом (надсилається один раз під час запуску).
final class AuthSubscriptionRequested extends AuthEvent {
  const AuthSubscriptionRequested();
}

/// Користувач підтвердив вихід з акаунта.
final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
