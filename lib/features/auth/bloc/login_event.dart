part of 'login_bloc.dart';

sealed class LoginEvent {
  const LoginEvent();
}

/// Натиснуто «Увійти» з коректно заповненою формою.
final class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;

  const LoginSubmitted(this.email, this.password);
}

/// Натиснуто «Продовжити з Google».
final class LoginWithGoogleSubmitted extends LoginEvent {
  const LoginWithGoogleSubmitted();
}
