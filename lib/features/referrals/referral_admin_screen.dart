import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/referrals/referral_models.dart';
import '../../core/referrals/referral_service.dart';
import '../../design_system/strot_tokens.dart';

class ReferralAdminScreen extends StatefulWidget {
  const ReferralAdminScreen({
    super.key,
    required this.service,
    this.initialCategory,
    this.initialId,
  });
  final ReferralService service;
  final String? initialCategory, initialId;
  @override
  State<ReferralAdminScreen> createState() => _ReferralAdminScreenState();
}

class _ReferralAdminScreenState extends State<ReferralAdminScreen> {
  late Future<ReferralAdminWorkspace> future = widget.service
      .loadAdminWorkspace();
  void reload() => setState(() {
    future = widget.service.loadAdminWorkspace();
  });
  @override
  Widget build(BuildContext context) => Material(
    color: StrotColors.cream,
    child: FutureBuilder<ReferralAdminWorkspace>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: OutlinedButton(
              onPressed: reload,
              child: const Text('Retry referral governance'),
            ),
          );
        }
        final record = snapshot.requireData;
        if (widget.initialId != null) {
          final item = record.queue
              .where(
                (value) =>
                    value.id == widget.initialId &&
                    (widget.initialCategory == null ||
                        value.category == widget.initialCategory),
              )
              .firstOrNull;
          if (item != null) {
            return _ExactAdminItem(item: item, onReview: _review);
          }
        }
        return _AdminBody(record: record, onReview: _review);
      },
    ),
  );
  Future<void> _review(ReferralAdminQueueItem item) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ReviewForm(service: widget.service, item: item),
    );
    if (result == true) reload();
  }
}

