import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/app_snack_bar.dart';
import '../shell/main_shell.dart';
import 'bloc/auth_bloc.dart';
import 'login_screen.dart';

/// Кореневий екран: за станом [AuthBloc] показує заставку (сеанс
/// відновлюється), вхід або головну частину застосунку.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          prev.status == AuthStatus.authenticated && curr.status == AuthStatus.unauthenticated,
      listener: (context, _) => context.showMessage('Ви вийшли з акаунта'),
      // Зміна імені чи фото не перебудовує весь застосунок – лише вхід/вихід.
      buildWhen: (prev, curr) => prev.status != curr.status,
      builder: (context, state) => switch (state.status) {
        AuthStatus.unknown => const _SplashScreen(),
        AuthStatus.unauthenticated => const LoginScreen(),
        AuthStatus.authenticated => const MainShell(),
      },
    );
  }
}

/// Поки Firebase відновлює збережений сеанс.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(),
            SizedBox(height: 24),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Відновлення сеансу…', style: TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
