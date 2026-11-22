import 'app_user.dart';

/// Контракт автентифікації (ФВ-1…ФВ-4 з ЛР2). Методи кидають [AuthFailure]
/// з повідомленням для користувача. BLoC отримують реалізацію через
/// RepositoryProvider, тож у тестах її легко замінити на фейкову.
abstract interface class AuthRepository {
  /// Поточний користувач: перша подія – відновлений сеанс або null,
  /// далі – вхід, вихід і зміни профілю (ім'я, фото, способи входу).
  Stream<AppUser?> get user;

  AppUser? get currentUser;

  Future<void> signUp({required String name, required String email, required String password});

  Future<void> signIn({required String email, required String password});

  Future<void> signInWithGoogle();

  Future<void> sendPasswordReset(String email);

  Future<void> changePassword({required String currentPassword, required String newPassword});

  /// Додає вхід за паролем до акаунта, створеного через Google.
  Future<void> linkPassword(String password);

  /// Прив'язує Google до поточного акаунта.
  Future<void> linkGoogle();

  Future<void> updateDisplayName(String name);

  Future<void> updatePhotoUrl(String url);

  Future<void> signOut();
}
