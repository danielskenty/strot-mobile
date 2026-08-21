import 'package:flutter/material.dart';
import '../../core/admin/admin_service.dart';
import '../../design_system/strot_tokens.dart';

class CommercialDashboardScreen extends StatefulWidget {
  const CommercialDashboardScreen({super.key, required this.service});
  final AdminService service;
  @override
  State<CommercialDashboardScreen> createState() =>
      _CommercialDashboardScreenState();
}

class _CommercialDashboardScreenState extends State<CommercialDashboardScreen> {
  late Future<CommercialDashboardData> future = widget.service
      .commercialDashboard();
  final name = TextEditingController(),
      markup = TextEditingController(),
      minimum = TextEditingController();
  Future<void> save() async {
    final percent = double.tryParse(markup.text),
        naira = double.tryParse(minimum.text);
    if (percent == null || naira == null || name.text.trim().isEmpty) return;
    await widget.service.createPolicy({
      'name': name.text.trim(),
      'scope': 'quotation',
      'markup_basis_points': (percent * 100).round(),
      'minimum_margin_minor': (naira * 100).round(),
      'currency': 'NGN',
      'active': true,
    });
    if (mounted) setState(() => future = widget.service.commercialDashboard());
  }

  @override
  void dispose() {
    name.dispose();
    markup.dispose();
    minimum.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Commercial reporting')),
    body: FutureBuilder<CommercialDashboardData>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!, summary = data.summary;
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            const Text(
              'CONFIDENTIAL COMMERCIAL CONTROL',
              style: TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            Text(
              'Pricing & margin reporting',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: StrotSpacing.lg),
            Wrap(
              spacing: StrotSpacing.md,
              runSpacing: StrotSpacing.md,
              children: [
                _Metric(
                  'Client revenue',
                  _money(summary['client_revenue_minor'] as int),
                ),
                _Metric(
                  'Partner base',
                  _money(summary['partner_base_minor'] as int),
                ),
                _Metric(
                  'Gross margin',
                  _money(summary['gross_margin_minor'] as int),
                ),
                _Metric(
                  'Margin rate',
                  '${((summary['gross_margin_basis_points'] as int) / 100).toStringAsFixed(2)}%',
                ),
              ],
            ),
            const SizedBox(height: StrotSpacing.xl),
            Text(
              'Pricing policies',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ...data.policies.map(
              (p) => Card(
                child: ListTile(
                  title: Text(p['name'] as String),
                  subtitle: Text(
                    '${p['scope']} · ${((p['markup_basis_points'] as int) / 100).toStringAsFixed(2)}%',
                  ),
                  trailing: p['active'] as bool
                      ? const Icon(Icons.check_circle_outline)
                      : TextButton(
                          onPressed: () async {
                            await widget.service.activatePolicy(p['id'] as int);
                            if (mounted) {
                              setState(
                                () => future = widget.service
                                    .commercialDashboard(),
                              );
                            }
                          },
                          child: const Text('Activate'),
                        ),
                ),
              ),
            ),
            const SizedBox(height: StrotSpacing.lg),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Policy name'),
            ),
            TextField(
              controller: markup,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Markup %'),
            ),
            TextField(
              controller: minimum,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minimum margin (NGN)',
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            FilledButton(
              onPressed: save,
              child: const Text('Create and activate policy'),
            ),
            const SizedBox(height: StrotSpacing.md),
            const Text(
              'Policies are internal guidance and never alter a quotation without an explicit administrator approval.',
            ),
          ],
        );
      },
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);
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
            const SizedBox(height: StrotSpacing.sm),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    ),
  );
}

String _money(int minor) => '₦${(minor / 100).toStringAsFixed(2)}';
