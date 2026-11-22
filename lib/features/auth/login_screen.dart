import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_snack_bar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/google_sign_in_button.dart';
import '../../core/widgets/primary_button.dart';
import 'bloc/login_bloc.dart';
import 'data/auth_repository.dart';
import 'widgets/auth_header.dart';

/// ФВ-2. Вхід за email і паролем або через Google.
/// [LoginBloc] створюється для екрана й отримує репозиторій із дерева віджетів.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(context.read<AuthRepository>()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  // Текст полів – ефемерний стан екрана, тому лишається у State.
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<LoginBloc>().add(LoginSubmitted(_emailController.text.trim(), _passwordController.text));
  }

  void _signInWithGoogle() {
    FocusScope.of(context).unfocus();
    context.read<LoginBloc>().add(const LoginWithGoogleSubmitted());
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
              // BlocListener – одноразова дія (SnackBar), BlocBuilder – перебудова кнопок.
              child: BlocListener<LoginBloc, LoginState>(
                listener: (context, state) {
                  if (state is LoginFailure) context.showMessage(state.message, isError: true);
                },
                child: BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    final loading = state is LoginLoading ? state.method : null;
                    return _buildForm(loading);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(LoginMethod? loading) {
    final busy = loading != null;
    return Form(
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
                child: const Text('Забули пароль?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Увійти',
              isLoading: loading == LoginMethod.email,
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
              isLoading: loading == LoginMethod.google,
              onPressed: busy ? null : _signInWithGoogle,
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Створити новий акаунт',
              outlined: true,
              onPressed: busy ? null : () => Navigator.of(context).pushNamed(AppRoutes.register),
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
    );
  }
}
