import 'package:flutter/material.dart';
import '../../core/properties/property_service.dart';
import '../../design_system/strot_tokens.dart';

class PropertiesScreen extends StatelessWidget {
  const PropertiesScreen({super.key, required this.service});
  final PropertyService service;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Properties')),
    body: FutureBuilder<List<PropertyRecord>>(
      future: service.list(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            const Text(
              'BUILT ENVIRONMENT PORTFOLIO',
              style: TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            Text(
              'Your properties',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const Text(
              'Accountable records for your completed and managed properties.',
            ),
            const SizedBox(height: StrotSpacing.xl),
            ...snapshot.data!.map(
              (item) => Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(StrotSpacing.md),
                  title: Text(item.name),
                  subtitle: Text(
                    '${item.reference}\n${item.address} · ${item.location}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          PropertyDetailScreen(service: service, id: item.id),
                    ),
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

class PropertyDetailScreen extends StatelessWidget {
  const PropertyDetailScreen({
    super.key,
    required this.service,
    required this.id,
  });
  final PropertyService service;
  final int id;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Property record')),
    body: FutureBuilder<PropertyRecord>(
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
              item.reference,
              style: const TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(item.name, style: Theme.of(context).textTheme.displayMedium),
            Text('${item.address} · ${item.location}'),
            const SizedBox(height: StrotSpacing.xl),
            _section(
              context,
              'Installed assets',
              item.assets,
              'name',
              'status',
            ),
            _section(
              context,
              'Care schedule',
              item.plans,
              'name',
              'next_service_on',
            ),
            _section(
              context,
              'Maintenance history',
              item.requests,
              'title',
              'status',
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
            const Text('No records yet.')
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
