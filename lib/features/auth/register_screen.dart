import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_snack_bar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import 'bloc/register_bloc.dart';
import 'data/auth_repository.dart';
import 'widgets/auth_header.dart';

/// ФВ-1. Реєстрація за email і паролем з валідацією полів через Form.
/// Після створення облікового запису AuthBloc отримує користувача,
/// і [AuthGate] відкриває головний екран.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterBloc(context.read<AuthRepository>()),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _acceptedTerms = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<RegisterBloc>().add(RegisterSubmitted(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ));
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
              child: BlocConsumer<RegisterBloc, RegisterState>(
                listener: (context, state) {
                  if (state is RegisterFailure) context.showMessage(state.message, isError: true);
                },
                builder: (context, state) => _buildForm(loading: state is RegisterLoading),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm({required bool loading}) {
    return Form(
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
              enabled: !loading,
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
              enabled: !loading,
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
              enabled: !loading,
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Підтвердження пароля',
              icon: Icons.lock_outline,
              isPassword: true,
              controller: _confirmController,
              validator: Validators.confirmPassword(() => _passwordController.text),
              enabled: !loading,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _register(),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _acceptedTerms,
              onChanged: loading ? null : (v) => setState(() => _acceptedTerms = v ?? false),
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
              isLoading: loading,
              onPressed: _acceptedTerms ? _register : null,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: loading ? null : () => Navigator.of(context).pop(),
              child: const Text(
                'Вже маєте акаунт? Увійти',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
