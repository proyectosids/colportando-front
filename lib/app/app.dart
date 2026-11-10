import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/pages/account_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/state/auth_state.dart';
import '../features/auth/presentation/state/auth_controller.dart';
import 'app_theme.dart';

class ColportandoApp extends ConsumerWidget {
  const ColportandoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Colportando',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: _AuthGate(auth: ref.watch(authControllerProvider)),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate({required this.auth});

  final AsyncValue<AuthState> auth;

  @override
  Widget build(BuildContext context) {
    return auth.when(
      loading: () => const SplashPage(),
      error: (error, _) => LoginPage(
        key: const ValueKey('login-error'),
        initialMessage: error.toString(),
      ),
      data: (state) => switch (state.status) {
        AuthStatus.initializing => const SplashPage(),
        AuthStatus.unauthenticated => LoginPage(
          key: const ValueKey('login'),
          initialMessage: state.message,
        ),
        AuthStatus.authenticated => AccountPage(
          key: const ValueKey('account'),
          account: state.account!,
          state: state,
        ),
      },
    );
  }
}
