final class LoginCredentials {
  const LoginCredentials({
    required this.email,
    required this.password,
    this.clientName = 'Colportando Flutter',
  });

  final String email;
  final String password;
  final String clientName;
}
