import 'package:flutter/material.dart';

import '../../core/insurance/insurance_service.dart';
import '../../design_system/strot_tokens.dart';

class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({super.key, required this.service});
  final InsuranceService service;
  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> {
  late Future<List<InsurancePolicy>> policies = widget.service.list();
  void reload() => setState(() => policies = widget.service.list());

  @override
  Widget build(BuildContext context) => FutureBuilder<List<InsurancePolicy>>(
    future: policies,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(
          child: TextButton(
            onPressed: reload,
            child: const Text(
              'Insurance records could not be loaded. Try again',
            ),
          ),
        );
      }
      final values = snapshot.requireData;
      return RefreshIndicator(
        onRefresh: () async => reload(),
        child: ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            const Text(
              'PROPERTY PROTECTION RECORD',
              style: TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            Text('Insurance', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: StrotSpacing.sm),
            const Text(
              'Review insurer-issued policy details, renewal dates and claim coordination.',
            ),
            const SizedBox(height: StrotSpacing.xl),
            ...values.map(_policyCard),
            if (values.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(StrotSpacing.xl),
                  child: Text(
                    'No insurance policies are connected to your properties.',
                  ),
                ),
              ),
            const SizedBox(height: StrotSpacing.lg),
            const Text(
              'Policy cover and claim decisions remain subject to the licensed provider’s issued documents.',
              style: TextStyle(color: StrotColors.charcoalMuted),
            ),
          ],
        ),
      );
    },
  );

  Widget _policyCard(InsurancePolicy policy) => Card(
    child: ExpansionTile(
      title: Text(policy.propertyName),
      subtitle: Text(
        '${policy.provider} · ${policy.providerPolicyNumber ?? "Provider reference pending"}',
      ),
      childrenPadding: const EdgeInsets.all(StrotSpacing.lg),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            policy.coverageType,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: StrotSpacing.sm),
        Text(policy.coverageSummary),
        const Divider(height: StrotSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Status(policy.status),
            Text('Expires ${policy.expiresOn ?? "pending"}'),
          ],
        ),
        const SizedBox(height: StrotSpacing.lg),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Claims (${policy.claims.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ...policy.claims.map(
          (claim) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(claim.incidentType),
            subtitle: Text(
              '${claim.reference} · ${claim.providerClaimNumber ?? "Awaiting provider"}',
            ),
            trailing: _Status(claim.status),
          ),
        ),
      ],
    ),
  );
}

class _Status extends StatelessWidget {
  const _Status(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: StrotSpacing.sm,
      vertical: StrotSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: StrotColors.goldMuted,
      border: Border.all(color: StrotColors.gold),
    ),
    child: Text(
      label.replaceAll('_', ' '),
      style: const TextStyle(
        color: StrotColors.forest,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
