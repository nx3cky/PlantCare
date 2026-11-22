part of 'register_bloc.dart';

sealed class RegisterEvent {
  const RegisterEvent();
}

/// Натиснуто «Зареєструватися» з коректно заповненою формою.
final class RegisterSubmitted extends RegisterEvent {
  final String name;
  final String email;
  final String password;

  const RegisterSubmitted({required this.name, required this.email, required this.password});
}
