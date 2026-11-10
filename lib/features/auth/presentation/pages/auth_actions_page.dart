import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/invitation.dart';
import '../state/auth_actions_controller.dart';

class AuthActionsPage extends ConsumerStatefulWidget {
  const AuthActionsPage({required this.authenticated, super.key});

  final bool authenticated;

  @override
  ConsumerState<AuthActionsPage> createState() => _AuthActionsPageState();
}

class _AuthActionsPageState extends ConsumerState<AuthActionsPage> {
  final _verificationEmail = TextEditingController();
  final _verificationToken = TextEditingController();
  final _resetEmail = TextEditingController();
  final _resetToken = TextEditingController();
  final _newPassword = TextEditingController();
  final _clubId = TextEditingController();
  final _invitationEmail = TextEditingController();
  final _invitationTargetEmail = TextEditingController();
  final _invitationToken = TextEditingController();
  final _givenNames = TextEditingController();
  final _familyName = TextEditingController();
  final _secondFamilyName = TextEditingController();
  final _phone = TextEditingController();
  final _invitationPassword = TextEditingController();

  @override
  void dispose() {
    for (final controller in [
      _verificationEmail,
      _verificationToken,
      _resetEmail,
      _resetToken,
      _newPassword,
      _clubId,
      _invitationEmail,
      _invitationTargetEmail,
      _invitationToken,
      _givenNames,
      _familyName,
      _secondFamilyName,
      _phone,
      _invitationPassword,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authActionsControllerProvider);
    final actions = ref.read(authActionsControllerProvider.notifier);
    ref.listen<AuthActionState>(authActionsControllerProvider, (
      previous,
      next,
    ) {
      final message = next.message;
      if (message == null ||
          (message == previous?.message && next.isError == previous?.isError)) {
        return;
      }
      final colors = Theme.of(context).colorScheme;
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: next.isError
                ? colors.errorContainer
                : colors.primaryContainer,
            content: Row(
              children: [
                Icon(
                  next.isError ? Icons.error_outline : Icons.check_circle,
                  color: next.isError
                      ? colors.onErrorContainer
                      : colors.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: next.isError
                          ? colors.onErrorContainer
                          : colors.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Endpoints de Authentication')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Text(
              'Laboratorio didáctico',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Cada sección consume el backend real. Los códigos son personales: no los compartas ni los incluyas en logs o capturas.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (state.message != null) ...[
              const SizedBox(height: 16),
              _ResultBanner(message: state.message!, isError: state.isError),
            ],
            const SizedBox(height: 16),
            _EndpointCard(
              title: 'Verificación de correo',
              subtitle: 'Solicitar y confirmar un código de 8 dígitos.',
              children: [
                _field(
                  _verificationEmail,
                  'Correo',
                  type: TextInputType.emailAddress,
                ),
                _ActionButton(
                  label: 'Solicitar verificación',
                  endpoint: 'POST /auth/email-verification/request',
                  busy: state.isBusy,
                  onPressed: () =>
                      actions.requestEmailVerification(_verificationEmail.text),
                ),
                _field(
                  _verificationToken,
                  'Código de 8 dígitos',
                  type: TextInputType.number,
                ),
                _ActionButton(
                  label: 'Confirmar correo',
                  endpoint: 'POST /auth/email-verification/confirm',
                  busy: state.isBusy,
                  onPressed: () => actions.confirmEmailVerification(
                    _verificationEmail.text,
                    _verificationToken.text,
                  ),
                ),
              ],
            ),
            _EndpointCard(
              title: 'Recuperación de contraseña',
              subtitle: 'La confirmación revoca las sesiones anteriores.',
              children: [
                _field(_resetEmail, 'Correo', type: TextInputType.emailAddress),
                _ActionButton(
                  label: 'Solicitar recuperación',
                  endpoint: 'POST /auth/password-reset/request',
                  busy: state.isBusy,
                  onPressed: () =>
                      actions.requestPasswordReset(_resetEmail.text),
                ),
                _field(
                  _resetToken,
                  'Código de 8 dígitos',
                  type: TextInputType.number,
                ),
                _field(_newPassword, 'Nueva contraseña', obscure: true),
                _ActionButton(
                  label: 'Cambiar contraseña',
                  endpoint: 'POST /auth/password-reset/confirm',
                  busy: state.isBusy,
                  onPressed: () => actions.confirmPasswordReset(
                    _resetEmail.text,
                    _resetToken.text,
                    _newPassword.text,
                  ),
                ),
              ],
            ),
            if (widget.authenticated)
              _EndpointCard(
                title: 'Crear invitación',
                subtitle: 'Requiere sesión, permiso de club e Idempotency-Key.',
                children: [
                  _field(_clubId, 'Club ID'),
                  _field(
                    _invitationEmail,
                    'Correo del aspirante',
                    type: TextInputType.emailAddress,
                  ),
                  _ActionButton(
                    label: 'Enviar invitación',
                    endpoint: 'POST /auth/invitations',
                    busy: state.isBusy,
                    onPressed: () => actions.createInvitation(
                      clubId: _clubId.text,
                      email: _invitationEmail.text,
                    ),
                  ),
                ],
              ),
            _EndpointCard(
              title: 'Invitación pública',
              subtitle: 'Inspeccionar y aceptar una invitación como aspirante.',
              children: [
                _field(
                  _invitationTargetEmail,
                  'Correo invitado',
                  type: TextInputType.emailAddress,
                ),
                _field(
                  _invitationToken,
                  'Código de invitación',
                  hint: 'K7M2-P9Q4-X6RT',
                ),
                _ActionButton(
                  label: 'Inspeccionar invitación',
                  endpoint: 'POST /auth/invitations/inspect',
                  busy: state.isBusy,
                  onPressed: () => actions.inspectInvitation(
                    _invitationTargetEmail.text,
                    _invitationToken.text,
                  ),
                ),
                if (state.invitation != null)
                  _InvitationPreview(invitation: state.invitation!),
                _field(_givenNames, 'Nombre(s)'),
                _field(_familyName, 'Primer apellido'),
                _field(_secondFamilyName, 'Segundo apellido (opcional)'),
                _field(
                  _phone,
                  'Teléfono E.164 (opcional)',
                  hint: '+529611234567',
                  type: TextInputType.phone,
                ),
                _field(_invitationPassword, 'Contraseña', obscure: true),
                _ActionButton(
                  label: 'Aceptar invitación',
                  endpoint: 'POST /auth/invitations/accept',
                  busy: state.isBusy,
                  onPressed: () => actions.acceptInvitation(
                    email: _invitationTargetEmail.text,
                    code: _invitationToken.text,
                    password: _invitationPassword.text,
                    givenNames: _givenNames.text,
                    familyName: _familyName.text,
                    secondFamilyName: _optional(_secondFamilyName.text),
                    phoneE164: _optional(_phone.text),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    bool obscure = false,
    TextInputType? type,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        autocorrect: false,
        enableSuggestions: !obscure,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }

  String? _optional(String value) => value.trim().isEmpty ? null : value.trim();
}

class _EndpointCard extends StatelessWidget {
  const _EndpointCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        children: children,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.endpoint,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final String endpoint;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            endpoint,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 7),
          FilledButton(onPressed: busy ? null : onPressed, child: Text(label)),
        ],
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.message, required this.isError});
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isError
              ? Theme.of(context).colorScheme.errorContainer
              : Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isError
                ? Theme.of(context).colorScheme.onErrorContainer
                : Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}

class _InvitationPreview extends StatelessWidget {
  const _InvitationPreview({required this.invitation});
  final InvitationContext invitation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '${invitation.institutionName}\n${invitation.clubName}\n${invitation.emailHint}\nVence: ${invitation.expiresAt.toLocal()}',
      ),
    );
  }
}
