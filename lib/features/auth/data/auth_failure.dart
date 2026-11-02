/// Помилка автентифікації з повідомленням, зрозумілим користувачу.
/// Екрани показують лише [message], а не технічний текст винятку Firebase.
class AuthFailure implements Exception {
  final String message;

  /// Firebase вимагає повторного входу перед чутливою операцією.
  final bool requiresRecentLogin;

  const AuthFailure(this.message, {this.requiresRecentLogin = false});

  /// Перетворення коду FirebaseAuthException на текст українською.
  factory AuthFailure.fromCode(String code) => switch (code) {
        'invalid-email' => const AuthFailure('Неправильний формат електронної пошти.'),
        'user-disabled' => const AuthFailure('Цей обліковий запис заблоковано.'),
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' ||
        'INVALID_LOGIN_CREDENTIALS' =>
          const AuthFailure('Невірний email або пароль.'),
        'email-already-in-use' =>
          const AuthFailure('Акаунт з таким email уже існує. Увійдіть або відновіть пароль.'),
        'weak-password' => const AuthFailure('Пароль занадто простий – щонайменше 6 символів.'),
        'too-many-requests' =>
          const AuthFailure('Забагато спроб. Зачекайте кілька хвилин і спробуйте знову.'),
        'network-request-failed' =>
          const AuthFailure('Немає з’єднання з інтернетом. Перевірте мережу.'),
        'requires-recent-login' => const AuthFailure(
            'З міркувань безпеки потрібно увійти повторно.',
            requiresRecentLogin: true,
          ),
        'credential-already-in-use' || 'account-exists-with-different-credential' =>
          const AuthFailure('Цей акаунт Google уже прив’язаний до іншого користувача.'),
        'provider-already-linked' => const AuthFailure('Цей спосіб входу вже прив’язаний.'),
        'popup-closed-by-user' || 'cancelled-popup-request' =>
          const AuthFailure('Вхід через Google скасовано.'),
        'operation-not-allowed' =>
          const AuthFailure('Цей спосіб входу вимкнено в налаштуваннях Firebase.'),
        _ => const AuthFailure('Щось пішло не так. Спробуйте ще раз.'),
      };

  @override
  String toString() => 'AuthFailure: $message';
}
