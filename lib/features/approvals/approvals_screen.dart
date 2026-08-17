import 'package:flutter/material.dart';
import '../../core/approvals/approval_models.dart';
import '../../core/approvals/approval_service.dart';
import '../../design_system/strot_tokens.dart';

class ApprovalsScreen extends StatelessWidget {
  const ApprovalsScreen({super.key, required this.service});
  final ApprovalService service;
  @override
  Widget build(BuildContext context) => FutureBuilder<List<StrotApproval>>(
    future: service.list(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'DECISIONS & GOVERNANCE',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text('Approvals', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: StrotSpacing.sm),
          const Text('Review items that require your recorded authorization.'),
          const SizedBox(height: StrotSpacing.xl),
          Card(
            child: Column(
              children: snapshot.data!
                  .map(
                    (item) => Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.all(StrotSpacing.md),
                          title: Text(item.title),
                          subtitle: Text(
                            '${item.projectReference} · Version ${item.version}\nDue ${item.dueAt.day} Aug 2026',
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ApprovalReviewScreen(
                                approval: item,
                                service: service,
                              ),
                            ),
                          ),
                        ),
                        if (item != snapshot.data!.last)
                          const Divider(height: 1),
                      ],
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

class ApprovalReviewScreen extends StatefulWidget {
  const ApprovalReviewScreen({
    super.key,
    required this.approval,
    required this.service,
  });
  final StrotApproval approval;
  final ApprovalService service;
  @override
  State<ApprovalReviewScreen> createState() => _ApprovalReviewScreenState();
}

class _ApprovalReviewScreenState extends State<ApprovalReviewScreen> {
  ApprovalStatus decision = ApprovalStatus.approved;
  final note = TextEditingController();
  bool submitting = false;
  String? error;
  bool complete = false;
  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (decision == ApprovalStatus.changesRequested &&
        note.text.trim().isEmpty) {
      setState(() => error = 'Explain the changes required before submitting.');
      return;
    }
    setState(() {
      submitting = true;
      error = null;
    });
    await widget.service.decide(
      id: widget.approval.id,
      decision: decision,
      note: note.text.trim(),
    );
    if (mounted) {
      setState(() {
        submitting = false;
        complete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Review approval')),
    body: ListView(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      children: [
        if (complete)
          Container(
            padding: const EdgeInsets.all(StrotSpacing.md),
            decoration: const BoxDecoration(
              color: StrotColors.goldMuted,
              border: Border(
                left: BorderSide(color: StrotColors.gold, width: 2),
              ),
            ),
            child: const Text(
              '✓ Your decision has been recorded in the audit history.',
            ),
          ),
        if (complete) const SizedBox(height: StrotSpacing.lg),
        Text(
          '${widget.approval.projectReference} · VERSION ${widget.approval.version}',
          style: const TextStyle(
            color: StrotColors.gold,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: StrotSpacing.md),
        Text(
          widget.approval.title,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        Text(
          '${widget.approval.projectName} · Due ${widget.approval.dueAt.day} Aug 2026',
        ),
        const SizedBox(height: StrotSpacing.xl),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review context',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: StrotSpacing.md),
                Text(widget.approval.description),
                const Divider(height: StrotSpacing.xl),
                Text(
                  'Document: ${widget.approval.title} v${widget.approval.version}',
                ),
                const SizedBox(height: StrotSpacing.sm),
                Text('Project: ${widget.approval.projectName}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: StrotSpacing.md),
        if (!complete)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(StrotSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Record your decision',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  RadioGroup<ApprovalStatus>(
                    groupValue: decision,
                    onChanged: (value) => setState(() => decision = value!),
                    child: const Column(
                      children: [
                        RadioListTile(
                          value: ApprovalStatus.approved,
                          title: Text('Approve'),
                          subtitle: Text('Authorise the current version.'),
                        ),
                        RadioListTile(
                          value: ApprovalStatus.changesRequested,
                          title: Text('Request changes'),
                          subtitle: Text('Return it with clear feedback.'),
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    controller: note,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: decision == ApprovalStatus.changesRequested
                          ? 'Decision note (required)'
                          : 'Decision note (optional)',
                    ),
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: StrotSpacing.md),
                      child: Text(
                        '◇ $error',
                        style: const TextStyle(color: StrotColors.forest),
                      ),
                    ),
                  const SizedBox(height: StrotSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitting ? null : submit,
                      child: Text(
                        submitting
                            ? 'Recording…'
                            : decision == ApprovalStatus.approved
                            ? 'Approve version'
                            : 'Submit change request',
                      ),
                    ),
                  ),
                  const SizedBox(height: StrotSpacing.sm),
                  const Text(
                    'Your identity, decision, note and timestamp will be stored in the audit history.',
                    style: TextStyle(color: StrotColors.charcoalMuted),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
