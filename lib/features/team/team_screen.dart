import 'package:flutter/material.dart';
import '../../core/team/team_models.dart';
import '../../core/team/team_service.dart';
import '../../design_system/strot_tokens.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key, required this.service});
  final TeamService service;

  @override
  Widget build(BuildContext context) => Material(
    color: StrotColors.cream,
    child: FutureBuilder<TeamRegister>(
      future: service.load(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.requireData;
        final pending = data.invitations
            .where((item) => item.status == 'pending')
            .length;
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            Text(
              'ORGANIZATION ACCESS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: StrotColors.gold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: StrotSpacing.sm),
            Text(
              'Team members and roles',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: StrotSpacing.sm),
            Text(
              'Review everyone attached to your organization and the capabilities controlled centrally for each role.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: StrotSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(
                  '$pending pending invitation${pending == 1 ? '' : 's'}',
                ),
              ),
            ),
            const SizedBox(height: StrotSpacing.xl),
            Text(
              'Active members',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: StrotSpacing.md),
            if (data.memberships.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(StrotSpacing.lg),
                  child: Text('No organization memberships are assigned.'),
                ),
              ),
            ...data.memberships.map(
              (item) => Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.person_outline,
                    color: StrotColors.gold,
                  ),
                  title: Text(item.name),
                  subtitle: Text('${item.email}\n${item.organization}'),
                  isThreeLine: true,
                  trailing: Chip(label: Text(item.role)),
                ),
              ),
            ),
            const SizedBox(height: StrotSpacing.xl),
            Text(
              'Role permissions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: StrotSpacing.sm),
            Text(
              'Permissions are governed by STROT. Contact support when a person needs a different role.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            ...data.roles.map((role) => _RoleCard(role: role)),
            const SizedBox(height: StrotSpacing.xl),
            Text(
              'Invitation history',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            ...data.invitations.map(
              (item) => Card(
                child: ListTile(
                  title: Text(item.email),
                  subtitle: Text(
                    '${item.organization} · ${item.role}\nExpires ${item.expiresAt.day}/${item.expiresAt.month}/${item.expiresAt.year}',
                  ),
                  isThreeLine: true,
                  trailing: Chip(label: Text(item.status)),
                ),
              ),
            ),
            const SizedBox(height: StrotSpacing.lg),
            Container(
              padding: const EdgeInsets.all(StrotSpacing.md),
              decoration: BoxDecoration(
                color: StrotColors.goldMuted,
                border: Border.all(color: StrotColors.goldMuted),
              ),
              child: const Text(
                'Invitation issuance and access removal remain protected web-administration actions. Passwords, invitation tokens and recovery credentials are never displayed.',
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role});
  final TeamRole role;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(role.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: StrotSpacing.md),
          ...role.permissions.map(
            (permission) => Padding(
              padding: const EdgeInsets.only(bottom: StrotSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 18, color: StrotColors.gold),
                  const SizedBox(width: StrotSpacing.sm),
                  Expanded(child: Text(permission.name)),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
