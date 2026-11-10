import '../repositories/auth_repository.dart';

final class LogoutUser {
  const LogoutUser(this._repository);
  final AuthRepository _repository;

  Future<void> call() => _repository.logout();
}
