class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

final class ApiException extends AppException {
  const ApiException({
    required String message,
    required this.statusCode,
    this.code,
    this.correlationId,
  }) : super(message);

  final int statusCode;
  final String? code;
  final String? correlationId;
  bool get isUnauthorized => statusCode == 401;
}

final class NetworkException extends AppException {
  const NetworkException(super.message);
}
