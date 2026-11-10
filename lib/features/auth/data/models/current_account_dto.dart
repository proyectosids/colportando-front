import '../../domain/entities/current_account.dart';

final class CurrentAccountDto {
  const CurrentAccountDto({
    required this.accountId,
    required this.email,
    required this.status,
    required this.sessionId,
  });

  factory CurrentAccountDto.fromJson(Map<String, Object?> json) {
    return CurrentAccountDto(
      accountId: json['accountId'] as String,
      email: json['email'] as String,
      status: json['status'] as String,
      sessionId: json['sessionId'] as String,
    );
  }

  final String accountId;
  final String email;
  final String status;
  final String sessionId;

  CurrentAccount toDomain() => CurrentAccount(
    accountId: accountId,
    email: email,
    status: status,
    sessionId: sessionId,
  );
}
