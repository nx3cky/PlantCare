import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_failure.dart';
import '../data/auth_repository.dart';

part 'register_event.dart';
part 'register_state.dart';

/// ФВ-1. Стан операції реєстрації нового користувача.
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _authRepository;

  RegisterBloc(this._authRepository) : super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(RegisterSubmitted event, Emitter<RegisterState> emit) async {
    if (state is RegisterLoading) return;
    emit(const RegisterLoading());
    try {
      await _authRepository.signUp(name: event.name, email: event.email, password: event.password);
      emit(const RegisterSuccess());
    } on AuthFailure catch (e) {
      emit(RegisterFailure(e.message));
    }
  }
}
