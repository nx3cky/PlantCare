import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_failure.dart';
import '../data/auth_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

/// ФВ-2. Стан операції входу. Отримує [AuthRepository] через конструктор,
/// тож працює з інтерфейсом, а не з Firebase напряму.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc(this._authRepository) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onSubmitted);
    on<LoginWithGoogleSubmitted>(_onGoogleSubmitted);
  }

  Future<void> _onSubmitted(LoginSubmitted event, Emitter<LoginState> emit) =>
      _run(LoginMethod.email, emit, () => _authRepository.signIn(email: event.email, password: event.password));

  Future<void> _onGoogleSubmitted(LoginWithGoogleSubmitted event, Emitter<LoginState> emit) =>
      _run(LoginMethod.google, emit, _authRepository.signInWithGoogle);

  Future<void> _run(LoginMethod method, Emitter<LoginState> emit, Future<void> Function() request) async {
    // Повторне натискання під час запиту ігнорується.
    if (state is LoginLoading) return;
    emit(LoginLoading(method));
    try {
      await request();
      // Екран головної відкриє AuthGate, отримавши користувача з AuthBloc.
      emit(const LoginSuccess());
    } on AuthFailure catch (e) {
      emit(LoginFailure(e.message));
    }
  }
}
