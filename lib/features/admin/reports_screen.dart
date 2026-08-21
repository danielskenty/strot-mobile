import 'package:flutter/material.dart';
import '../../core/admin/admin_service.dart';
import '../../design_system/strot_tokens.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key, required this.service});
  final AdminService service;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reports')),
    body: FutureBuilder<AdminReportData>(
      future: service.report(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!, m = data.metrics;
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            const Text(
              'REPORTS & ANALYTICS',
              style: TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            Text(
              'Operational intelligence',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Text('${data.range['from']} — ${data.range['to']}'),
            const SizedBox(height: StrotSpacing.xl),
            Wrap(
              spacing: StrotSpacing.md,
              runSpacing: StrotSpacing.md,
              children: [
                _Metric('Projects created', '${m['projects_created']}'),
                _Metric('Active projects', '${m['active_projects']}'),
                _Metric('Invoices issued', '${m['invoices_issued']}'),
                _Metric('Pending approvals', '${m['pending_approvals']}'),
                _Metric(
                  'Invoice value',
                  _money(m['invoice_total_minor'] as int),
                ),
                _Metric('Payments', _money(m['invoice_paid_minor'] as int)),
                _Metric('Provider requests', '${m['provider_requests']}'),
                _Metric(
                  'Notification failures',
                  '${m['notification_failures']}',
                ),
              ],
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
