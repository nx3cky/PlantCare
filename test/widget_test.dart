import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plant_care/core/utils/validators.dart';
import 'package:plant_care/features/auth/login_screen.dart';
import 'package:plant_care/features/auth/register_screen.dart';
import 'package:plant_care/features/shell/main_shell.dart';

// Тести не звертаються до Firebase: Firebase.initializeApp() не викликається,
// тож репозиторій повертає «немає користувача», а аналітика вимкнена.
Widget _app(Widget home) => MaterialApp(home: home);

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

    test('name and photo url', () {
      expect(Validators.name(' '), 'Введіть ім’я');
      expect(Validators.name('М'), isNotNull);
      expect(Validators.name('Микола'), isNull);
      expect(Validators.photoUrl('http://example.com/a.png'), isNotNull);
      expect(Validators.photoUrl('https://example.com/a.png'), isNull);
    });
  });

  testWidgets('Register form shows validation errors', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1000));
    await tester.pumpWidget(_app(const RegisterScreen()));

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

  testWidgets('Login form requires email and password', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1000));
    await tester.pumpWidget(_app(const LoginScreen()));

    await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
    await tester.tap(find.text('Увійти'));
    await tester.pump();
    expect(find.textContaining('Неправильний формат email'), findsOneWidget);
    expect(find.text('Введіть пароль'), findsOneWidget);
  });

  testWidgets('Tapping a plant adds it to recently viewed', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    await tester.pumpWidget(_app(const MainShell()));
    await tester.pumpAndSettle();

    expect(find.text('Догляд на сьогодні'), findsOneWidget);
    expect(find.text('Натисніть на рослину, щоб вона з’явилася тут'), findsOneWidget);

    await tester.tap(find.text('Спатифілум'));
    await tester.pumpAndSettle();
    expect(find.text('Спатифілум'), findsNWidgets(2));
    expect(find.text('Очистити'), findsOneWidget);

    // Повторний перегляд не створює дубліката.
    await tester.tap(find.text('Спатифілум').first);
    await tester.pumpAndSettle();
    expect(find.text('Спатифілум'), findsNWidgets(2));

    await tester.tap(find.text('Очистити'));
    await tester.pumpAndSettle();
    expect(find.text('Спатифілум'), findsOneWidget);
    expect(find.text('Натисніть на рослину, щоб вона з’явилася тут'), findsOneWidget);
  });
}
