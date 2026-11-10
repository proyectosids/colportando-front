# Contrato de arquitectura

Fecha de decisión: 2026-11-09.

## Alcance inicial

Aplicación Flutter de ventas de libros para Colportando y el Club de Colportores Kerusso. Este corte implementa los 11 endpoints publicados bajo `Authentication`: sesión, verificación, recuperación e invitaciones.

## Estructura acordada

Se usa Clean Architecture orientada por funcionalidad:

```text
lib/
  app/                         composición, tema e inyección manual
  core/                        configuración y errores compartidos
  features/auth/
    domain/                    entidades, contratos y casos de uso
    data/                      DTO, HTTP, almacenamiento y repositorio
    presentation/              estado, páginas y widgets
```

La dirección de dependencias es `presentation -> domain <- data`. El dominio no importa Flutter, HTTP ni almacenamiento. Los DTO pertenecen a data y se convierten explícitamente a entidades.

## Decisiones

- Estado y DI: Riverpod 3 con `AsyncNotifier`, `Notifier` y proveedores reemplazables en pruebas. No se usa generación de código.
- Navegación: estado raíz; se añadirá un router cuando existan rutas y enlaces profundos reales.
- Red: `package:http` con un `Client` inyectado y comprobable.
- Persistencia: sólo el refresh token se guarda mediante `flutter_secure_storage`; el access token permanece en memoria.
- Refresh: rotación de un solo vuelo. Nunca se reutiliza deliberadamente un refresh consumido.
- Configuración: `API_BASE_URL` se proporciona con `--dart-define` y debe terminar en `/`.
- Errores: el sobre `{error: {code, message, correlationId}}` se mapea en data y se traduce a mensajes accionables en presentación.
- Idempotencia: la creación y aceptación de invitaciones generan claves distintas por operación y nunca las reutilizan con otro cuerpo.

## Reglas para siguientes módulos

1. No importar DTO desde presentación.
2. No leer tokens desde widgets.
3. No autorizar por rol visual; consumir `permissions` desde `/workspace/context`.
4. No registrar contraseñas, access tokens ni refresh tokens.
5. Cada dependencia nueva requiere una necesidad concreta y revisión en pub.dev.
6. Catálogo, campañas y ventas se agregan como funcionalidades hermanas, no dentro de `auth`.
