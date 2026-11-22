import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/services/analytics_service.dart';
import '../../../core/services/crash_reporting.dart';
import 'app_user.dart';
import 'auth_failure.dart';
import 'auth_repository.dart';

/// Реалізація [AuthRepository] на Firebase Authentication.
/// Винятки Firebase і Google Sign-In перетворюються на [AuthFailure]
/// з повідомленням українською.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  AnalyticsService get _analytics => AnalyticsService.instance;
  bool _googleInitialized = false;

  /// Firebase не ініціалізовано (тести без мережі) – сеансу немає.
  bool get _ready => Firebase.apps.isNotEmpty;

  static AppUser? _map(User? user) => user == null
      ? null
      : AppUser(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          providers: {for (final info in user.providerData) info.providerId},
        );

  @override
  Stream<AppUser?> get user => _ready ? _auth.userChanges().map(_map) : Stream.value(null);

  @override
  AppUser? get currentUser => _ready ? _map(_auth.currentUser) : null;

  @override
  Future<void> signUp({required String name, required String email, required String password}) {
    return _guard(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
      await credential.user?.reload();
      await _analytics.logSignUp('email');
    });
  }

  @override
  Future<void> signIn({required String email, required String password}) {
    return _guard(() async {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      await _analytics.logLogin('email');
    });
  }

  /// На Web – спливаюче вікно, на Android – Credential Manager.
  @override
  Future<void> signInWithGoogle() {
    return _guard(() async {
      final result = kIsWeb
          ? await _auth.signInWithPopup(GoogleAuthProvider())
          : await _auth.signInWithCredential(await _googleCredential());
      final isNew = result.additionalUserInfo?.isNewUser ?? false;
      await (isNew ? _analytics.logSignUp('google') : _analytics.logLogin('google'));
    });
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return _guard(() async {
      await _auth.setLanguageCode('uk');
      await _auth.sendPasswordResetEmail(email: email.trim());
      await _analytics.logEvent('password_reset_requested');
    });
  }

  /// Firebase вимагає «свіжого» входу, тому спершу повторна автентифікація.
  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) {
    return _guard(() async {
      final user = _requireUser();
      try {
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: user.email!, password: currentPassword),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
          throw const AuthFailure('Поточний пароль неправильний.');
        }
        rethrow;
      }
      await user.updatePassword(newPassword);
      await _analytics.logEvent('change_password');
    });
  }

  @override
  Future<void> linkPassword(String password) {
    return _guard(() async {
      final user = _requireUser();
      await user.linkWithCredential(
        EmailAuthProvider.credential(email: user.email!, password: password),
      );
      await user.reload();
      await _analytics.logEvent('link_provider', {'provider': AppUser.passwordProvider});
    });
  }

  @override
  Future<void> linkGoogle() {
    return _guard(() async {
      final user = _requireUser();
      if (kIsWeb) {
        await user.linkWithPopup(GoogleAuthProvider());
      } else {
        await user.linkWithCredential(await _googleCredential());
      }
      await user.reload();
      await _analytics.logEvent('link_provider', {'provider': AppUser.googleProvider});
    });
  }

  @override
  Future<void> updateDisplayName(String name) {
    return _guard(() async {
      final user = _requireUser();
      await user.updateDisplayName(name.trim());
      await user.reload();
      await _analytics.logEvent('profile_name_changed');
    });
  }

  /// Зберігається лише HTTPS-посилання, файл не завантажується.
  @override
  Future<void> updatePhotoUrl(String url) {
    return _guard(() async {
      final user = _requireUser();
      await user.updatePhotoURL(url.trim());
      await user.reload();
      await _analytics.logEvent('avatar_changed');
    });
  }

  @override
  Future<void> signOut() {
    return _guard(() async {
      await _analytics.logEvent('logout');
      if (!kIsWeb && _googleInitialized) {
        await GoogleSignIn.instance.signOut();
      }
      await _auth.signOut();
    });
  }

  User _requireUser() {
    final user = _ready ? _auth.currentUser : null;
    if (user == null) throw const AuthFailure('Сеанс завершився. Увійдіть ще раз.');
    return user;
  }

  /// Android: акаунт Google через Credential Manager → облікові дані Firebase.
  Future<AuthCredential> _googleCredential() async {
    final google = GoogleSignIn.instance;
    if (!_googleInitialized) {
      await google.initialize();
      _googleInitialized = true;
    }
    final account = await google.authenticate();
    return GoogleAuthProvider.credential(idToken: account.authentication.idToken);
  }

  /// Перетворює винятки на [AuthFailure]; непередбачені помилки
  /// потрапляють у Crashlytics як нефатальні.
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on AuthFailure {
      rethrow;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} ${e.message}');
      throw AuthFailure.fromCode(e.code);
    } on GoogleSignInException catch (e) {
      debugPrint('GoogleSignInException: ${e.code} ${e.description}');
      throw AuthFailure(
        e.code == GoogleSignInExceptionCode.canceled
            ? 'Вхід через Google скасовано.'
            : 'Не вдалося увійти через Google. Спробуйте ще раз.',
      );
    } catch (error, stack) {
      await CrashReporting.recordError(error, stack, reason: 'AuthRepository');
      throw const AuthFailure('Щось пішло не так. Спробуйте ще раз.');
    }
  }
}
