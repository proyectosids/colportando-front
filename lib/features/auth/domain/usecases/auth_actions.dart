import '../entities/invitation.dart';
import '../repositories/auth_repository.dart';

final class AuthActions {
  const AuthActions(this._repository);
  final AuthRepository _repository;

  Future<void> requestEmailVerification(String email) =>
      _repository.requestEmailVerification(email);

  Future<void> confirmEmailVerification(String email, String code) =>
      _repository.confirmEmailVerification(email, code);

  Future<void> requestPasswordReset(String email) =>
      _repository.requestPasswordReset(email);

  Future<void> confirmPasswordReset(String email, String code, String newPassword) =>
      _repository.confirmPasswordReset(email, code, newPassword);

  Future<InvitationCreated> createInvitation({
    required String clubId,
    required String email,
    required String idempotencyKey,
  }) => _repository.createInvitation(
    clubId: clubId,
    email: email,
    idempotencyKey: idempotencyKey,
  );

  Future<InvitationContext> inspectInvitation(String email, String code) =>
      _repository.inspectInvitation(email, code);

  Future<InvitationAccepted> acceptInvitation(AcceptInvitationInput input) =>
      _repository.acceptInvitation(input);
}
