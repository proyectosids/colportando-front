import 'package:colportando_app/features/auth/domain/entities/current_account.dart';
import 'package:colportando_app/features/auth/domain/entities/invitation.dart';
import 'package:colportando_app/features/auth/domain/entities/login_credentials.dart';
import 'package:colportando_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:colportando_app/features/auth/presentation/pages/auth_actions_page.dart';
import 'package:colportando_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra confirmación visible al cambiar la contraseña', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_SuccessfulRepository()),
        ],
        child: const MaterialApp(home: AuthActionsPage(authenticated: false)),
      ),
    );

    await tester.tap(find.text('Recuperación de contraseña'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Correo').last,
      'member@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Código de 8 dígitos').last,
      '48271936',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Nueva contraseña'),
      'Nueva-clave-segura-123!',
    );
    final changePasswordLabel = find.text('Cambiar contraseña').last;
    await tester.drag(find.byType(ListView), const Offset(0, -320));
    await tester.pumpAndSettle();
    await tester.tap(changePasswordLabel);
    await tester.pump();
    await tester.pump();

    expect(
      find.text(
        'Contraseña actualizada. Todas las sesiones anteriores se revocaron.',
      ),
      findsWidgets,
    );
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}

final class _SuccessfulRepository implements AuthRepository {
  @override
  Future<void> confirmPasswordReset(
    String email,
    String code,
    String newPassword,
  ) async {}

  @override
  Future<InvitationAccepted> acceptInvitation(AcceptInvitationInput input) =>
      throw UnimplementedError();

  @override
  Future<void> confirmEmailVerification(String email, String code) async {}

  @override
  Future<InvitationCreated> createInvitation({
    required String clubId,
    required String email,
    required String idempotencyKey,
  }) => throw UnimplementedError();

  @override
  Future<InvitationContext> inspectInvitation(String email, String code) =>
      throw UnimplementedError();

  @override
  Future<CurrentAccount> login(LoginCredentials credentials) =>
      throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
  Future<void> requestEmailVerification(String email) async {}

  @override
  Future<void> requestPasswordReset(String email) async {}

  @override
  Future<CurrentAccount?> restoreSession() async => null;

  @override
  Future<CurrentAccount> validateSession() => throw UnimplementedError();
}
