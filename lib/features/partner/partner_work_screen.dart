import 'package:flutter/material.dart';
import '../../core/partner/partner_assignment_service.dart';
import '../../core/partner/partner_quotation_service.dart';
import '../../design_system/strot_tokens.dart';
import 'partner_assignments_screen.dart';
import 'partner_quotations_screen.dart';

class PartnerWorkScreen extends StatelessWidget {
  const PartnerWorkScreen({
    super.key,
    required this.quotationService,
    required this.assignmentService,
  });
  final PartnerQuotationService quotationService;
  final PartnerAssignmentService assignmentService;
  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<(List<PartnerAssignment>, List<PartnerQuotationRecord>)>(
    future: Future.wait([assignmentService.list(), quotationService.list()])
        .then(
          (values) => (
            values[0] as List<PartnerAssignment>,
            values[1] as List<PartnerQuotationRecord>,
          ),
        ),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final assignments = snapshot.requireData.$1,
          quotations = snapshot.requireData.$2,
          pending = assignments
              .where((item) => item.status == 'assignment_pending')
              .length,
          corrections = quotations
              .where((item) => item.status == 'changes_requested')
              .length;
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'PARTNER OPERATIONS',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(
            'Assigned work',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: StrotSpacing.sm),
          const Text(
            'Live work-order briefs and confidential quotation records for your organization.',
          ),
          const SizedBox(height: StrotSpacing.xl),
          Wrap(
            spacing: StrotSpacing.md,
            runSpacing: StrotSpacing.md,
            children: [
              _Metric(label: 'Assignments', value: '${assignments.length}'),
              _Metric(label: 'Awaiting response', value: '$pending'),
              _Metric(label: 'Quotation corrections', value: '$corrections'),
            ],
          ),
          const SizedBox(height: StrotSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PartnerAssignmentsScreen(service: assignmentService),
                    ),
                  ),
                  icon: const Icon(Icons.assignment_turned_in_outlined),
                  label: const Text('Review assignments'),
                ),
              ),
              const SizedBox(width: StrotSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PartnerQuotationsScreen(service: quotationService),
                    ),
                  ),
                  icon: const Icon(Icons.request_quote_outlined),
                  label: const Text('Quotation register'),
                ),
              ),
            ],
          ),
          const SizedBox(height: StrotSpacing.xl),
          Text(
            'Recent assignments',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: StrotSpacing.sm),
          if (assignments.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(StrotSpacing.lg),
                child: Text(
                  'No work orders are assigned to your organization.',
                ),
              ),
            ),
          ...assignments
              .take(5)
              .map(
                (item) => Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(StrotSpacing.md),
                    title: Text(item.title),
                    subtitle: Text(
                      '${item.projectReference} · ${item.status.replaceAll('_', ' ')}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PartnerAssignmentsScreen(
                          service: assignmentService,
                          initialId: item.id,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          const SizedBox(height: StrotSpacing.lg),
          Text(
            'Recent quotations',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: StrotSpacing.sm),
          if (quotations.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(StrotSpacing.lg),
                child: Text('No quotations have been submitted.'),
              ),
            ),
          ...quotations
              .take(5)
              .map(
                (item) => Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(StrotSpacing.md),
                    title: Text(item.workTitle),
                    subtitle: Text(
                      '${item.projectReference} · ${item.status.replaceAll('_', ' ')}',
                    ),
                    trailing: Text(
                      '${item.currency} ${(item.amountMinor / 100).toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: StrotColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PartnerQuotationsScreen(
                          service: quotationService,
                          initialId: item.id,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        ],
      );
    },
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 190,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: StrotSpacing.md),
            Text(value, style: Theme.of(context).textTheme.displaySmall),
          ],
        ),
      ),
    ),
  );
}
