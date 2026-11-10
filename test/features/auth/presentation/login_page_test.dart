import 'package:colportando_app/features/auth/domain/entities/current_account.dart';
import 'package:colportando_app/features/auth/domain/entities/invitation.dart';
import 'package:colportando_app/features/auth/domain/entities/login_credentials.dart';
import 'package:colportando_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:colportando_app/features/auth/presentation/pages/login_page.dart';
import 'package:colportando_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('valida el formulario sin perder los campos', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        ],
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();

    expect(find.text('Escribe un correo válido.'), findsOneWidget);
    expect(find.text('Escribe tu contraseña.'), findsOneWidget);
  });
}

final class _FakeAuthRepository implements AuthRepository {
  @override
  Future<InvitationAccepted> acceptInvitation(AcceptInvitationInput input) =>
      throw UnimplementedError();

  @override
  Future<void> confirmEmailVerification(String email, String code) async {}

  @override
  Future<void> confirmPasswordReset(String email, String code, String newPassword) async {}

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
