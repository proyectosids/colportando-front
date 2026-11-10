import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/auth_controller.dart';
import '../state/auth_state.dart';
import '../widgets/brand_mark.dart';
import 'auth_actions_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({this.initialMessage, super.key});
  final String? initialMessage;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  Future<void> _requestReset() async {
    final email = _emailController.text.trim();
    if (!_looksLikeEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe primero un correo válido.')),
      );
      return;
    }
    final message = await ref
        .read(authControllerProvider.notifier)
        .requestPasswordReset(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  bool _looksLikeEmail(String value) {
    final at = value.indexOf('@');
    return at > 0 && value.indexOf('.', at) > at + 1;
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(authControllerProvider).value ??
        const AuthState(status: AuthStatus.unauthenticated);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF14211E)
                  : const Color(0xFFE9F4EF),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: wide ? 48 : 20,
                    vertical: 28,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: wide
                        ? Row(
                            children: [
                              const Expanded(child: _SalesStory()),
                              const SizedBox(width: 64),
                              SizedBox(width: 430, child: _buildCard(state)),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const BrandMark(),
                              const SizedBox(height: 30),
                              _buildCard(state),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(AuthState state) {
    return _LoginCard(
      formKey: _formKey,
      emailController: _emailController,
      passwordController: _passwordController,
      passwordFocus: _passwordFocus,
      obscurePassword: _obscurePassword,
      onTogglePassword: () =>
          setState(() => _obscurePassword = !_obscurePassword),
      onSubmit: _submit,
      onReset: _requestReset,
      onOpenExamples: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const AuthActionsPage(authenticated: false),
        ),
      ),
      isBusy: state.isBusy,
      message: state.message ?? widget.initialMessage,
    );
  }
}

class _SalesStory extends StatelessWidget {
  const _SalesStory();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BrandMark(),
        const SizedBox(height: 56),
        Text(
          'Lleva conocimiento,\nsalud y esperanza.',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.05,
            letterSpacing: -1.7,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Una base segura para acompañar al colportor desde su capacitación hasta la entrega de cada libro.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 34),
        const Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StoryPill(icon: Icons.auto_stories_rounded, label: 'Catálogo'),
            _StoryPill(icon: Icons.route_rounded, label: 'Campañas'),
            _StoryPill(
              icon: Icons.verified_user_rounded,
              label: 'Sesión segura',
            ),
          ],
        ),
      ],
    );
  }
}

class _StoryPill extends StatelessWidget {
  const _StoryPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.passwordFocus,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onReset,
    required this.onOpenExamples,
    required this.isBusy,
    required this.message,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode passwordFocus;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onReset;
  final VoidCallback onOpenExamples;
  final bool isBusy;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: AutofillGroup(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bienvenido de nuevo',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ingresa con tu cuenta de Colportando.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 20),
                  _MessageBanner(message: message!),
                ],
                const SizedBox(height: 26),
                TextFormField(
                  controller: emailController,
                  autofillHints: const [
                    AutofillHints.username,
                    AutofillHints.email,
                  ],
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enabled: !isBusy,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    hintText: 'nombre@ulv.edu.mx',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                  ),
                  onFieldSubmitted: (_) => passwordFocus.requestFocus(),
                  validator: (value) {
                    final input = value?.trim() ?? '';
                    final at = input.indexOf('@');
                    if (at <= 0 || input.indexOf('.', at) <= at + 1) {
                      return 'Escribe un correo válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  focusNode: passwordFocus,
                  autofillHints: const [AutofillHints.password],
                  obscureText: obscurePassword,
                  textInputAction: TextInputAction.done,
                  enableSuggestions: false,
                  autocorrect: false,
                  enabled: !isBusy,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      tooltip: obscurePassword
                          ? 'Mostrar contraseña'
                          : 'Ocultar contraseña',
                      onPressed: onTogglePassword,
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  onFieldSubmitted: (_) {
                    if (!isBusy) onSubmit();
                  },
                  validator: (value) => (value?.isEmpty ?? true)
                      ? 'Escribe tu contraseña.'
                      : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isBusy ? null : onReset,
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: isBusy ? null : onSubmit,
                  child: isBusy
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text('Iniciar sesión'),
                ),
                TextButton.icon(
                  onPressed: isBusy ? null : onOpenExamples,
                  icon: const Icon(Icons.science_outlined),
                  label: const Text('Explorar todos los endpoints'),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shield_outlined, size: 18),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        'Tus credenciales viajan cifradas por HTTPS.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
