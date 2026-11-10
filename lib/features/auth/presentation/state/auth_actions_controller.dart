import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/invitation.dart';
import '../providers/auth_providers.dart';
import 'auth_error_presenter.dart';

final authActionsControllerProvider =
    NotifierProvider<AuthActionsController, AuthActionState>(
      AuthActionsController.new,
    );

final class AuthActionState {
  const AuthActionState({
    this.isBusy = false,
    this.isError = false,
    this.message,
    this.invitation,
  });

  final bool isBusy;
  final bool isError;
  final String? message;
  final InvitationContext? invitation;
}

final class AuthActionsController extends Notifier<AuthActionState> {
  final Map<String, ({int signature, String key})> _idempotencyKeys = {};

  @override
  AuthActionState build() => const AuthActionState();

  Future<void> requestEmailVerification(String email) => _run(() async {
    await ref.read(authActionsProvider).requestEmailVerification(email);
    return 'Si la cuenta es elegible, se intentará enviar el correo.';
  });

  Future<void> confirmEmailVerification(String email, String code) => _run(
    () async {
      await ref.read(authActionsProvider).confirmEmailVerification(email, code);
      return 'Correo verificado. Ya puedes iniciar sesión.';
    },
  );

  Future<void> requestPasswordReset(String email) => _run(() async {
    await ref.read(authActionsProvider).requestPasswordReset(email);
    return 'Si la cuenta es elegible, se intentará enviar el correo.';
  });

  Future<void> confirmPasswordReset(
    String email,
    String code,
    String password,
  ) => _run(() async {
    await ref
        .read(authActionsProvider)
        .confirmPasswordReset(email, code, password);
    return 'Contraseña actualizada. Todas las sesiones anteriores se revocaron.';
  });

  Future<void> createInvitation({
    required String clubId,
    required String email,
  }) => _run(() async {
    final result = await ref
        .read(authActionsProvider)
        .createInvitation(
          clubId: clubId,
          email: email,
          idempotencyKey: _idempotencyKey(
            scope: 'invite',
            signature: Object.hash(clubId.trim(), email.trim().toLowerCase()),
          ),
        );
    return 'Invitación ${result.invitationId} creada hasta ${result.expiresAt.toLocal()}.';
  });

  Future<void> inspectInvitation(String email, String code) async {
    state = const AuthActionState(isBusy: true);
    try {
      final result = await ref
          .read(authActionsProvider)
          .inspectInvitation(email, code);
      state = AuthActionState(
        message: 'Invitación disponible para ${result.emailHint}.',
        invitation: result,
      );
    } catch (error) {
      state = AuthActionState(
        isError: true,
        message: AuthErrorPresenter.messageFor(error),
      );
    }
  }

  Future<void> acceptInvitation({
    required String email,
    required String code,
    required String password,
    required String givenNames,
    required String familyName,
    String? secondFamilyName,
    String? phoneE164,
  }) => _run(() async {
    final signature = Object.hash(
      email.trim().toLowerCase(),
      code.trim(),
      password,
      givenNames.trim(),
      familyName.trim(),
      secondFamilyName?.trim(),
      phoneE164?.trim(),
    );
    final result = await ref
        .read(authActionsProvider)
        .acceptInvitation(
          AcceptInvitationInput(
            email: email,
            code: code,
            password: password,
            givenNames: givenNames,
            familyName: familyName,
            secondFamilyName: secondFamilyName,
            phoneE164: phoneE164,
            idempotencyKey: _idempotencyKey(
              scope: 'accept',
              signature: signature,
            ),
          ),
        );
    return 'Registro completado como ${result.memberCondition}. Membresía ${result.membershipStatus}.';
  });

  Future<void> _run(Future<String> Function() operation) async {
    state = const AuthActionState(isBusy: true);
    try {
      state = AuthActionState(message: await operation());
    } catch (error) {
      state = AuthActionState(
        isError: true,
        message: AuthErrorPresenter.messageFor(error),
      );
    }
  }

  String _idempotencyKey({required String scope, required int signature}) {
    final existing = _idempotencyKeys[scope];
    if (existing != null && existing.signature == signature) {
      return existing.key;
    }
    final key = '$scope-${DateTime.now().microsecondsSinceEpoch}';
    _idempotencyKeys[scope] = (signature: signature, key: key);
    return key;
  }
}
