import '../entities/current_account.dart';
import '../entities/login_credentials.dart';
import '../repositories/auth_repository.dart';

final class AuthenticateUser {
  const AuthenticateUser(this._repository);
  final AuthRepository _repository;

  Future<CurrentAccount> call(LoginCredentials credentials) =>
      _repository.login(credentials);
}