class _AdminBody extends StatelessWidget {
  const _AdminBody({required this.record, required this.onReview});
  final ReferralAdminWorkspace record;
  final ValueChanged<ReferralAdminQueueItem> onReview;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => ListView(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      children: [
        Text(
          'REFERRAL GOVERNANCE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: StrotColors.gold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: StrotSpacing.sm),
        Text(
          'Referral control plane',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: StrotSpacing.sm),
        const Text(
          'Programme posture, own-service exclusions and accountable operational reviews. Confidential rule values remain restricted to authorised administration.',
        ),
        const SizedBox(height: StrotSpacing.lg),
        GridView.count(
          crossAxisCount: constraints.maxWidth >= 1000 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: StrotSpacing.md,
          mainAxisSpacing: StrotSpacing.md,
          childAspectRatio: constraints.maxWidth >= 1000 ? 1.8 : 1.3,
          children: [
            _Metric(
              label: 'Active members',
              value: '${record.metrics.activeMembers}',
            ),
            _Metric(
              label: 'Referrals in range',
              value: '${record.analytics.referrals}',
            ),
            _Metric(
              label: 'Verified payment backing',
              value: _money(record.analytics.verifiedPaymentBackingMinor),
            ),
            _Metric(
              label: 'Withdrawals pending',
              value: '${record.metrics.pendingWithdrawals}',
            ),
          ],
        ),
        const SizedBox(height: StrotSpacing.lg),
        _Panel(
          title: 'Programme register',
          child: Wrap(
            spacing: StrotSpacing.md,
            runSpacing: StrotSpacing.md,
            children: record.programmes
                .map(
                  (item) => Container(
                    width: constraints.maxWidth >= 900 ? 280 : double.infinity,
                    padding: const EdgeInsets.all(StrotSpacing.md),
                    decoration: BoxDecoration(
                      border: Border.all(color: StrotColors.forestMuted),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: StrotSpacing.xs),
                        Text(item.description),
                        const SizedBox(height: StrotSpacing.sm),
                        Text(
                          '${item.attributionWindowDays}-day attribution',
                          style: const TextStyle(color: StrotColors.gold),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: StrotSpacing.lg),
        _Panel(
          title: 'Provider eligibility matrix',
          subtitle:
              'Automatically excluded own services cannot be overridden by an administrator or AI.',
          child: record.eligibility.isEmpty
              ? const Text('No provider service assignments are configured.')
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Organisation')),
                      DataColumn(label: Text('Provided services')),
                      DataColumn(label: Text('Excluded')),
                      DataColumn(label: Text('Eligible')),
                    ],
                    rows: record.eligibility
                        .map(
                          (row) => DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  '${row.organizationName}\n${row.organizationType.replaceAll('_', ' ')}',
                                ),
                              ),
                              DataCell(
                                Text(
                                  row.providedServices.isEmpty
                                      ? 'None'
                                      : row.providedServices.join(', '),
                                ),
                              ),
                              DataCell(Text('${row.excludedCount}')),
                              DataCell(Text('${row.eligibleCount}')),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
        ),
        const SizedBox(height: StrotSpacing.lg),
        _Panel(
          title: 'Review queue',
          subtitle: '${record.queue.length} accountable records',
          child: record.queue.isEmpty
              ? const Text(
                  'No referral records currently require governance review.',
                )
              : Column(
                  children: record.queue
                      .map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.title),
                          subtitle: Text(
                            '${item.category.replaceAll('_', ' ')} · ${item.context}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.riskScore != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: StrotSpacing.sm,
                                  ),
                                  child: Text(
                                    'Risk ${item.riskScore}',
                                    style: const TextStyle(
                                      color: StrotColors.gold,
                                    ),
                                  ),
                                ),
                              Chip(
                                label: Text(item.status.replaceAll('_', ' ')),
                              ),
                              IconButton(
                                key: Key('review-${item.id}'),
                                onPressed: () => onReview(item),
                                icon: const Icon(Icons.rate_review_outlined),
                                tooltip: 'Review exact record',
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    ),
  );
}

class _ExactAdminItem extends StatelessWidget {
  const _ExactAdminItem({required this.item, required this.onReview});
  final ReferralAdminQueueItem item;
  final ValueChanged<ReferralAdminQueueItem> onReview;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(StrotSpacing.lg),
    children: [
      TextButton.icon(
        onPressed: () => Navigator.maybePop(context),
        icon: const Icon(Icons.arrow_back),
        label: const Text('Referral control plane'),
      ),
      const SizedBox(height: StrotSpacing.md),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EXACT GOVERNANCE RECORD',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: StrotColors.gold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: StrotSpacing.sm),
              Text(
                item.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: StrotSpacing.sm),
              Text('${item.category.replaceAll('_', ' ')} · ${item.context}'),
              const SizedBox(height: StrotSpacing.md),
              Chip(label: Text(item.status.replaceAll('_', ' '))),
              const SizedBox(height: StrotSpacing.md),
              ElevatedButton.icon(
                onPressed: () => onReview(item),
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('Review this record'),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _ReviewForm extends StatefulWidget {
  const _ReviewForm({required this.service, required this.item});
  final ReferralService service;
  final ReferralAdminQueueItem item;
  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  final key = GlobalKey<FormState>();
  final note = TextEditingController();
  late String decision = _options(widget.item).first;
  bool saving = false;
  String? error;
  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      StrotSpacing.lg,
      StrotSpacing.lg,
      StrotSpacing.lg,
      MediaQuery.viewInsetsOf(context).bottom + StrotSpacing.lg,
    ),
    child: Form(
      key: key,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Review exact ${widget.item.category} record',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: StrotSpacing.sm),
            Text(widget.item.title),
            const SizedBox(height: StrotSpacing.md),
            DropdownButtonFormField<String>(
              key: const Key('referral-review-decision'),
              initialValue: decision,
              decoration: const InputDecoration(labelText: 'Decision'),
              items: _options(widget.item)
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item.replaceAll('_', ' ')),
                    ),
                  )
                  .toList(),
              onChanged: (value) => decision = value!,
            ),
            const SizedBox(height: StrotSpacing.md),
            TextFormField(
              key: const Key('referral-review-note'),
              controller: note,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Accountable review note',
              ),
              validator: (value) => (value?.trim().length ?? 0) < 12
                  ? 'Provide at least 12 characters'
                  : null,
            ),
            if (error != null) ...[
              const SizedBox(height: StrotSpacing.md),
              Container(
                padding: const EdgeInsets.all(StrotSpacing.md),
                color: StrotColors.goldMuted,
                child: Text(error!),
              ),
            ],
            const SizedBox(height: StrotSpacing.lg),
            ElevatedButton(
              onPressed: saving ? null : save,
              child: Text(saving ? 'Recording…' : 'Record decision'),
            ),
          ],
        ),
      ),
    ),
  );
  Future<void> save() async {
    if (!key.currentState!.validate()) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.service.review(
        category: widget.item.category,
        id: widget.item.id,
        decision: decision,
        note: note.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } on Object catch (exception) {
      if (mounted) {
        setState(() {
          saving = false;
          error = exception is ApiException
              ? exception.message
              : 'The decision could not be recorded.';
        });
      }
    }
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child, this.subtitle});
  final String title;
  final String? subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          if (subtitle != null) ...[
            const SizedBox(height: StrotSpacing.sm),
            Text(subtitle!),
          ],
          const Divider(height: StrotSpacing.xl),
          child,
        ],
      ),
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(StrotSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: StrotSpacing.sm),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    ),
  );
}

List<String> _options(ReferralAdminQueueItem item) => switch (item.category) {
  'interest' => ['under_review', 'approved', 'rejected'],
  'lead' => ['referral_verified', 'withdrawn'],
  'withdrawal' =>
    item.status == 'requested'
        ? ['under_review', 'rejected']
        : item.status == 'under_review'
        ? ['approved', 'rejected']
        : ['paid', 'rejected'],
  'kyc' =>
    item.status == 'submitted'
        ? ['under_review']
        : ['verified', 'resubmission_required', 'rejected'],
  'fraud' => ['cleared', 'fraudulent'],
  _ => ['under_review'],
};
String _money(int minor) => 'NGN ${(minor / 100).toStringAsFixed(2)}';
