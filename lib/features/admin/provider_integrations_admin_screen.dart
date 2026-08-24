import 'package:flutter/material.dart';
import '../../core/admin/provider_integration_admin_service.dart';
import '../../design_system/strot_tokens.dart';

class ProviderIntegrationsAdminScreen extends StatefulWidget {
  const ProviderIntegrationsAdminScreen({super.key, required this.service});
  final ProviderIntegrationAdminService service;
  @override
  State<ProviderIntegrationsAdminScreen> createState() =>
      _ProviderIntegrationsAdminScreenState();
}

class _ProviderIntegrationsAdminScreenState
    extends State<ProviderIntegrationsAdminScreen> {
  late Future<List<Map<String, dynamic>>> items = widget.service.load();
  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<List<Map<String, dynamic>>>(
    future: items,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'PROVIDER INTEGRATION GOVERNANCE',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(
            'Integration registry',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: StrotSpacing.sm),
          const Text(
            'Inspect non-secret service metadata and operational states.',
          ),
          const SizedBox(height: StrotSpacing.xl),
          ...snapshot.requireData.map(
            (item) => Card(
              child: Padding(
                padding: const EdgeInsets.all(StrotSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] as String,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: StrotSpacing.xs),
                    Text(
                      '${(item['provider_organization'] as Map<String, dynamic>)['name']} · ${item['environment']}',
                      style: const TextStyle(color: StrotColors.charcoalMuted),
                    ),
                    const SizedBox(height: StrotSpacing.md),
                    Text((item['capabilities'] as List).join(' · ')),
                    const Divider(height: StrotSpacing.xl),
                    Text(
                      '${item['status']} · ${item['credentials_configured'] == true ? 'credentials configured' : 'credentials pending'}',
                      style: const TextStyle(
                        color: StrotColors.gold,
                        fontWeight: FontWeight.w700,
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
  );
}
