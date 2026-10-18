import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plant_care/main.dart';

void main() {
  testWidgets('Login button opens the home screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    await tester.pumpWidget(const PlantCareApp());

    expect(find.text('Увійти'), findsOneWidget);
    await tester.tap(find.text('Увійти'));
    await tester.pumpAndSettle();

    expect(find.text('Догляд на сьогодні'), findsOneWidget);
    expect(find.text('Микола'), findsOneWidget);
  });

  testWidgets('Profile tab shows password change form', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    await tester.pumpWidget(const PlantCareApp());
    await tester.tap(find.text('Увійти'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Профіль').last);
    await tester.pumpAndSettle();

    expect(find.text('Зміна пароля'), findsOneWidget);
    expect(find.text('Оновити пароль'), findsOneWidget);
  });
}
