import 'package:flutter/material.dart';
import '../../core/issues/issue_models.dart';
import '../../core/issues/issue_service.dart';
import '../../core/projects/project_models.dart';
import '../../core/projects/project_service.dart';
import '../../design_system/strot_tokens.dart';

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({
    super.key,
    required this.service,
    required this.projectService,
    required this.canManage,
    required this.canCreate,
    this.initialId,
  });
  final IssueService service;
  final ProjectService projectService;
  final bool canManage, canCreate;
  final int? initialId;
  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  late Future<List<ProjectIssue>> future;
  @override
  void initState() {
    super.initState();
    future = widget.service.list();
  }

  void refresh() {
    future = widget.service.list();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialId != null) {
      return IssueDetailScreen(
        id: widget.initialId!,
        service: widget.service,
        canManage: widget.canManage,
      );
    }
    return Scaffold(
      floatingActionButton: widget.canCreate
          ? FloatingActionButton.extended(
              onPressed: _create,
              icon: const Icon(Icons.add),
              label: const Text('Raise issue'),
            )
          : null,
      body: FutureBuilder<List<ProjectIssue>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('◇ ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(StrotSpacing.lg),
            children: [
              const Text(
                'ACCOUNTABLE RESOLUTION REGISTER',
                style: TextStyle(
                  color: StrotColors.gold,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: StrotSpacing.md),
              Text(
                'Issues, RFIs & delays',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const Text(
                'Track concerns, STROT responses and final resolution records.',
              ),
              const SizedBox(height: StrotSpacing.xl),
              if (snapshot.data!.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(StrotSpacing.lg),
                    child: Text('No project issues are currently recorded.'),
                  ),
                )
              else
                ...snapshot.data!.map(
                  (item) => Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(StrotSpacing.md),
                      title: Text(item.title),
                      subtitle: Text(
                        '${item.reference} · ${item.projectReference}\n${item.category.toUpperCase()} · ${item.status.replaceAll('_', ' ')}',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => IssueDetailScreen(
                              id: item.id,
                              service: widget.service,
                              canManage: widget.canManage,
                            ),
                          ),
                        );
                        if (mounted) setState(refresh);
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _create() async {
    final projects = await widget.projectService.list();
    if (!mounted) return;
    if (projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authorized project is available.')),
      );
      return;
    }
    final result = await showDialog<_NewIssue>(
      context: context,
      builder: (_) => _NewIssueDialog(projects: projects),
    );
    if (result == null) return;
    final issue = await widget.service.create(
      projectId: result.projectId,
      category: result.category,
      priority: result.priority,
      title: result.title,
      description: result.description,
    );
    if (mounted) {
      setState(refresh);
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => IssueDetailScreen(
            id: issue.id,
            service: widget.service,
            canManage: widget.canManage,
          ),
        ),
      );
    }
  }
}

class IssueDetailScreen extends StatefulWidget {
  const IssueDetailScreen({
    super.key,
    required this.id,
    required this.service,
    required this.canManage,
  });
  final int id;
  final IssueService service;
  final bool canManage;
  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  late Future<ProjectIssue> future;
  @override
  void initState() {
    super.initState();
    future = widget.service.get(widget.id);
  }

