/// Локальна валідація полів форм (ФВ-1…ФВ-4 з ЛР2).
/// Кожен валідатор повертає текст помилки або null, якщо значення коректне.
/// Існування акаунта й правильність пароля перевіряє вже Firebase Auth.
abstract final class Validators {
  static const minPasswordLength = 6;
  static const minNameLength = 2;

  static final _emailRegExp = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)*\.[a-zA-Z]{2,}$');

  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Введіть ім’я';
    if (text.length < minNameLength) return 'Ім’я має містити щонайменше $minNameLength символи';
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Введіть електронну пошту';
    if (!_emailRegExp.hasMatch(text)) return 'Неправильний формат email, напр. name@gmail.com';
    return null;
  }

  /// Пароль для входу: лише обов'язковість (довжину перевіряє Firebase).
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Введіть пароль';
    return null;
  }

  /// Новий пароль: реєстрація, зміна пароля, створення пароля для Google-акаунта.
  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Введіть пароль';
    if (value.length < minPasswordLength) {
      return 'Пароль має містити щонайменше $minPasswordLength символів';
    }
    if (value.contains(' ')) return 'Пароль не може містити пробіли';
    return null;
  }

  /// Підтвердження має збігатися з паролем, який повертає [password].
  static String? Function(String?) confirmPassword(String Function() password) {
    return (value) {
      if (value == null || value.isEmpty) return 'Повторіть пароль';
      if (value != password()) return 'Паролі не збігаються';
      return null;
    };
  }

  /// Посилання на фото профілю – лише HTTPS.
  static String? photoUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Вставте посилання на зображення';
    final uri = Uri.tryParse(text);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      return 'Посилання має починатися з https://';
    }
    return null;
  }
}
