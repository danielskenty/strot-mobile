import 'package:flutter/material.dart';
import '../../core/auth/auth_service.dart';
import '../../design_system/strot_tokens.dart';
import '../portal/portal_shell.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.authService});
  final AuthService authService;
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final email = TextEditingController(text: 'client@strot.test');
  final password = TextEditingController(text: 'strot-demo');
  bool submitting = false;
  String? error;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      submitting = true;
      error = null;
    });
    try {
      final session = await widget.authService.signIn(
        email: email.text.trim(),
        password: password.text,
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => PortalShell(session: session)),
      );
    } on AuthException catch (exception) {
      if (mounted) setState(() => error = exception.message);
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STROT', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: StrotSpacing.xxl),
                const Text(
                  'SECURE PROJECT ACCESS',
                  style: TextStyle(
                    color: StrotColors.gold,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: StrotSpacing.md),
                Text(
                  'Sign in to your workspace',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: StrotSpacing.sm),
                const Text(
                  'Access decisions, evidence, payments and project records assigned to your role.',
                ),
                const SizedBox(height: StrotSpacing.xl),
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(labelText: 'Email address'),
                ),
                const SizedBox(height: StrotSpacing.md),
                TextField(
                  controller: password,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => submit(),
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                if (error != null) ...[
                  const SizedBox(height: StrotSpacing.md),
                  Semantics(
                    liveRegion: true,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(StrotSpacing.md),
                      decoration: const BoxDecoration(
                        color: StrotColors.goldMuted,
                        border: Border(
                          left: BorderSide(color: StrotColors.gold, width: 2),
                        ),
                      ),
                      child: Text('◇ $error'),
                    ),
                  ),
                ],
                const SizedBox(height: StrotSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: submitting ? null : submit,
                    child: Text(
                      submitting ? 'Signing in…' : 'Sign in securely',
                    ),
                  ),
                ),
                const SizedBox(height: StrotSpacing.md),
                const Center(
                  child: Text(
                    'Demo: client@strot.test / strot-demo',
                    style: TextStyle(color: StrotColors.charcoalMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
