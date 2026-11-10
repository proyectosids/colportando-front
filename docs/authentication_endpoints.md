# Guía de Authentication

Base predeterminada: `https://colportando-app.apps.isdapps.uk/api/v1/`.

| Endpoint | Autorización | Implementación Flutter |
|---|---|---|
| `POST /auth/login` | Pública | `AuthRemoteDataSource.login` |
| `POST /auth/refresh` | Refresh token en cuerpo | `AuthRemoteDataSource.refresh` |
| `POST /auth/logout` | Refresh token en cuerpo | `AuthRemoteDataSource.logout` |
| `GET /auth/me` | Bearer access token | `AuthRemoteDataSource.me` |
| `POST /auth/email-verification/request` | Pública | `requestEmailVerification` |
| `POST /auth/email-verification/confirm` | Correo + código de 8 dígitos | `confirmEmailVerification` |
| `POST /auth/password-reset/request` | Pública | `requestPasswordReset` |
| `POST /auth/password-reset/confirm` | Correo + código de 8 dígitos | `confirmPasswordReset` |
| `POST /auth/invitations` | Bearer + permiso + idempotencia | `createInvitation` |
| `POST /auth/invitations/inspect` | Correo + código de invitación | `inspectInvitation` |
| `POST /auth/invitations/accept` | Correo + código + idempotencia | `acceptInvitation` |

## Responsabilidades por capa

- Los widgets sólo envían datos al `AuthController` o `AuthActionsController` de Riverpod.
- Los controladores ejecutan casos de uso y convierten errores técnicos en mensajes útiles.
- `AuthRepositoryImpl` administra access/refresh, reintenta una vez un `401` y serializa las rotaciones concurrentes.
- `AuthRemoteDataSource` conoce rutas, métodos, encabezados y JSON.
- `SecureTokenStorage` guarda únicamente el refresh token. La contraseña y el access token nunca se persisten.

## Rotación

Cada respuesta de `/auth/refresh` sustituye ambos tokens. El token anterior no puede volver a usarse: el backend interpretaría su reutilización como posible robo y revocaría la familia completa. `_refreshInFlight` evita dos rotaciones simultáneas.

## Idempotencia

Crear y aceptar invitaciones usa `Idempotency-Key`. El controlador conserva la misma clave cuando el usuario reintenta exactamente el mismo contenido; si cambia el contenido, genera otra. Esto permite recuperarse de una desconexión sin duplicar la operación.

## Flujos de UI

- Login normal: pantalla principal.
- Recuperación rápida: “¿Olvidaste tu contraseña?”.
- Todos los contratos: “Explorar todos los endpoints” o el icono de matraz tras iniciar sesión.
- Crear invitación sólo aparece autenticado; el backend vuelve a validar permisos y alcance.
- Inspeccionar/aceptar invitación es público. Si el correo ya existe, la contraseña debe corresponder a esa cuenta.

Los correos no dependen de una página web ni de deep links. La persona escribe en la app el código de un solo uso recibido por correo. Verificación y recuperación usan 8 dígitos; las invitaciones usan un código alfanumérico más largo.
