import 'package:flutter/material.dart';
import '../../core/admin/role_service.dart';
import '../../design_system/strot_tokens.dart';

class RolesScreen extends StatelessWidget {
  const RolesScreen({super.key, required this.service});
  final AdminRoleService service;
  @override
  Widget build(BuildContext context) => FutureBuilder<List<AdminRole>>(
    future: service.list(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'ACCESS ARCHITECTURE',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(
            'Roles & permissions',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const Text('Canonical capabilities for every STROT workspace.'),
          const SizedBox(height: StrotSpacing.xl),
          ...snapshot.data!.map((role) {
            final count = role.permissions.values.fold<int>(
              0,
              (total, items) => total + items.length,
            );
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(StrotSpacing.md),
                title: Text(role.name),
                subtitle: Text(
                  '${role.assignments} assignments · $count capabilities',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        RoleDetailScreen(service: service, id: role.id),
                  ),
                ),
              ),
            );
          }),
        ],
      );
    },
  );
}

class RoleDetailScreen extends StatelessWidget {
  const RoleDetailScreen({super.key, required this.service, required this.id});
  final AdminRoleService service;
  final int id;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Role record')),
    body: FutureBuilder<AdminRole>(
      future: service.get(id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final role = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            Text(
              role.key.toUpperCase(),
              style: const TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(role.name, style: Theme.of(context).textTheme.displayMedium),
            Text('${role.assignments} active assignments'),
            const SizedBox(height: StrotSpacing.xl),
            ...role.permissions.entries.map(
              (group) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(StrotSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.key,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
                      ...group.value.map(
                        (permission) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.diamond_outlined),
                          title: Text(permission['name'].toString()),
                          subtitle: Text(permission['key'].toString()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
