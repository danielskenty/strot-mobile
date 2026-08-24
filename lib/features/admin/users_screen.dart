import 'package:flutter/material.dart';
import '../../core/admin/user_directory_service.dart';
import '../../design_system/strot_tokens.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key, required this.service});
  final AdminUserDirectoryService service;
  @override
  Widget build(BuildContext context) => FutureBuilder<List<AdminUserRecord>>(
    future: service.list(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'IDENTITY GOVERNANCE',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text('Users', style: Theme.of(context).textTheme.displayMedium),
          const Text('Platform identities and security posture.'),
          const SizedBox(height: StrotSpacing.xl),
          ...snapshot.data!.map(
            (user) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(StrotSpacing.md),
                title: Text(user.name),
                subtitle: Text(
                  '${user.email}\n${user.twoFactor ? 'Two-factor enabled' : 'Two-factor not enabled'}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        UserDetailScreen(service: service, id: user.id),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.service, required this.id});
  final AdminUserDirectoryService service;
  final int id;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Identity record')),
    body: FutureBuilder<AdminUserRecord>(
      future: service.get(id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            const Text(
              'IDENTITY RECORD',
              style: TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(user.name, style: Theme.of(context).textTheme.displayMedium),
            Text(user.email),
            const SizedBox(height: StrotSpacing.xl),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Email verification'),
                    trailing: Text(user.verified ? 'Verified' : 'Unverified'),
                  ),
                  ListTile(
                    title: const Text('Two-factor'),
                    trailing: Text(user.twoFactor ? 'Enabled' : 'Not enabled'),
                  ),
                  ListTile(
                    title: const Text('Active sessions'),
                    trailing: Text('${user.sessions}'),
                  ),
                ],
              ),
            ),
            _section(
              context,
              'Organizations',
              user.organizations,
              'name',
              'type',
            ),
            _section(context, 'Roles', user.roles, 'name', 'key'),
            _section(
              context,
              'Recent activity',
              user.activity,
              'event',
              'occurred_at',
            ),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(StrotSpacing.lg),
                child: Text(
                  'Passwords, tokens, recovery codes and authentication secrets are excluded.',
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  Widget _section(
    BuildContext context,
    String title,
    List<Map<String, dynamic>> rows,
    String primary,
    String secondary,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          if (rows.isEmpty)
            const Text('No records.')
          else
            ...rows.map(
              (row) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  row[primary]?.toString().replaceAll('_', ' ') ?? '',
                ),
                trailing: Text(
                  row[secondary]?.toString().replaceAll('_', ' ') ?? '',
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
