import 'package:flutter/material.dart';
import '../../design_system/strot_tokens.dart';

class AdminOverviewScreen extends StatelessWidget {
  const AdminOverviewScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(StrotSpacing.lg),
    children: [
      const Text(
        'INTERNAL CONTROL PLANE',
        style: TextStyle(
          color: StrotColors.gold,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
      const SizedBox(height: StrotSpacing.md),
      Text(
        'Operations overview',
        style: Theme.of(context).textTheme.displayMedium,
      ),
      const SizedBox(height: StrotSpacing.xl),
      Wrap(
        spacing: StrotSpacing.md,
        runSpacing: StrotSpacing.md,
        children: const [
          _AdminMetric('Active projects', '24'),
          _AdminMetric('Organizations', '18'),
          _AdminMetric('Users', '73'),
          _AdminMetric('Approvals', '09'),
        ],
      ),
      const SizedBox(height: StrotSpacing.xl),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Commercial review',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(height: StrotSpacing.xl),
              const Text(
                'STR-24001 · Structural blockwork',
                style: TextStyle(
                  color: StrotColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: StrotSpacing.sm),
              const Text('BuildRight Ltd quotation'),
              const SizedBox(height: StrotSpacing.md),
              const Text('Partner base: ₦100,000'),
              const Text(
                'Client total: Not configured',
                style: TextStyle(color: StrotColors.gold),
              ),
              const SizedBox(height: StrotSpacing.md),
              const Text(
                'A privileged commercial rule must be approved before client pricing can be produced.',
                style: TextStyle(color: StrotColors.charcoalMuted),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: StrotSpacing.md),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent audit events',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(height: StrotSpacing.xl),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('quotation.submitted'),
                subtitle: Text('Quotation #1'),
                trailing: Text('09:42'),
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('approval.decided'),
                subtitle: Text('Scope of Work v2.1'),
                trailing: Text('09:18'),
              ),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('document.uploaded'),
                subtitle: Text('Column reinforcement'),
                trailing: Text('08:56'),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _AdminMetric extends StatelessWidget {
  const _AdminMetric(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 180,
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
