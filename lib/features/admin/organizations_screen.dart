import 'package:flutter/material.dart';
import '../../core/admin/organization_service.dart';
import '../../design_system/strot_tokens.dart';

class OrganizationsScreen extends StatelessWidget {
  const OrganizationsScreen({super.key, required this.service});
  final AdminOrganizationService service;
  @override
  Widget build(BuildContext context) => FutureBuilder<List<AdminOrganization>>(
    future: service.list(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'PLATFORM RELATIONSHIPS',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(
            'Organizations',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const Text('Clients, partners, providers and internal teams.'),
          const SizedBox(height: StrotSpacing.xl),
          ...snapshot.data!.map(
            (item) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(StrotSpacing.md),
                title: Text(item.name),
                subtitle: Text(
                  '${item.type.replaceAll('_', ' ')} · ${item.status}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        OrganizationDetailScreen(service: service, id: item.id),
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

class OrganizationDetailScreen extends StatelessWidget {
  const OrganizationDetailScreen({
    super.key,
    required this.service,
    required this.id,
  });
  final AdminOrganizationService service;
  final int id;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Organization record')),
    body: FutureBuilder<AdminOrganization>(
      future: service.get(id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final item = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            Text(
              item.type.toUpperCase(),
              style: const TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(item.name, style: Theme.of(context).textTheme.displayMedium),
            Text(item.status),
            const SizedBox(height: StrotSpacing.xl),
            _section(context, 'Members', item.members, 'name', 'role'),
            _section(context, 'Projects', item.projects, 'name', 'reference'),
            _section(
              context,
              'Properties',
              item.properties,
              'name',
              'reference',
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
                title: Text(row[primary]?.toString() ?? ''),
                trailing: Text(
                  (row[secondary]?.toString() ?? '').replaceAll('_', ' '),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
