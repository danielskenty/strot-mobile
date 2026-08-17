import 'package:flutter/material.dart';
import '../../core/security/security_service.dart';
import '../../design_system/strot_tokens.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key, required this.service});
  final SecurityService service;
  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  late Future<List<SecuritySession>> future;
  final current = TextEditingController();
  final password = TextEditingController();
  final confirmation = TextEditingController();
  @override
  void initState() {
    super.initState();
    future = widget.service.sessions();
  }

  void refresh() {
    final next = widget.service.sessions();
    setState(() {
      future = next;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Password & sessions')),
    body: ListView(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      children: [
        Text(
          'Account security',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: StrotSpacing.sm),
        const Text(
          'Changing your password ends every other authenticated session.',
          style: TextStyle(color: StrotColors.charcoalMuted),
        ),
        const SizedBox(height: StrotSpacing.lg),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change password',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: StrotSpacing.md),
                TextField(
                  controller: current,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current password',
                  ),
                ),
                const SizedBox(height: StrotSpacing.md),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New password'),
                ),
                const SizedBox(height: StrotSpacing.md),
                TextField(
                  controller: confirmation,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm new password',
                  ),
                ),
                const SizedBox(height: StrotSpacing.md),
                FilledButton(
                  onPressed: _changePassword,
                  child: const Text('Change password'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: StrotSpacing.lg),
        Text(
          'Authenticated sessions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: StrotSpacing.md),
        FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('◇ ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: snapshot.data!
                  .map(
                    (session) => Card(
                      child: ListTile(
                        title: Text(session.name),
                        subtitle: Text(
                          'Started ${session.createdAt.day}/${session.createdAt.month}/${session.createdAt.year}',
                        ),
                        trailing: session.current
                            ? const Text(
                                'CURRENT',
                                style: TextStyle(
                                  color: StrotColors.gold,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : TextButton(
                                onPressed: () async {
                                  await widget.service.revoke(session.id);
                                  refresh();
                                },
                                child: const Text('Revoke'),
                              ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    ),
  );

  Future<void> _changePassword() async {
    if (password.text != confirmation.text || password.text.length < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Use matching passwords of at least 12 characters.'),
        ),
      );
      return;
    }
    await widget.service.changePassword(
      currentPassword: current.text,
      password: password.text,
    );
    current.clear();
    password.clear();
    confirmation.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed. Other sessions were revoked.'),
        ),
      );
      refresh();
    }
  }
}
