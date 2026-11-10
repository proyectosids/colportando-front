final class InvitationCreated {
  const InvitationCreated({
    required this.invitationId,
    required this.status,
    required this.expiresAt,
    required this.replayed,
  });

  final String invitationId;
  final String status;
  final DateTime expiresAt;
  final bool replayed;
}

final class InvitationContext {
  const InvitationContext({
    required this.invitationId,
    required this.clubName,
    required this.institutionName,
    required this.emailHint,
    required this.expiresAt,
  });

  final String invitationId;
  final String clubName;
  final String institutionName;
  final String emailHint;
  final DateTime expiresAt;
}

final class InvitationAccepted {
  const InvitationAccepted({
    required this.accountId,
    required this.personId,
    required this.membershipId,
    required this.membershipStatus,
    required this.memberCondition,
    required this.emailVerified,
    required this.replayed,
  });

  final String accountId;
  final String personId;
  final String membershipId;
  final String membershipStatus;
  final String memberCondition;
  final bool emailVerified;
  final bool replayed;
}

final class AcceptInvitationInput {
  const AcceptInvitationInput({
    required this.email,
    required this.code,
    required this.password,
    required this.givenNames,
    required this.familyName,
    required this.idempotencyKey,
    this.secondFamilyName,
    this.phoneE164,
  });

  final String email;
  final String code;
  final String password;
  final String givenNames;
  final String familyName;
  final String? secondFamilyName;
  final String? phoneE164;
  final String idempotencyKey;
}
