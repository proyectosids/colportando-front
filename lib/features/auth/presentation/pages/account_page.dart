import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_theme.dart';
import '../../domain/entities/current_account.dart';
import '../state/auth_controller.dart';
import '../state/auth_state.dart';
import '../widgets/brand_mark.dart';
import 'auth_actions_page.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({required this.account, required this.state, super.key});

  final CurrentAccount account;
  final AuthState state;

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
          'Se revocará esta sesión y tendrás que volver a escribir tus credenciales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const BrandMark(compact: true),
        actions: [
          IconButton(
            tooltip: 'Endpoints de autenticación',
            onPressed: state.isBusy
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const AuthActionsPage(authenticated: true),
                    ),
                  ),
            icon: const Icon(Icons.science_outlined),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: state.isBusy ? null : () => _confirmLogout(context, ref),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _WelcomeHeader(email: account.email),
                    if (state.message != null) ...[
                      const SizedBox(height: 16),
                      _StatusMessage(message: state.message!),
                    ],
                    const SizedBox(height: 24),
                    if (constraints.maxWidth >= 760)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _SessionCard(
                              account: account,
                              isBusy: state.isBusy,
                              onValidate: () => ref
                                  .read(authControllerProvider.notifier)
                                  .validateSession(),
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Expanded(child: _NextStepCard()),
                        ],
                      )
                    else ...[
                      _SessionCard(
                        account: account,
                        isBusy: state.isBusy,
                        onValidate: () => ref
                            .read(authControllerProvider.notifier)
                            .validateSession(),
                      ),
                      const SizedBox(height: 20),
                      const _NextStepCard(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BrandColors.sehsBlue, Color(0xFF256C73)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: BrandColors.kerussoLime,
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              'SESIÓN ACTIVA',
              style: TextStyle(
                color: BrandColors.ink,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Hola, colportor',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            style: const TextStyle(color: Color(0xFFE5F1F5), fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.account,
    required this.isBusy,
    required this.onValidate,
  });

  final CurrentAccount account;
  final bool isBusy;
  final VoidCallback onValidate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Identidad y sesión',
                    softWrap: true,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _AccountField(label: 'Estado', value: account.status),
            const SizedBox(height: 14),
            _AccountField(label: 'Cuenta', value: account.accountId),
            const SizedBox(height: 14),
            _AccountField(label: 'Sesión', value: account.sessionId),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: isBusy ? null : onValidate,
              icon: isBusy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync_rounded),
              label: const Text('Validar sesión con /auth/me'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountField extends StatelessWidget {
  const _AccountField({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        SelectableText(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _NextStepCard extends StatelessWidget {
  const _NextStepCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: BrandColors.warmGold.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: BrandColors.ink,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Base lista para crecer',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'El siguiente módulo puede consultar /workspace/context para construir la navegación por permisos y después mostrar campañas, catálogo y libros asignados.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            const _ChecklistItem(text: 'Access token sólo en memoria'),
            const _ChecklistItem(text: 'Refresh token cifrado'),
            const _ChecklistItem(text: 'Rotación y logout reales'),
          ],
        ),
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: BrandColors.sehsGreen,
          ),
          const SizedBox(width: 9),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
