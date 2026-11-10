import '../../../../core/error/app_exception.dart';

abstract final class AuthErrorPresenter {
  static String messageFor(Object error) {
    if (error is ApiException) {
      return switch (error.code) {
        'INVALID_CREDENTIALS' => 'El correo o la contraseña no son correctos.',
        'CORS_ORIGIN_DENIED' =>
          'El servidor no permite solicitudes desde este origen.',
        'RATE_LIMIT_EXCEEDED' =>
          'Hubo demasiados intentos. Espera unos minutos e inténtalo de nuevo.',
        'REFRESH_TOKEN_REUSED' =>
          'La sesión fue cerrada por seguridad. Inicia sesión nuevamente.',
        'ACTION_TOKEN_EXPIRED' => 'El enlace ya venció. Solicita uno nuevo.',
        'ACTION_TOKEN_USED' => 'El enlace ya fue utilizado.',
        'INVITATION_NOT_AVAILABLE' =>
          'La invitación venció, ya fue utilizada o no está disponible.',
        'PASSWORD_POLICY_VIOLATION' =>
          'La contraseña no cumple la política de seguridad.',
        _ =>
          error.correlationId == null
              ? error.message
              : '${error.message} Seguimiento: ${error.correlationId}',
      };
    }
    if (error is AppException) return error.message;
    return 'Ocurrió un error inesperado. Inténtalo nuevamente.';
  }
}
