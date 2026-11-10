import '../entities/current_account.dart';
import '../repositories/auth_repository.dart';

final class ValidateSession {
  const ValidateSession(this._repository);
  final AuthRepository _repository;

  Future<CurrentAccount> call() => _repository.validateSession();
}
