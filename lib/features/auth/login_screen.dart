import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_snack_bar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/google_sign_in_button.dart';
import '../../core/widgets/primary_button.dart';
import 'data/auth_failure.dart';
import 'data/auth_repository.dart';
import 'widgets/auth_header.dart';

/// ФВ-2. Вхід за email і паролем або через Google.
/// Після успішного входу [AuthGate] сам відкриває головний екран.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _LoginAction { email, google }

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Яка дія зараз виконується; поки не null – усі кнопки заблоковані.
  _LoginAction? _loading;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_loading != null || !_formKey.currentState!.validate()) return;
    await _run(
      _LoginAction.email,
      () => AuthRepository.instance.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    if (_loading != null) return;
    await _run(_LoginAction.google, AuthRepository.instance.signInWithGoogle);
  }

  Future<void> _run(_LoginAction action, Future<void> Function() request) async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = action);
    try {
      await request();
    } on AuthFailure catch (e) {
      if (mounted) context.showMessage(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _loading = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _loading != null;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    children: [
                      const AuthHeader(mode: AuthMode.login),
                      const SizedBox(height: 28),
                      AppTextField(
                        label: 'Електронна пошта',
                        icon: Icons.mail,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        validator: Validators.email,
                        enabled: !busy,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Пароль',
                        icon: Icons.lock,
                        isPassword: true,
                        controller: _passwordController,
                        validator: Validators.password,
                        enabled: !busy,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _signIn(),
                        autofillHints: const [AutofillHints.password],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: busy
                              ? null
                              : () => Navigator.of(context).pushNamed(
                                    AppRoutes.forgotPassword,
                                    arguments: _emailController.text.trim(),
                                  ),
                          child: const Text(
                            'Забули пароль?',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'Увійти',
                        isLoading: _loading == _LoginAction.email,
                        onPressed: busy ? null : _signIn,
                      ),
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
                      GoogleSignInButton(
                        isLoading: _loading == _LoginAction.google,
                        onPressed: busy ? null : _signInWithGoogle,
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'Створити новий акаунт',
                        outlined: true,
                        onPressed: busy
                            ? null
                            : () => Navigator.of(context).pushNamed(AppRoutes.register),
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
        ),
      ),
    );
  }
}
