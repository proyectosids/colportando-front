import '../entities/current_account.dart';
import '../repositories/auth_repository.dart';

final class RestoreSession {
  const RestoreSession(this._repository);
  final AuthRepository _repository;

  Future<CurrentAccount?> call() => _repository.restoreSession();
}
