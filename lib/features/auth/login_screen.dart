import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import 'widgets/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'mykola.heiko@gmail.com');
  final _passwordController = TextEditingController(text: 'plantcare1');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Без бізнес-логіки: «успішний вхід» одразу відкриває головну сторінку.
  void _handleSignIn() {
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
                  const AuthHeader(mode: AuthMode.login),
                  const SizedBox(height: 28),
                  AppTextField(
                    label: 'Електронна пошта',
                    icon: Icons.mail,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: 'Пароль',
                    icon: Icons.lock,
                    isPassword: true,
                    controller: _passwordController,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
                      child: const Text(
                        'Забули пароль?',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(label: 'Увійти', onPressed: _handleSignIn),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.outline)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('або', style: TextStyle(color: AppColors.muted)),
                      ),
                      Expanded(child: Divider(color: AppColors.outline)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Створити новий акаунт',
                    outlined: true,
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed(AppRoutes.register),
                  ),
                  const SizedBox(height: 36),
                  const Text(
                    'Продовжуючи, ви погоджуєтесь з умовами використання '
                    'та політикою конфіденційності',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
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
