import 'package:flutter/material.dart';

import '../../core/partner/partner_commercial_service.dart';
import '../../design_system/strot_tokens.dart';

class PartnerCommercialScreen extends StatefulWidget {
  const PartnerCommercialScreen({super.key, required this.service});

  final PartnerCommercialService service;

  @override
  State<PartnerCommercialScreen> createState() =>
      _PartnerCommercialScreenState();
}

class _PartnerCommercialScreenState extends State<PartnerCommercialScreen> {
  late Future<PartnerCommercialRecord> record = widget.service.load();

  String money(int minor, String currency) =>
      '$currency ${(minor / 100).toStringAsFixed(2)}';

  void reload() => setState(() => record = widget.service.load());

  @override
  Widget build(BuildContext context) => FutureBuilder<PartnerCommercialRecord>(
    future: record,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 42),
                const SizedBox(height: StrotSpacing.md),
                const Text('Commercial records could not be loaded.'),
                TextButton(onPressed: reload, child: const Text('Try again')),
              ],
            ),
          ),
        );
      }
      final value = snapshot.requireData;
      return RefreshIndicator(
        onRefresh: () async => reload(),
        child: ListView(
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
              'Deliverables & payouts',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: StrotSpacing.sm),
            const Text(
              'Track submitted evidence, invoice reviews and recorded payout references.',
            ),
            const SizedBox(height: StrotSpacing.xl),
            Text('Invoices', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: StrotSpacing.md),
            ...value.invoices.map(_invoiceCard),
            const SizedBox(height: StrotSpacing.xl),
            Text(
              'Deliverables',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: StrotSpacing.md),
            ...value.deliverables.map(_deliverableCard),
            if (value.invoices.isEmpty && value.deliverables.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(StrotSpacing.xl),
                  child: Text(
                    'No commercial records have been submitted. Use the responsive web portal to create a deliverable or invoice.',
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );

  Widget _invoiceCard(PartnerInvoice invoice) => Card(
    child: Padding(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            invoice.invoiceNumber,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: StrotSpacing.xs),
          Text(
            '${invoice.reference} · ${invoice.workOrder}',
            style: const TextStyle(color: StrotColors.charcoalMuted),
          ),
          const Divider(height: StrotSpacing.xl),
          Text(
            money(invoice.amountMinor, invoice.currency),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: StrotSpacing.sm),
          Wrap(
            spacing: StrotSpacing.sm,
            children: [
              _Status(invoice.status),
              if (invoice.payout != null)
                _Status('Payout ${invoice.payout!.status}'),
            ],
          ),
          if (invoice.payout != null)
            Padding(
              padding: const EdgeInsets.only(top: StrotSpacing.md),
              child: Text(
                invoice.payout!.paymentReference ??
                    (invoice.payout!.scheduledFor == null
                        ? invoice.payout!.reference
                        : 'Scheduled ${invoice.payout!.scheduledFor}'),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _deliverableCard(PartnerDeliverable item) => Card(
    child: Padding(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              _Status(item.status),
            ],
          ),
          const SizedBox(height: StrotSpacing.sm),
          Text(
            '${item.reference} · ${item.workOrder}',
            style: const TextStyle(color: StrotColors.charcoalMuted),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(item.summary),
          const Divider(height: StrotSpacing.xl),
          Text('${item.evidenceCount} verified evidence item(s)'),
        ],
      ),
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
