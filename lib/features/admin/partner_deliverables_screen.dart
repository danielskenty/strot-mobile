import 'package:flutter/material.dart';
import '../../core/partner/partner_commercial_service.dart';
import '../../design_system/strot_tokens.dart';

class PartnerDeliverablesScreen extends StatefulWidget {
  const PartnerDeliverablesScreen({super.key, required this.service});
  final PartnerCommercialService service;
  @override
  State<PartnerDeliverablesScreen> createState() =>
      _PartnerDeliverablesScreenState();
}

class _PartnerDeliverablesScreenState extends State<PartnerDeliverablesScreen> {
  late Future<PartnerCommercialRecord> record = widget.service.load();
  void reload() => setState(() => record = widget.service.load());
  @override
  Widget build(BuildContext context) => FutureBuilder<PartnerCommercialRecord>(
    future: record,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'VENDOR EVIDENCE ASSURANCE',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(
            'Partner deliverable review',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: StrotSpacing.sm),
          const Text(
            'Review submitted evidence against its partner and work-order context.',
          ),
          const SizedBox(height: StrotSpacing.xl),
          ...snapshot.requireData.deliverables.map(
            (item) => Card(
              child: Padding(
                padding: const EdgeInsets.all(StrotSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.partnerName == null
                          ? item.title
                          : '${item.partnerName} · ${item.title}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: StrotSpacing.xs),
                    Text(
                      '${item.reference} · ${item.workOrder}',
                      style: const TextStyle(color: StrotColors.charcoalMuted),
                    ),
                    const SizedBox(height: StrotSpacing.md),
                    Text(item.summary),
                    const Divider(height: StrotSpacing.xl),
                    Text(
                      '${item.evidenceCount} S3 evidence item(s) · ${item.status.replaceAll('_', ' ')}',
                    ),
                    if (item.reviewNote != null)
                      Padding(
                        padding: const EdgeInsets.only(top: StrotSpacing.sm),
                        child: Text('Review: ${item.reviewNote}'),
                      ),
                    if (item.status == 'submitted')
                      Padding(
                        padding: const EdgeInsets.only(top: StrotSpacing.md),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => review(item),
                            child: const Text('Record evidence review'),
                          ),
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

  Future<void> review(PartnerDeliverable item) async {
    var decision = 'approved';
    final note = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Evidence review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: decision,
                decoration: const InputDecoration(labelText: 'Decision'),
                items: const [
                  DropdownMenuItem(value: 'approved', child: Text('Approve')),
                  DropdownMenuItem(
                    value: 'changes_requested',
                    child: Text('Request correction'),
                  ),
                  DropdownMenuItem(value: 'rejected', child: Text('Reject')),
                ],
                onChanged: (value) => setDialogState(() => decision = value!),
              ),
              const SizedBox(height: StrotSpacing.md),
              TextField(
                controller: note,
                maxLines: 3,
                onChanged: (_) => setDialogState(() {}),
                decoration: const InputDecoration(labelText: 'Review note'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: decision != 'approved' && note.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(context, true),
              child: const Text('Record review'),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      await widget.service.reviewDeliverable(
        item.id,
        decision,
        note.text.trim().isEmpty ? null : note.text.trim(),
      );
      reload();
    }
    note.dispose();
  }
}
