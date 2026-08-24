import 'package:flutter/material.dart';
import '../../core/partner/partner_quotation_service.dart';
import '../../design_system/strot_tokens.dart';

class PartnerQuotationsScreen extends StatefulWidget {
  const PartnerQuotationsScreen({
    super.key,
    required this.service,
    this.initialId,
  });
  final PartnerQuotationService service;
  final int? initialId;

  @override
  State<PartnerQuotationsScreen> createState() =>
      _PartnerQuotationsScreenState();
}

class _PartnerQuotationsScreenState extends State<PartnerQuotationsScreen> {
  bool openedInitial = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Quotation register')),
    body: FutureBuilder<List<PartnerQuotationRecord>>(
      future: widget.service.list(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final records = snapshot.data!;
        if (!openedInitial && widget.initialId != null) {
          openedInitial = true;
          final matches = records.where((item) => item.id == widget.initialId);
          if (matches.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _QuotationDetail(record: matches.first),
                  ),
                );
              }
            });
          }
        }
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            const Text(
              'PARTNER COMMERCIAL RECORD',
              style: TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            Text(
              'Quotations',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: StrotSpacing.xl),
            if (records.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(StrotSpacing.lg),
                  child: Text('No quotations have been submitted.'),
                ),
              ),
            ...records.map(
              (record) => Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(StrotSpacing.md),
                  title: Text(record.workTitle),
                  subtitle: Text(
                    '${record.projectReference} · ${_money(record.amountMinor)}\n${record.status.replaceAll('_', ' ')}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _QuotationDetail(record: record),
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

class _QuotationDetail extends StatelessWidget {
  const _QuotationDetail({required this.record});
  final PartnerQuotationRecord record;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Quotation #${record.id}')),
    body: ListView(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      children: [
        Text(
          record.projectReference,
          style: const TextStyle(
            color: StrotColors.gold,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          record.workTitle,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: StrotSpacing.lg),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Submitted base amount'),
                const SizedBox(height: StrotSpacing.sm),
                Text(
                  _money(record.amountMinor),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Divider(height: StrotSpacing.xl),
                Text(record.workDescription),
                if (record.reviewNote != null) ...[
                  const Divider(height: StrotSpacing.xl),
                  Text('STROT review: ${record.reviewNote}'),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: StrotSpacing.md),
        const Text(
          'Client pricing and internal STROT margins are not included in the partner record.',
          style: TextStyle(color: StrotColors.charcoalMuted),
        ),
      ],
    ),
  );
}

String _money(int minor) => '₦${(minor / 100).toStringAsFixed(2)}';
