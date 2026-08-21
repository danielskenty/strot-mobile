import 'package:flutter/material.dart';
import '../../core/inspections/inspection_models.dart';
import '../../core/inspections/inspection_service.dart';
import '../../design_system/strot_tokens.dart';

class InspectionsScreen extends StatelessWidget {
  const InspectionsScreen({
    super.key,
    required this.service,
    this.canReview = false,
  });
  final InspectionService service;
  final bool canReview;
  @override
  Widget build(BuildContext context) => FutureBuilder<List<SiteInspection>>(
    future: service.list(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'SITE ASSURANCE',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text('Inspections', style: Theme.of(context).textTheme.displayMedium),
          const Text('Scheduled field checks, evidence and review decisions.'),
          const SizedBox(height: StrotSpacing.xl),
          Card(
            child: Column(
              children: snapshot.data!
                  .map(
                    (item) => ListTile(
                      contentPadding: const EdgeInsets.all(StrotSpacing.md),
                      title: Text(item.title),
                      subtitle: Text(
                        '${item.reference} · ${item.location}\n${item.status} · ${item.complete}/${item.checklist.length} checks',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => InspectionDetailScreen(
                            item: item,
                            service: service,
                            canReview: canReview,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      );
    },
  );
}

class InspectionDetailScreen extends StatefulWidget {
  const InspectionDetailScreen({
    super.key,
    required this.item,
    required this.service,
    required this.canReview,
  });
  final SiteInspection item;
  final InspectionService service;
  final bool canReview;
  @override
  State<InspectionDetailScreen> createState() => _InspectionDetailScreenState();
}

class _InspectionDetailScreenState extends State<InspectionDetailScreen> {
  String decision = 'approved';
  final note = TextEditingController();
  bool complete = false;
  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Inspection record')),
    body: ListView(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      children: [
        Text(
          widget.item.reference,
          style: const TextStyle(
            color: StrotColors.gold,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          widget.item.title,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        Text('${widget.item.projectReference} · ${widget.item.location}'),
        const SizedBox(height: StrotSpacing.lg),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Checklist · ${widget.item.complete}/${widget.item.checklist.length}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ...widget.item.checklist.map(
                  (check) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      check.complete ? Icons.check : Icons.circle_outlined,
                      color: check.complete
                          ? StrotColors.forest
                          : StrotColors.gold,
                    ),
                    title: Text(check.label),
                    subtitle: check.note == null ? null : Text(check.note!),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: StrotSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Findings', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: StrotSpacing.sm),
                Text(widget.item.findings ?? 'Awaiting submission.'),
                const Divider(height: StrotSpacing.xl),
                Text('Evidence', style: Theme.of(context).textTheme.titleLarge),
                ...widget.item.evidenceNames.map(
                  (name) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.description_outlined),
                    title: Text(name),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.canReview &&
            widget.item.status == 'submitted' &&
            !complete) ...[
          const SizedBox(height: StrotSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: decision,
            decoration: const InputDecoration(labelText: 'Review decision'),
            items: const [
              DropdownMenuItem(
                value: 'approved',
                child: Text('Approve inspection'),
              ),
              DropdownMenuItem(
                value: 'changes_requested',
                child: Text('Return for correction'),
              ),
              DropdownMenuItem(
                value: 'flagged',
                child: Text('Flag for escalation'),
              ),
            ],
            onChanged: (value) => setState(() => decision = value!),
          ),
          const SizedBox(height: StrotSpacing.md),
          TextField(
            controller: note,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Review note'),
          ),
          const SizedBox(height: StrotSpacing.md),
          FilledButton(
            onPressed: () async {
              await widget.service.review(
                widget.item.id,
                decision,
                note.text.trim(),
              );
              if (mounted) setState(() => complete = true);
            },
            child: const Text('Record review'),
          ),
        ],
        if (complete)
          Container(
            margin: const EdgeInsets.only(top: StrotSpacing.md),
            padding: const EdgeInsets.all(StrotSpacing.md),
            color: StrotColors.goldMuted,
            child: const Text('Inspection review recorded.'),
          ),
      ],
    ),
  );
}
