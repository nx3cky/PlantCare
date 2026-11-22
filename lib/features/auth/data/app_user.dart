import 'package:equatable/equatable.dart';

/// Користувач застосунку (об'єкт даних 3.1 з ЛР2) – незалежний від Firebase,
/// тож BLoC і віджети не імпортують firebase_auth.
class AppUser extends Equatable {
  static const passwordProvider = 'password';
  static const googleProvider = 'google.com';

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  /// Прив'язані способи входу (`password`, `google.com`).
  final Set<String> providers;

  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.providers = const {},
  });

  bool get hasPassword => providers.contains(passwordProvider);

  bool get hasGoogle => providers.contains(googleProvider);

  /// Перше слово імені або частина email до «@».
  String get firstName {
    final name = displayName?.trim() ?? '';
    if (name.isNotEmpty) return name.split(RegExp(r'\s+')).first;
    final mail = email ?? '';
    return mail.contains('@') ? mail.split('@').first : 'друже';
  }

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, providers];
}
