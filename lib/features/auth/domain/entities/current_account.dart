final class CurrentAccount {
  const CurrentAccount({
    required this.accountId,
    required this.email,
    required this.status,
    required this.sessionId,
  });

  final String accountId;
  final String email;
  final String status;
  final String sessionId;
}
