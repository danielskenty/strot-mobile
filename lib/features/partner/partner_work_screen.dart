import 'package:flutter/material.dart';
import '../../design_system/strot_tokens.dart';
import '../../core/partner/partner_quotation_service.dart';
import '../../core/partner/partner_assignment_service.dart';
import 'partner_quotations_screen.dart';
import 'partner_assignments_screen.dart';

class PartnerWorkScreen extends StatefulWidget {
  const PartnerWorkScreen({
    super.key,
    required this.quotationService,
    required this.assignmentService,
  });
  final PartnerQuotationService quotationService;
  final PartnerAssignmentService assignmentService;
  @override
  State<PartnerWorkScreen> createState() => _PartnerWorkScreenState();
}

class _PartnerWorkScreenState extends State<PartnerWorkScreen> {
  final amount = TextEditingController();
  bool submitted = false;
  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(StrotSpacing.lg),
    children: [
      if (submitted)
        Container(
          padding: const EdgeInsets.all(StrotSpacing.md),
          decoration: const BoxDecoration(
            color: StrotColors.goldMuted,
            border: Border(left: BorderSide(color: StrotColors.gold, width: 2)),
          ),
          child: const Text(
            '✓ Quotation submitted for confidential commercial review.',
          ),
        ),
      const SizedBox(height: StrotSpacing.md),
      const Text(
        'PARTNER OPERATIONS',
        style: TextStyle(
          color: StrotColors.gold,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
      const SizedBox(height: StrotSpacing.md),
      Text('Assigned work', style: Theme.of(context).textTheme.displayMedium),
      const SizedBox(height: StrotSpacing.md),
      OutlinedButton.icon(
        onPressed: () => Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PartnerQuotationsScreen(service: widget.quotationService),
          ),
        ),
        icon: const Icon(Icons.request_quote_outlined),
        label: const Text('Open quotation register'),
      ),
      OutlinedButton.icon(
        onPressed: () => Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PartnerAssignmentsScreen(service: widget.assignmentService),
          ),
        ),
        icon: const Icon(Icons.assignment_turned_in_outlined),
        label: const Text('Review assignments'),
      ),
      const SizedBox(height: StrotSpacing.xl),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'STR-24001',
                style: TextStyle(
                  color: StrotColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: StrotSpacing.sm),
              Text(
                'Structural blockwork',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: StrotSpacing.md),
              const Text(
                'Complete ground-floor blockwork to approved structural drawings and submit photographic evidence at each inspection point.',
              ),
              const Divider(height: StrotSpacing.xl),
              const Text('Oak Residence · Response due 28 Aug 2026'),
              const SizedBox(height: StrotSpacing.lg),
              TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Your quotation (NGN)',
                ),
              ),
              const SizedBox(height: StrotSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => submitted = true),
                  child: const Text('Submit quotation'),
                ),
              ),
              const SizedBox(height: StrotSpacing.sm),
              const Text(
                'Submit only your base delivery amount. STROT commercial pricing is handled separately.',
                style: TextStyle(color: StrotColors.charcoalMuted),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
