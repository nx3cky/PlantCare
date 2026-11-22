import 'dart:async';

import 'package:plant_care/features/auth/data/app_user.dart';
import 'package:plant_care/features/auth/data/auth_failure.dart';
import 'package:plant_care/features/auth/data/auth_repository.dart';

/// Фейкова реалізація [AuthRepository] для тестів без Firebase:
/// вхід успішний лише для test@example.com / password123.
class FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _user;
  int signInCalls = 0;

  FakeAuthRepository([this._user]);

  @override
  Stream<AppUser?> get user async* {
    yield _user;
    yield* _controller.stream;
  }

  @override
  AppUser? get currentUser => _user;

  void _set(AppUser? user) {
    _user = user;
    _controller.add(user);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (email != 'test@example.com' || password != 'password123') {
      throw const AuthFailure('Невірний email або пароль.');
    }
    _set(AppUser(uid: 'u1', email: email, displayName: 'Тест Тестович', providers: {AppUser.passwordProvider}));
  }

  @override
  Future<void> signUp({required String name, required String email, required String password}) async {
    if (email == 'used@example.com') {
      throw const AuthFailure('Акаунт з таким email уже існує. Увійдіть або відновіть пароль.');
    }
    _set(AppUser(uid: 'u2', email: email, displayName: name, providers: {AppUser.passwordProvider}));
  }

  @override
  Future<void> updateDisplayName(String name) async {
    final u = _user!;
    _set(AppUser(uid: u.uid, email: u.email, displayName: name, photoUrl: u.photoUrl, providers: u.providers));
  }

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    if (currentPassword != 'password123') throw const AuthFailure('Поточний пароль неправильний.');
  }

  @override
  Future<void> signOut() async => _set(null);

  @override
  Future<void> signInWithGoogle() async => throw const AuthFailure('Вхід через Google скасовано.');

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> linkPassword(String password) async {}

  @override
  Future<void> linkGoogle() async {}

  @override
  Future<void> updatePhotoUrl(String url) async {}
}
