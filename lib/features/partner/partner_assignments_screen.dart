import 'package:flutter/material.dart';
import '../../core/partner/partner_assignment_service.dart';
import '../../design_system/strot_tokens.dart';

class PartnerAssignmentsScreen extends StatelessWidget {
  const PartnerAssignmentsScreen({super.key, required this.service});
  final PartnerAssignmentService service;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Assignment review')),
    body: FutureBuilder<List<PartnerAssignment>>(
      future: service.list(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            const Text(
              'PARTNER ASSIGNMENTS',
              style: TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            Text(
              'Review assigned work',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: StrotSpacing.xl),
            ...snapshot.data!.map(
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
                      builder: (_) =>
                          _AssignmentDetail(item: item, service: service),
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

class _AssignmentDetail extends StatefulWidget {
  const _AssignmentDetail({required this.item, required this.service});
  final PartnerAssignment item;
  final PartnerAssignmentService service;
  @override
  State<_AssignmentDetail> createState() => _AssignmentDetailState();
}

class _AssignmentDetailState extends State<_AssignmentDetail> {
  final note = TextEditingController();
  bool saving = false;
  Future<void> decide(String decision) async {
    setState(() => saving = true);
    try {
      await widget.service.respond(
        widget.item.id,
        decision,
        note: note.text.trim().isEmpty ? null : note.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.item.title)),
    body: ListView(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      children: [
        Text(
          widget.item.projectReference,
          style: const TextStyle(
            color: StrotColors.gold,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          widget.item.title,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: StrotSpacing.lg),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            child: Text(widget.item.description),
          ),
        ),
        if (widget.item.status == 'assignment_pending') ...[
          TextField(
            controller: note,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Response note (required to decline)',
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          FilledButton(
            onPressed: saving ? null : () => decide('accept'),
            child: const Text('Accept assignment'),
          ),
          OutlinedButton(
            onPressed: saving || note.text.trim().isEmpty
                ? null
                : () => decide('decline'),
            child: const Text('Decline with reason'),
          ),
        ],
      ],
    ),
  );
}
