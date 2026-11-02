import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_snack_bar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import 'data/auth_failure.dart';
import 'data/auth_repository.dart';
import 'widgets/auth_header.dart';

/// ФВ-1. Реєстрація за email і паролем з валідацією полів через Form.
/// Після створення облікового запису [AuthGate] відкриває головний екран.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Ключ створюється один раз у State, а не в build().
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _acceptedTerms = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await AuthRepository.instance.signUp(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on AuthFailure catch (e) {
      if (mounted) context.showMessage(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    children: [
                      const AuthHeader(mode: AuthMode.register),
                      const SizedBox(height: 28),
                      AppTextField(
                        label: 'Ім’я та прізвище',
                        icon: Icons.person,
                        controller: _nameController,
                        validator: Validators.name,
                        enabled: !_loading,
                        keyboardType: TextInputType.name,
                        autofillHints: const [AutofillHints.name],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Електронна пошта',
                        icon: Icons.mail,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        validator: Validators.email,
                        enabled: !_loading,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Пароль',
                        icon: Icons.lock,
                        isPassword: true,
                        helperText: 'Не менше ${Validators.minPasswordLength} символів',
                        controller: _passwordController,
                        validator: Validators.newPassword,
                        enabled: !_loading,
                        autofillHints: const [AutofillHints.newPassword],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Підтвердження пароля',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: _confirmController,
                        validator: Validators.confirmPassword(() => _passwordController.text),
                        enabled: !_loading,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _register(),
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: _acceptedTerms,
                        onChanged: _loading
                            ? null
                            : (v) => setState(() => _acceptedTerms = v ?? false),
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
                        isLoading: _loading,
                        onPressed: _acceptedTerms ? _register : null,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _loading ? null : () => Navigator.of(context).pop(),
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
        ),
      ),
    );
  }
}
