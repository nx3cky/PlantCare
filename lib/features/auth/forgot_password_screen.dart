import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController(text: 'mykola.heiko@gmail.com');
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Без бізнес-логіки: лист не надсилається, лише показується стан «надіслано».
  void _sendResetLink() {
    setState(() => _sent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Посилання надіслано на ${_emailController.text}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Відновлення пароля'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_reset, size: 48, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Забули пароль?',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.text),
              ),
              const SizedBox(height: 8),
              const Text(
                'Введіть електронну пошту, вказану під час реєстрації. '
                'Ми надішлемо на неї посилання для створення нового пароля.',
                style: TextStyle(fontSize: 15, height: 1.4, color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Електронна пошта',
                icon: Icons.mail,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _sent ? 'Надіслати ще раз' : 'Надіслати посилання',
                icon: Icons.send,
                onPressed: _sendResetLink,
              ),
              const SizedBox(height: 20),
              if (_sent)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.mark_email_read, color: AppColors.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Перевірте пошту – посилання дійсне протягом 30 хвилин. '
                          'Не знайшли лист? Перегляньте папку «Спам».',
                          style: TextStyle(fontSize: 14, color: AppColors.onPrimaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Повернутися до входу'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
