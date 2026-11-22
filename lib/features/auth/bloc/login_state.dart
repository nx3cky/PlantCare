part of 'login_bloc.dart';

enum LoginMethod { email, google }

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

/// Запит виконується: індикатор на кнопці [method], решта кнопок заблокована.
final class LoginLoading extends LoginState {
  final LoginMethod method;

  const LoginLoading(this.method);

  @override
  List<Object?> get props => [method];
}

final class LoginSuccess extends LoginState {
  const LoginSuccess();
}

final class LoginFailure extends LoginState {
  final String message;

  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}
