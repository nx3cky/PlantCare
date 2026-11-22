import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plant_care/app/app.dart';
import 'package:plant_care/core/data/repositories/local_garden_repository.dart';
import 'package:plant_care/core/data/repositories/settings_repository.dart';
import 'package:plant_care/core/utils/validators.dart';
import 'package:plant_care/features/auth/data/app_user.dart';
import 'package:plant_care/features/auth/data/auth_repository.dart';
import 'package:plant_care/features/auth/login_screen.dart';
import 'package:plant_care/features/auth/register_screen.dart';

import 'helpers.dart';

// Тести не звертаються до Firebase: замість FirebaseAuthRepository –
// FakeAuthRepository, а SharedPreferences працює з даними в пам'яті.
Widget _screen(Widget home, [AuthRepository? auth]) => RepositoryProvider<AuthRepository>.value(
      value: auth ?? FakeAuthRepository(),
      child: MaterialApp(home: home),
    );

void main() {
  group('Validators', () {
    test('email', () {
      expect(Validators.email(''), 'Введіть електронну пошту');
      expect(Validators.email('mykola@'), isNotNull);
      expect(Validators.email('mykola.heiko@gmail.com'), isNull);
    });

    test('password and confirmation', () {
      expect(Validators.newPassword('12345'), contains('6'));
      expect(Validators.newPassword('plant care'), isNotNull);
      expect(Validators.newPassword('plantcare1'), isNull);
      final confirm = Validators.confirmPassword(() => 'plantcare1');
      expect(confirm('plantcare2'), 'Паролі не збігаються');
      expect(confirm('plantcare1'), isNull);
    });
  });

  testWidgets('Register form shows validation errors', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1000));
    await tester.pumpWidget(_screen(const RegisterScreen()));

    await tester.tap(find.text('Зареєструватися'));
    await tester.pump();
    expect(find.text('Введіть ім’я'), findsOneWidget);
    expect(find.text('Введіть електронну пошту'), findsOneWidget);
    expect(find.text('Повторіть пароль'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(2), 'plantcare1');
    await tester.enterText(find.byType(TextFormField).at(3), 'plantcare2');
    await tester.tap(find.text('Зареєструватися'));
    await tester.pump();
    expect(find.text('Паролі не збігаються'), findsOneWidget);
  });

  testWidgets('LoginBloc: wrong password shows an error message', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1000));
    final auth = FakeAuthRepository();
    await tester.pumpWidget(_screen(const Scaffold(body: LoginScreen()), auth));

    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong-password');
    await tester.tap(find.text('Увійти'));
    await tester.pump();
    // LoginLoading: замість тексту кнопки – індикатор.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(auth.signInCalls, 1);
    expect(find.text('Невірний email або пароль.'), findsOneWidget);
  });

  testWidgets('App: signed-in user sees today tasks and the plant catalog', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 1600));
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final user = AppUser(uid: 'u1', email: 'test@example.com', displayName: 'Микола Гейко', providers: {'password'});

    await tester.pumpWidget(PlantCareApp(
      authRepository: FakeAuthRepository(user),
      gardenRepository: LocalGardenRepository(prefs),
      settingsRepository: SettingsRepository(prefs),
    ));
    await tester.pumpAndSettle();

    // Головна: демо-дані, полив Хлорофітуму прострочено.
    expect(find.text('Микола'), findsOneWidget);
    expect(find.text('Полити · Хлорофітум'), findsOneWidget);
    expect(find.text('Прострочено на 1 день'), findsOneWidget);

    // Відмітка виконання переносить процедуру у «виконано».
    await tester.tap(find.byTooltip('Позначити виконаним').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Виконано о'), findsWidgets);

    // Каталог: 7 рослин, пошук за назвою.
    await tester.tap(find.text('Рослини'));
    await tester.pumpAndSettle();
    expect(find.text('7 рослин · за назвою'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'фікус');
    await tester.pumpAndSettle();
    expect(find.text('1 рослина · за назвою'), findsOneWidget);
  });
}
