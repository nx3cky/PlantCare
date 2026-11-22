import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_snack_bar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import 'data/auth_failure.dart';
import 'data/auth_repository.dart';

/// ФВ-3. Відновлення пароля: Firebase надсилає лист із посиланням.
class ForgotPasswordScreen extends StatefulWidget {
  /// Email, уже введений на екрані входу.
  final String? initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(text: widget.initialEmail);
  bool _loading = false;
  String? _sentTo;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final email = _emailController.text.trim();
    try {
      await context.read<AuthRepository>().sendPasswordReset(email);
      if (!mounted) return;
      setState(() => _sentTo = email);
      context.showMessage('Лист для відновлення пароля надіслано на $email');
    } on AuthFailure catch (e) {
      if (mounted) context.showMessage(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
          child: Form(
            key: _formKey,
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
                  validator: Validators.email,
                  enabled: !_loading,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _sendResetLink(),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: _sentTo != null ? 'Надіслати ще раз' : 'Надіслати посилання',
                  icon: Icons.send,
                  isLoading: _loading,
                  onPressed: _sendResetLink,
                ),
                const SizedBox(height: 20),
                if (_sentTo != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mark_email_read, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Якщо акаунт $_sentTo існує, на нього надіслано лист. '
                            'Не знайшли лист? Перегляньте папку «Спам».',
                            style: const TextStyle(fontSize: 14, color: AppColors.onPrimaryContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: _loading ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Повернутися до входу'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