  void refresh() {
    future = widget.service.get(widget.id);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Project issue')),
    body: FutureBuilder<ProjectIssue>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('◇ ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final item = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            Text(
              item.reference,
              style: const TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: StrotSpacing.sm),
            Text(item.title, style: Theme.of(context).textTheme.displayMedium),
            Text('${item.projectReference} · ${item.projectName}'),
            const SizedBox(height: StrotSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(StrotSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.description),
                    const SizedBox(height: StrotSpacing.md),
                    Text(
                      'Raised by ${item.createdBy} · ${item.priority.replaceAll('_', ' ')}',
                    ),
                  ],
                ),
              ),
            ),
            if (item.response != null) ...[
              const SizedBox(height: StrotSpacing.md),
              Container(
                padding: const EdgeInsets.all(StrotSpacing.lg),
                decoration: BoxDecoration(
                  border: Border.all(color: StrotColors.gold),
                  color: StrotColors.goldMuted,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STROT response',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: StrotSpacing.sm),
                    Text(item.response!),
                    if (item.respondedBy != null)
                      Text('Recorded by ${item.respondedBy}'),
                  ],
                ),
              ),
            ],
            if (item.category == 'delay') ...[
              const SizedBox(height: StrotSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(StrotSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DELAY RECOVERY PLAN',
                        style: TextStyle(
                          color: StrotColors.gold,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: StrotSpacing.sm),
                      Text(
                        'Programme recovery',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: StrotSpacing.md),
                      Text(
                        (item.recoveryStatus ?? 'awaiting plan').replaceAll(
                          '_',
                          ' ',
                        ),
                        key: const Key('recovery-status'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const Divider(height: StrotSpacing.xl),
                      Text(
                        'Programme impact',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: StrotSpacing.xs),
                      Text(
                        item.impactSummary ??
                            'STROT is assessing the programme impact.',
                      ),
                      const SizedBox(height: StrotSpacing.md),
                      Text(
                        'Recovery actions',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: StrotSpacing.xs),
                      Text(
                        item.recoveryPlan ??
                            'Accountable recovery actions are being prepared.',
                      ),
                      const SizedBox(height: StrotSpacing.md),
                      Text(
                        'Owner: ${item.recoveryOwner ?? 'STROT operations queue'}',
                      ),
                      Text(
                        'Target: ${item.recoveryTargetOn == null ? 'Being confirmed' : item.recoveryTargetOn!.toIso8601String().split('T').first}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: StrotSpacing.lg),
            if (widget.canManage && item.status != 'closed')
              ElevatedButton(
                onPressed: () => _manage(item),
                child: const Text('Update issue'),
              ),
            if (!widget.canManage && item.status == 'resolved')
              OutlinedButton(
                key: const Key('close-resolved-issue'),
                onPressed: () async {
                  await widget.service.update(id: item.id, status: 'closed');
                  if (mounted) setState(refresh);
                },
                child: const Text('Confirm resolution and close'),
              ),
          ],
        );
      },
    ),
  );
  Future<void> _manage(ProjectIssue item) async {
    final result = await showDialog<_IssueUpdate>(
      context: context,
      builder: (_) => _IssueUpdateDialog(item: item),
    );
    if (result == null) return;
    await widget.service.update(
      id: item.id,
      status: result.status,
      response: result.response,
      impactSummary: result.impactSummary,
      recoveryPlan: result.recoveryPlan,
      recoveryTargetOn: result.recoveryTargetOn,
      recoveryStatus: result.recoveryStatus,
      recoveryOwnerId: result.recoveryOwnerId,
    );
    if (mounted) setState(refresh);
  }
}

class _NewIssue {
  const _NewIssue(
    this.projectId,
    this.category,
    this.priority,
    this.title,
    this.description,
  );
  final int projectId;
  final String category, priority, title, description;
}

class _NewIssueDialog extends StatefulWidget {
  const _NewIssueDialog({required this.projects});
  final List<StrotProject> projects;
  @override
  State<_NewIssueDialog> createState() => _NewIssueDialogState();
}

class _NewIssueDialogState extends State<_NewIssueDialog> {
  int? projectId;
  String category = 'issue', priority = 'action_required';
  final title = TextEditingController(), description = TextEditingController();
  String? error;
  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  void submit() {
    if (projectId == null ||
        title.text.trim().isEmpty ||
        description.text.trim().length < 10) {
      setState(
        () => error = 'Choose a project and provide a clear description.',
      );
      return;
    }
    Navigator.pop(
      context,
      _NewIssue(
        projectId!,
        category,
        priority,
        title.text.trim(),
        description.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Raise project issue'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            key: const Key('issue-project-select'),
            initialValue: projectId,
            decoration: const InputDecoration(labelText: 'Project'),
            items: widget.projects
                .map(
                  (p) => DropdownMenuItem(
                    value: p.id,
                    child: Text('${p.name} · ${p.reference}'),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => projectId = value),
          ),
          const SizedBox(height: StrotSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: const [
              DropdownMenuItem(value: 'issue', child: Text('Project issue')),
              DropdownMenuItem(
                value: 'rfi',
                child: Text('Request for information'),
              ),
              DropdownMenuItem(value: 'delay', child: Text('Delay')),
            ],
            onChanged: (value) => setState(() => category = value!),
          ),
          const SizedBox(height: StrotSpacing.md),
          TextField(
            key: const Key('issue-title'),
            controller: title,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: StrotSpacing.md),
          TextField(
            key: const Key('issue-description'),
            controller: description,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Description',
              errorText: error,
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: submit, child: const Text('Submit issue')),
    ],
  );
}

class _IssueUpdate {
  const _IssueUpdate(
    this.status,
    this.response,
    this.impactSummary,
    this.recoveryPlan,
    this.recoveryTargetOn,
    this.recoveryStatus,
    this.recoveryOwnerId,
  );
  final String status;
  final String? response;
  final String? impactSummary, recoveryPlan, recoveryTargetOn, recoveryStatus;
  final int? recoveryOwnerId;
}

class _IssueUpdateDialog extends StatefulWidget {
  const _IssueUpdateDialog({required this.item});
  final ProjectIssue item;
  @override
  State<_IssueUpdateDialog> createState() => _IssueUpdateDialogState();
}

class _IssueUpdateDialogState extends State<_IssueUpdateDialog> {
  late String status;
  late String recoveryStatus;
  final response = TextEditingController(),
      impactSummary = TextEditingController(),
      recoveryPlan = TextEditingController(),
      recoveryTargetOn = TextEditingController(),
      recoveryOwnerId = TextEditingController();
  String? error;
  @override
  void initState() {
    super.initState();
    status = widget.item.status == 'open'
        ? 'acknowledged'
        : widget.item.status == 'resolved'
        ? 'in_progress'
        : 'resolved';
    response.text = widget.item.response ?? '';
    impactSummary.text = widget.item.impactSummary ?? '';
    recoveryPlan.text = widget.item.recoveryPlan ?? '';
    recoveryTargetOn.text =
        widget.item.recoveryTargetOn?.toIso8601String().split('T').first ?? '';
    recoveryStatus = widget.item.recoveryStatus ?? 'planned';
    recoveryOwnerId.text = widget.item.recoveryOwnerId?.toString() ?? '';
  }

