import 'package:flutter/material.dart';
import '../../core/admin/admin_service.dart';
import '../../design_system/strot_tokens.dart';
import 'commercial_dashboard_screen.dart';

class AdminOverviewScreen extends StatefulWidget {
  const AdminOverviewScreen({super.key, required this.service});
  final AdminService service;
  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  late Future<AdminOverviewData> overview = widget.service.overview();
  void refresh() => setState(() => overview = widget.service.overview());
  @override
  Widget build(BuildContext context) => FutureBuilder<AdminOverviewData>(
    future: overview,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final data = snapshot.data!;
      return ListView(
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
            children: data.metrics.entries
                .take(4)
                .map(
                  (item) => _AdminMetric(
                    item.key.replaceAll('_', ' '),
                    '${item.value}',
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: StrotSpacing.xl),
          OutlinedButton.icon(
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    CommercialDashboardScreen(service: widget.service),
              ),
            ),
            icon: const Icon(Icons.analytics_outlined),
            label: const Text('Pricing & margin reporting'),
          ),
          const SizedBox(height: StrotSpacing.xl),
          Text(
            'Commercial review',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          ...data.quotations.map(
            (quote) => Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(StrotSpacing.md),
                title: Text(quote.title),
                subtitle: Text(
                  '${quote.reference} · Partner base ${_money(quote.partnerBaseMinor)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommercialReviewScreen(
                        quotation: quote,
                        service: widget.service,
                      ),
                    ),
                  );
                  refresh();
                },
              ),
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(StrotSpacing.lg),
              child: Text(
                'Partner base pricing and commercial margins are restricted to privileged STROT administrators.',
              ),
            ),
          ),
        ],
      );
    },
  );
}

class CommercialReviewScreen extends StatefulWidget {
  const CommercialReviewScreen({
    super.key,
    required this.quotation,
    required this.service,
  });
  final AdminQuotation quotation;
  final AdminService service;
  @override
  State<CommercialReviewScreen> createState() => _CommercialReviewScreenState();
}

class _CommercialReviewScreenState extends State<CommercialReviewScreen> {
  final total = TextEditingController();
  final note = TextEditingController();
  bool saving = false;
  Future<void> decide(String decision) async {
    setState(() => saving = true);
    try {
      final naira = int.tryParse(total.text.replaceAll(RegExp(r'[^0-9]'), ''));
      await widget.service.review(
        widget.quotation.id,
        decision,
        clientTotalMinor: naira == null ? null : naira * 100,
        note: note.text.trim().isEmpty ? null : note.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    total.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Commercial review')),
    body: ListView(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      children: [
        Text(
          widget.quotation.reference,
          style: const TextStyle(
            color: StrotColors.gold,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          widget.quotation.title,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: StrotSpacing.xl),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Partner base'),
                Text(
                  _money(widget.quotation.partnerBaseMinor),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ),
        TextField(
          controller: total,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Client total (NGN)'),
        ),
        const SizedBox(height: StrotSpacing.md),
        TextField(
          controller: note,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Review note'),
        ),
        const SizedBox(height: StrotSpacing.lg),
        FilledButton(
          onPressed: saving ? null : () => decide('approve'),
          child: const Text('Approve client total'),
        ),
        OutlinedButton(
          onPressed: saving ? null : () => decide('request_revision'),
          child: const Text('Request revision'),
        ),
        OutlinedButton(
          onPressed: saving ? null : () => decide('reject'),
          child: const Text('Reject quotation'),
        ),
      ],
    ),
  );
}

String _money(int minor) => '₦${(minor / 100).toStringAsFixed(2)}';

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
