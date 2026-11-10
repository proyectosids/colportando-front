import '../../domain/entities/current_account.dart';

enum AuthStatus { initializing, unauthenticated, authenticated }

final class AuthState {
  const AuthState({
    required this.status,
    this.account,
    this.isBusy = false,
    this.message,
  });

  const AuthState.initializing()
    : this(status: AuthStatus.initializing, isBusy: true);

  final AuthStatus status;
  final CurrentAccount? account;
  final bool isBusy;
  final String? message;
}
