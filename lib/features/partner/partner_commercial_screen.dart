import 'package:flutter/material.dart';

import '../../core/partner/partner_commercial_service.dart';
import '../../design_system/strot_tokens.dart';

class PartnerCommercialScreen extends StatefulWidget {
  const PartnerCommercialScreen({
    super.key,
    required this.service,
    this.financeMode = false,
    this.initialDeliverableId,
  });

  final PartnerCommercialService service;
  final bool financeMode;
  final int? initialDeliverableId;

  @override
  State<PartnerCommercialScreen> createState() =>
      _PartnerCommercialScreenState();
}

class _PartnerCommercialScreenState extends State<PartnerCommercialScreen> {
  late Future<PartnerCommercialRecord> record = widget.service.load();
  bool openedInitial = false;

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
      if (!openedInitial && widget.initialDeliverableId != null) {
        openedInitial = true;
        final matches = value.deliverables.where(
          (item) => item.id == widget.initialDeliverableId,
        );
        if (matches.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!mounted) return;
            await Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => _DeliverableDetail(
                  item: matches.first,
                  service: widget.service,
                ),
              ),
            );
            reload();
          });
        }
      }
      return RefreshIndicator(
        onRefresh: () async => reload(),
        child: ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            Text(
              widget.financeMode
                  ? 'PARTNER COMMERCIAL CONTROL'
                  : 'PARTNER COMMERCIAL RECORD',
              style: const TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            Text(
              widget.financeMode
                  ? 'Partner invoices and payouts'
                  : 'Deliverables & payouts',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: StrotSpacing.sm),
            Text(
              widget.financeMode
                  ? 'Review claims, schedule payouts and record reconciled bank references.'
                  : 'Track submitted evidence, invoice reviews and recorded payout references.',
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
            widget.financeMode && invoice.partnerName != null
                ? '${invoice.partnerName} · ${invoice.invoiceNumber}'
                : invoice.invoiceNumber,
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
          if (widget.financeMode &&
              ['submitted', 'approved', 'scheduled'].contains(invoice.status))
            Padding(
              padding: const EdgeInsets.only(top: StrotSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _review(invoice),
                  child: const Text('Record finance action'),
                ),
              ),
            ),
        ],
      ),
    ),
  );

  Future<void> _review(PartnerInvoice invoice) async {
    final actions = invoice.status == 'submitted'
        ? ['approved', 'rejected']
        : invoice.status == 'approved'
        ? ['scheduled']
        : ['paid'];
    var action = actions.first;
    final detail = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Partner finance action'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: action,
                decoration: const InputDecoration(labelText: 'Next state'),
                items: actions
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => setDialogState(() => action = value!),
              ),
              if (invoice.status != 'submitted') ...[
                const SizedBox(height: StrotSpacing.md),
                TextField(
                  controller: detail,
                  decoration: InputDecoration(
                    labelText: action == 'scheduled'
                        ? 'Schedule date (YYYY-MM-DD)'
                        : 'Bank payment reference',
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed:
                  invoice.status != 'submitted' && detail.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(context, true),
              child: const Text('Record action'),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      await widget.service.reviewInvoice(
        invoice.id,
        action,
        scheduledFor: action == 'scheduled' ? detail.text.trim() : null,
        paymentReference: action == 'paid' ? detail.text.trim() : null,
      );
      reload();
    }
    detail.dispose();
  }

  Widget _deliverableCard(PartnerDeliverable item) => Card(
    child: InkWell(
      onTap: () async {
        await Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) =>
                _DeliverableDetail(item: item, service: widget.service),
          ),
        );
        reload();
      },
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
    ),
  );
}

class _DeliverableDetail extends StatefulWidget {
  const _DeliverableDetail({required this.item, required this.service});
  final PartnerDeliverable item;
  final PartnerCommercialService service;
  @override
  State<_DeliverableDetail> createState() => _DeliverableDetailState();
}

class _DeliverableDetailState extends State<_DeliverableDetail> {
  late final summary = TextEditingController(text: widget.item.summary),
      evidence = TextEditingController(
        text: widget.item.mediaAssetIds.join('\n'),
      );
  bool saving = false;
  @override
  void dispose() {
    summary.dispose();
    evidence.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.item.reference)),
    body: ListView(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      children: [
        Text(
          widget.item.title,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: StrotSpacing.sm),
        _Status(widget.item.status),
        const SizedBox(height: StrotSpacing.lg),
        Text(widget.item.summary),
        if (widget.item.reviewNote != null) ...[
          const Divider(height: StrotSpacing.xl),
          Text('STROT review: ${widget.item.reviewNote}'),
        ],
        const Divider(height: StrotSpacing.xl),
        Text('${widget.item.evidenceCount} evidence item(s)'),
        if (widget.item.status == 'correction_requested') ...[
          const SizedBox(height: StrotSpacing.xl),
          Text(
            'Submit correction',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          TextField(
            controller: summary,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Revised summary'),
          ),
          TextField(
            controller: evidence,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Processed S3 media asset IDs · one per line',
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          ElevatedButton(
            onPressed: saving
                ? null
                : () async {
                    setState(() => saving = true);
                    await widget.service.reviseDeliverable(
                      widget.item.id,
                      summary.text.trim(),
                      evidence.text
                          .split('\n')
                          .map((value) => value.trim())
                          .where((value) => value.isNotEmpty)
                          .toList(),
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
            child: Text(
              saving ? 'Submitting…' : 'Submit corrected deliverable',
            ),
          ),
        ],
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
