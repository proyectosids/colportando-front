import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/entities/current_account.dart';
import '../../domain/entities/login_credentials.dart';
import '../providers/auth_providers.dart';
import 'auth_error_presenter.dart';
import 'auth_state.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

final class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    try {
      final account = await ref.read(restoreSessionProvider)();
      return account == null
          ? const AuthState(status: AuthStatus.unauthenticated)
          : AuthState(status: AuthStatus.authenticated, account: account);
    } catch (error) {
      return AuthState(
        status: AuthStatus.unauthenticated,
        message: AuthErrorPresenter.messageFor(error),
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncData(
      AuthState(status: AuthStatus.unauthenticated, isBusy: true),
    );
    try {
      final account = await ref.read(authenticateUserProvider)(
        LoginCredentials(email: email, password: password),
      );
      state = AsyncData(
        AuthState(status: AuthStatus.authenticated, account: account),
      );
    } catch (error) {
      state = AsyncData(
        AuthState(
          status: AuthStatus.unauthenticated,
          message: AuthErrorPresenter.messageFor(error),
        ),
      );
    }
  }

  Future<void> validateSession() async {
    final current = state.value?.account;
    if (current == null) return;
    state = AsyncData(
      AuthState(
        status: AuthStatus.authenticated,
        account: current,
        isBusy: true,
      ),
    );
    try {
      final account = await ref.read(validateSessionProvider)();
      state = AsyncData(
        AuthState(
          status: AuthStatus.authenticated,
          account: account,
          message: 'La sesión está vigente y protegida.',
        ),
      );
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        state = const AsyncData(
          AuthState(
            status: AuthStatus.unauthenticated,
            message: 'Tu sesión terminó. Inicia sesión nuevamente.',
          ),
        );
        return;
      }
      _setAuthenticatedError(current, error);
    } catch (error) {
      _setAuthenticatedError(current, error);
    }
  }

  Future<void> logout() async {
    final current = state.value?.account;
    if (current == null) return;
    state = AsyncData(
      AuthState(
        status: AuthStatus.authenticated,
        account: current,
        isBusy: true,
      ),
    );
    try {
      await ref.read(logoutUserProvider)();
    } finally {
      state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<String> requestPasswordReset(String email) async {
    try {
      await ref.read(authActionsProvider).requestPasswordReset(email);
      return 'Si la cuenta es elegible, recibirás un correo con las instrucciones.';
    } catch (error) {
      return AuthErrorPresenter.messageFor(error);
    }
  }

  void _setAuthenticatedError(CurrentAccount current, Object error) {
    state = AsyncData(
      AuthState(
        status: AuthStatus.authenticated,
        account: current,
        message: AuthErrorPresenter.messageFor(error),
      ),
    );
  }
}