  @override
  void dispose() {
    response.dispose();
    impactSummary.dispose();
    recoveryPlan.dispose();
    recoveryTargetOn.dispose();
    recoveryOwnerId.dispose();
    super.dispose();
  }

  void submit() {
    if (status == 'resolved' && response.text.trim().isEmpty) {
      setState(() => error = 'Resolution requires an accountable response.');
      return;
    }
    if (widget.item.category == 'delay' &&
        status == 'resolved' &&
        (impactSummary.text.trim().isEmpty ||
            recoveryPlan.text.trim().isEmpty ||
            recoveryTargetOn.text.trim().isEmpty)) {
      setState(
        () => error =
            'Resolved delays require impact, recovery actions and a target date.',
      );
      return;
    }
    Navigator.pop(
      context,
      _IssueUpdate(
        status,
        response.text.trim().isEmpty ? null : response.text.trim(),
        impactSummary.text.trim().isEmpty ? null : impactSummary.text.trim(),
        recoveryPlan.text.trim().isEmpty ? null : recoveryPlan.text.trim(),
        recoveryTargetOn.text.trim().isEmpty
            ? null
            : recoveryTargetOn.text.trim(),
        widget.item.category == 'delay' ? recoveryStatus : null,
        int.tryParse(recoveryOwnerId.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Update issue'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: status,
            decoration: const InputDecoration(labelText: 'Next status'),
            items: [
              if (widget.item.status == 'open')
                const DropdownMenuItem(
                  value: 'acknowledged',
                  child: Text('Acknowledge'),
                ),
              if ([
                'acknowledged',
                'in_progress',
              ].contains(widget.item.status)) ...const [
                DropdownMenuItem(
                  value: 'in_progress',
                  child: Text('In progress'),
                ),
                DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
              ],
              if (widget.item.status == 'resolved')
                const DropdownMenuItem(
                  value: 'in_progress',
                  child: Text('Reopen'),
                ),
            ],
            onChanged: (value) => setState(() => status = value!),
          ),
          const SizedBox(height: StrotSpacing.md),
          TextField(
            controller: response,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Accountable response',
              errorText: error,
            ),
          ),
          if (widget.item.category == 'delay') ...[
            const SizedBox(height: StrotSpacing.md),
            TextField(
              key: const Key('recovery-impact'),
              controller: impactSummary,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Programme impact'),
            ),
            const SizedBox(height: StrotSpacing.md),
            TextField(
              key: const Key('recovery-plan'),
              controller: recoveryPlan,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Recovery actions'),
            ),
            const SizedBox(height: StrotSpacing.md),
            TextField(
              key: const Key('recovery-target'),
              controller: recoveryTargetOn,
              decoration: const InputDecoration(
                labelText: 'Target recovery (YYYY-MM-DD)',
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: recoveryStatus,
              decoration: const InputDecoration(labelText: 'Recovery state'),
              items: const [
                DropdownMenuItem(value: 'planned', child: Text('Planned')),
                DropdownMenuItem(
                  value: 'in_progress',
                  child: Text('In progress'),
                ),
                DropdownMenuItem(value: 'at_risk', child: Text('At risk')),
                DropdownMenuItem(value: 'recovered', child: Text('Recovered')),
              ],
              onChanged: (value) => setState(() => recoveryStatus = value!),
            ),
            const SizedBox(height: StrotSpacing.md),
            TextField(
              controller: recoveryOwnerId,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Accountable owner user ID',
              ),
            ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: submit, child: const Text('Save update')),
    ],
  );
}
