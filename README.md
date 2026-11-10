# Colportando App

Base Flutter educativa y ejecutable para consumir toda la sección `Authentication` de Colportando con Clean Architecture y Riverpod.

## Requisitos

- Flutter estable 3.47 o compatible
- Dart 3.13 o compatible
- Android 6.0+ para almacenamiento seguro
- HTTPS en despliegues web

## Ejecutar

La API publicada ya es el valor predeterminado:

```powershell
flutter pub get
flutter run
```

Para apuntar a otro entorno, la URL debe terminar en `/`:

```powershell
flutter run --dart-define=API_BASE_URL=https://servidor.example/api/v1/
```

Para Flutter Web local usa un puerto fijo:

```powershell
flutter run -d chrome --web-port 5173
```

El backend debe incluir exactamente `http://localhost:5173` en `CORS_ALLOWED_ORIGINS`. En Android/iOS no aplica CORS, pero sí se requiere conectividad HTTPS.

## Flujo implementado

1. Al iniciar, busca el refresh token en almacenamiento seguro.
2. Si existe, llama a `POST /auth/refresh`, reemplaza ambos tokens y valida con `GET /auth/me`.
3. Login usa `POST /auth/login`; la contraseña nunca se persiste.
4. La validación de sesión reintenta una vez con refresh ante un `401`.
5. Logout llama a `POST /auth/logout` y borra siempre los tokens locales.
6. “Olvidé mi contraseña” llama a `POST /auth/password-reset/request` y conserva la respuesta neutral del backend.
7. El laboratorio accesible desde el icono de matraz cubre verificación de correo, confirmación de contraseña, creación, inspección y aceptación de invitaciones.

El access token permanece en memoria y el refresh token se guarda cifrado. En web, `flutter_secure_storage` requiere HTTPS o localhost.

## Calidad

```powershell
dart format .
flutter analyze
flutter test
```

Consulta [docs/architecture.md](docs/architecture.md) y [docs/authentication_endpoints.md](docs/authentication_endpoints.md) antes de añadir funcionalidades o dependencias.

## Referencias visuales

La paleta parte del logotipo público de SEHS (`#1E487A`, `#239E6C`), los colores de su sitio y el acento verde visible en material institucional de Kerusso. El isotipo mostrado por la aplicación es propio y no sustituye un manual oficial de marca.
