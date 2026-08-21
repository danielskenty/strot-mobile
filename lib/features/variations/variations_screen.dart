import 'package:flutter/material.dart';
import '../../core/variations/variation_models.dart';
import '../../core/variations/variation_service.dart';
import '../../design_system/strot_tokens.dart';

class VariationsScreen extends StatelessWidget {
  const VariationsScreen({super.key, required this.service});
  final VariationService service;
  String money(ProjectVariation item) =>
      '${item.amountDeltaMinor > 0 ? '+' : ''}${item.currency} ${(item.amountDeltaMinor / 100).toStringAsFixed(0)}';
  @override
  Widget build(BuildContext context) => FutureBuilder<List<ProjectVariation>>(
    future: service.list(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'COMMERCIAL CHANGE CONTROL',
            style: TextStyle(
              color: StrotColors.gold,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text('Variations', style: Theme.of(context).textTheme.displayMedium),
          const Text(
            'Review cost, scope and schedule impact before the project baseline changes.',
          ),
          const SizedBox(height: StrotSpacing.xl),
          Card(
            child: Column(
              children: snapshot.data!
                  .map(
                    (item) => ListTile(
                      contentPadding: const EdgeInsets.all(StrotSpacing.md),
                      title: Text(item.title),
                      subtitle: Text(
                        '${item.reference} · ${money(item)} · ${item.scheduleDeltaDays >= 0 ? '+' : ''}${item.scheduleDeltaDays} days\n${item.status}',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => VariationReviewScreen(
                            item: item,
                            service: service,
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

class VariationReviewScreen extends StatefulWidget {
  const VariationReviewScreen({
    super.key,
    required this.item,
    required this.service,
  });
  final ProjectVariation item;
  final VariationService service;
  @override
  State<VariationReviewScreen> createState() => _VariationReviewScreenState();
}

class _VariationReviewScreenState extends State<VariationReviewScreen> {
  String decision = 'approved';
  final note = TextEditingController();
  String? error;
  bool complete = false;
  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (decision != 'approved' && note.text.trim().isEmpty) {
      setState(() => error = 'Explain a rejection or requested revision.');
      return;
    }
    await widget.service.decide(
      id: widget.item.id,
      decision: decision,
      note: note.text.trim(),
    );
    if (mounted) setState(() => complete = true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Review variation')),
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
        const SizedBox(height: StrotSpacing.sm),
        Text(
          widget.item.title,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        Text('${widget.item.projectReference} · ${widget.item.projectName}'),
        const SizedBox(height: StrotSpacing.xl),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Commercial impact',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: StrotSpacing.md),
                Text(
                  '${widget.item.currency} ${(widget.item.amountDeltaMinor / 100).toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  '${widget.item.scheduleDeltaDays >= 0 ? '+' : ''}${widget.item.scheduleDeltaDays} schedule days',
                  style: const TextStyle(color: StrotColors.gold),
                ),
                const Divider(height: StrotSpacing.xl),
                Text(widget.item.reason),
                const SizedBox(height: StrotSpacing.md),
                Text(widget.item.scopeDescription),
              ],
            ),
          ),
        ),
        if (widget.item.status == 'submitted' && !complete) ...[
          const SizedBox(height: StrotSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: decision,
            decoration: const InputDecoration(labelText: 'Decision'),
            items: const [
              DropdownMenuItem(
                value: 'approved',
                child: Text('Approve variation'),
              ),
              DropdownMenuItem(
                value: 'changes_requested',
                child: Text('Request revision'),
              ),
              DropdownMenuItem(
                value: 'rejected',
                child: Text('Reject variation'),
              ),
            ],
            onChanged: (value) => setState(() => decision = value!),
          ),
          const SizedBox(height: StrotSpacing.md),
          TextField(
            controller: note,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Decision note',
              errorText: error,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          FilledButton(onPressed: submit, child: const Text('Record decision')),
        ],
        if (complete)
          Container(
            margin: const EdgeInsets.only(top: StrotSpacing.md),
            padding: const EdgeInsets.all(StrotSpacing.md),
            color: StrotColors.goldMuted,
            child: const Text('Decision recorded in the audit history.'),
          ),
      ],
    ),
  );
}
