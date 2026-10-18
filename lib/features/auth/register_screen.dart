import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import 'widgets/auth_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _acceptedTerms = true;

  // Без бізнес-логіки: реєстрація вважається успішною та веде на головну.
  void _handleRegister() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const AuthHeader(mode: AuthMode.register),
                  const SizedBox(height: 28),
                  const AppTextField(label: 'Ім’я та прізвище', icon: Icons.person),
                  const SizedBox(height: 16),
                  const AppTextField(
                    label: 'Електронна пошта',
                    icon: Icons.mail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  const AppTextField(
                    label: 'Пароль',
                    icon: Icons.lock,
                    isPassword: true,
                    helperText: 'Не менше 6 символів',
                  ),
                  const SizedBox(height: 16),
                  const AppTextField(
                    label: 'Підтвердження пароля',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _acceptedTerms,
                    onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Погоджуюсь з умовами використання',
                      style: TextStyle(fontSize: 14, color: AppColors.text),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Зареєструватися',
                    onPressed: _acceptedTerms ? _handleRegister : null,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                    child: const Text(
                      'Вже маєте акаунт? Увійти',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
