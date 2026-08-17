import 'package:flutter/material.dart';
import '../../design_system/strot_tokens.dart';

class ProviderOperationsScreen extends StatelessWidget {
  const ProviderOperationsScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(StrotSpacing.lg),
    children: [
      const Text(
        'PROVIDER OPERATIONS',
        style: TextStyle(
          color: StrotColors.gold,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
      const SizedBox(height: StrotSpacing.md),
      Text(
        'Fulfilment console',
        style: Theme.of(context).textTheme.displayMedium,
      ),
      const SizedBox(height: StrotSpacing.xl),
      Wrap(
        spacing: StrotSpacing.md,
        runSpacing: StrotSpacing.md,
        children: const [
          _ProviderMetric('Open requests', '01'),
          _ProviderMetric('Operational', '01'),
          _ProviderMetric('Response', '284 ms'),
        ],
      ),
      const SizedBox(height: StrotSpacing.xl),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'API-24001',
                style: TextStyle(
                  color: StrotColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: StrotSpacing.sm),
              Text(
                'Property verification',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: StrotSpacing.sm),
              const Text(
                'Verify title and coordinate match for Oak Residence.',
              ),
              const Divider(height: StrotSpacing.xl),
              const Text('Property reference: PROP-001 · Due 18 Aug 2026'),
              const SizedBox(height: StrotSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Unable to fulfil'),
                    ),
                  ),
                  const SizedBox(width: StrotSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Accept request'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: StrotSpacing.md),
      const Card(
        child: ListTile(
          contentPadding: EdgeInsets.all(StrotSpacing.md),
          title: Text('Property Verification'),
          subtitle: Text('production · Checked today'),
          trailing: Text(
            'operational · 284 ms',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ],
  );
}

class _ProviderMetric extends StatelessWidget {
  const _ProviderMetric(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 190,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: StrotSpacing.md),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    ),
  );
}
