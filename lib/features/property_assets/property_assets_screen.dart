import 'package:flutter/material.dart';
import '../../core/property_assets/property_asset_service.dart';
import '../../design_system/strot_tokens.dart';

class PropertyAssetsScreen extends StatelessWidget {
  const PropertyAssetsScreen({super.key, required this.service});
  final PropertyAssetService service;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Asset register')),
    body: FutureBuilder<List<PropertyAsset>>(
      future: service.list(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            const Text(
              'PROPERTY INTELLIGENCE',
              style: TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            Text(
              'Installed assets',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const Text('Equipment identity, condition and warranty readiness.'),
            const SizedBox(height: StrotSpacing.xl),
            ...snapshot.data!.map(
              (asset) => Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(StrotSpacing.md),
                  title: Text(asset.name),
                  subtitle: Text(
                    '${asset.property} · ${asset.category}\n${asset.status.replaceAll('_', ' ')}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => PropertyAssetDetailScreen(asset: asset),
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

class PropertyAssetDetailScreen extends StatelessWidget {
  const PropertyAssetDetailScreen({super.key, required this.asset});
  final PropertyAsset asset;
  String value(String? input) =>
      input?.isNotEmpty == true ? input! : 'Not recorded';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Asset record')),
    body: ListView(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      children: [
        Text(
          asset.category.toUpperCase(),
          style: const TextStyle(
            color: StrotColors.gold,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: StrotSpacing.sm),
        Text(asset.name, style: Theme.of(context).textTheme.displayMedium),
        Text('${asset.property} · ${asset.status.replaceAll('_', ' ')}'),
        const SizedBox(height: StrotSpacing.xl),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Manufacturer', value(asset.manufacturer)),
                _row('Model', value(asset.model)),
                _row('Serial number', value(asset.serialNumber)),
                _row('Installed', value(asset.installedOn)),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Warranty', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: StrotSpacing.sm),
                Text(asset.warrantyState.replaceAll('_', ' ')),
                Text(value(asset.warrantyExpiresOn)),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maintenance requirements',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(),
                if (asset.maintenanceRequirements.isEmpty)
                  const Text('No requirements recorded.')
                else
                  ...asset.maintenanceRequirements.entries.map(
                    (entry) => _row(
                      entry.key.replaceAll('_', ' '),
                      entry.value.toString(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
  Widget _row(String label, String detail) => Padding(
    padding: const EdgeInsets.symmetric(vertical: StrotSpacing.sm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        Expanded(
          child: Text(
            detail,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
