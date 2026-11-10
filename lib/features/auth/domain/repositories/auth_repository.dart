import '../entities/current_account.dart';
import '../entities/login_credentials.dart';
import '../entities/invitation.dart';

abstract interface class AuthRepository {
  Future<CurrentAccount> login(LoginCredentials credentials);
  Future<CurrentAccount?> restoreSession();
  Future<CurrentAccount> validateSession();
  Future<void> logout();
  Future<void> requestPasswordReset(String email);
  Future<void> requestEmailVerification(String email);
  Future<void> confirmEmailVerification(String email, String code);
  Future<void> confirmPasswordReset(String email, String code, String newPassword);
  Future<InvitationCreated> createInvitation({
    required String clubId,
    required String email,
    required String idempotencyKey,
  });
  Future<InvitationContext> inspectInvitation(String email, String code);
  Future<InvitationAccepted> acceptInvitation(AcceptInvitationInput input);
}
