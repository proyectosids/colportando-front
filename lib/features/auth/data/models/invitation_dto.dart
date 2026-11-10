import '../../domain/entities/invitation.dart';

final class InvitationCreatedDto {
  const InvitationCreatedDto({
    required this.invitationId,
    required this.status,
    required this.expiresAt,
    required this.replayed,
  });

  factory InvitationCreatedDto.fromJson(Map<String, Object?> json) =>
      InvitationCreatedDto(
        invitationId: json['invitationId'] as String,
        status: json['status'] as String,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        replayed: json['replayed'] as bool,
      );

  final String invitationId;
  final String status;
  final DateTime expiresAt;
  final bool replayed;

  InvitationCreated toDomain() => InvitationCreated(
    invitationId: invitationId,
    status: status,
    expiresAt: expiresAt,
    replayed: replayed,
  );
}

final class InvitationContextDto {
  const InvitationContextDto({
    required this.invitationId,
    required this.clubName,
    required this.institutionName,
    required this.emailHint,
    required this.expiresAt,
  });

  factory InvitationContextDto.fromJson(Map<String, Object?> json) =>
      InvitationContextDto(
        invitationId: json['invitationId'] as String,
        clubName: json['clubName'] as String,
        institutionName: json['institutionName'] as String,
        emailHint: json['emailHint'] as String,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );

  final String invitationId;
  final String clubName;
  final String institutionName;
  final String emailHint;
  final DateTime expiresAt;

  InvitationContext toDomain() => InvitationContext(
    invitationId: invitationId,
    clubName: clubName,
    institutionName: institutionName,
    emailHint: emailHint,
    expiresAt: expiresAt,
  );
}

final class InvitationAcceptedDto {
  const InvitationAcceptedDto({
    required this.accountId,
    required this.personId,
    required this.membershipId,
    required this.membershipStatus,
    required this.memberCondition,
    required this.emailVerified,
    required this.replayed,
  });

  factory InvitationAcceptedDto.fromJson(Map<String, Object?> json) =>
      InvitationAcceptedDto(
        accountId: json['accountId'] as String,
        personId: json['personId'] as String,
        membershipId: json['membershipId'] as String,
        membershipStatus: json['membershipStatus'] as String,
        memberCondition: json['memberCondition'] as String,
        emailVerified: json['emailVerified'] as bool,
        replayed: json['replayed'] as bool,
      );

  final String accountId;
  final String personId;
  final String membershipId;
  final String membershipStatus;
  final String memberCondition;
  final bool emailVerified;
  final bool replayed;

  InvitationAccepted toDomain() => InvitationAccepted(
    accountId: accountId,
    personId: personId,
    membershipId: membershipId,
    membershipStatus: membershipStatus,
    memberCondition: memberCondition,
    emailVerified: emailVerified,
    replayed: replayed,
  );
}
