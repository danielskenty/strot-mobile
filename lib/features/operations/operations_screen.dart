import 'package:flutter/material.dart';
import '../../core/operations/operation_models.dart';
import '../../core/operations/operation_service.dart';
import '../../design_system/strot_tokens.dart';

class OperationsScreen extends StatefulWidget {
  const OperationsScreen({
    super.key,
    required this.service,
    required this.canSubmit,
  });
  final OperationService service;
  final bool canSubmit;
  @override
  State<OperationsScreen> createState() => _OperationsScreenState();
}

class _OperationsScreenState extends State<OperationsScreen> {
  late Future<(List<ProjectTask>, List<DailySiteReport>)> future;
  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    future = Future.wait([widget.service.tasks(), widget.service.reports()])
        .then(
          (items) => (
            items[0] as List<ProjectTask>,
            items[1] as List<DailySiteReport>,
          ),
        );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text('◇ ${snapshot.error}'));
      }
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final (tasks, reports) = snapshot.data!;
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Site operations'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Tasks'),
                Tab(text: 'Daily reports'),
              ],
            ),
          ),
          floatingActionButton: widget.canSubmit
              ? FloatingActionButton.extended(
                  onPressed: () => _submit(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Site report'),
                )
              : null,
          body: TabBarView(children: [_tasks(tasks), _reports(reports)]),
        ),
      );
    },
  );
  Widget _tasks(List<ProjectTask> tasks) => ListView(
    padding: const EdgeInsets.all(StrotSpacing.lg),
    children: [
      Text('Assigned work', style: Theme.of(context).textTheme.displaySmall),
      const SizedBox(height: StrotSpacing.sm),
      const Text(
        'Deadlines and exact actions across active projects.',
        style: TextStyle(color: StrotColors.charcoalMuted),
      ),
      const SizedBox(height: StrotSpacing.lg),
      ...tasks.map(
        (task) => Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(StrotSpacing.md),
            title: Text(task.title),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: StrotSpacing.sm),
              child: Text(
                '${task.project.reference} · ${task.priority.replaceAll('_', ' ')} · ${task.status.replaceAll('_', ' ')}',
              ),
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TaskDetailScreen(
                    taskId: task.id,
                    service: widget.service,
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
  Widget _reports(List<DailySiteReport> reports) => ListView(
    padding: const EdgeInsets.all(StrotSpacing.lg),
    children: [
      Text(
        'Daily site reports',
        style: Theme.of(context).textTheme.displaySmall,
      ),
      const SizedBox(height: StrotSpacing.sm),
      const Text(
        'Dated field records of progress, labour and constraints.',
        style: TextStyle(color: StrotColors.charcoalMuted),
      ),
      const SizedBox(height: StrotSpacing.lg),
      ...reports.map(
        (report) => Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(StrotSpacing.md),
            leading: Text(
              '${report.reportDate.day}\nAUG',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
            title: Text(report.workCompleted),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: StrotSpacing.sm),
              child: Text(
                '${report.project.reference} · ${report.workersOnSite} on site',
              ),
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SiteReportDetailScreen(
                  reportId: report.id,
                  service: widget.service,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
  Future<void> _submit(BuildContext context) async {
    final completed = TextEditingController(),
        workers = TextEditingController(),
        weather = TextEditingController();
    final submit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit today’s report'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weather,
                decoration: const InputDecoration(labelText: 'Weather'),
              ),
              const SizedBox(height: StrotSpacing.md),
              TextField(
                controller: workers,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Workers on site'),
              ),
              const SizedBox(height: StrotSpacing.md),
              TextField(
                controller: completed,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Work completed'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (submit == true && completed.text.trim().isNotEmpty) {
      await widget.service.submit(
        NewSiteReport(
          projectId: 1,
          reportDate: DateTime.now(),
          workersOnSite: int.tryParse(workers.text) ?? 0,
          workCompleted: completed.text,
          weather: weather.text,
          workPlanned: '',
          blockers: '',
        ),
      );
      if (mounted) setState(refresh);
    }
  }
}

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.taskId,
    required this.service,
  });
  final int taskId;
  final OperationService service;
  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Future<ProjectTask> future;
  @override
  void initState() {
    super.initState();
    future = widget.service.task(widget.taskId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Task')),
    body: FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('◇ ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final task = snapshot.data!;
        final next = task.status == 'assigned'
            ? ['in_progress', 'blocked']
            : task.status == 'in_progress'
            ? ['blocked', 'completed']
            : task.status == 'blocked'
            ? ['in_progress']
            : <String>[];
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            Text(
              task.project.reference,
              style: const TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            Text(task.title, style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: StrotSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(StrotSpacing.lg),
                child: Text(task.description ?? 'No additional instruction.'),
              ),
            ),
            const SizedBox(height: StrotSpacing.lg),
            Wrap(
              spacing: StrotSpacing.sm,
              children: next
                  .map(
                    (status) => FilledButton(
                      onPressed: () async {
                        await widget.service.updateTask(task.id, status);
                        setState(() => future = widget.service.task(task.id));
                      },
                      child: Text(status.replaceAll('_', ' ')),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    ),
  );
}

class SiteReportDetailScreen extends StatelessWidget {
  const SiteReportDetailScreen({
    super.key,
    required this.reportId,
    required this.service,
  });
  final int reportId;
  final OperationService service;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Daily site report')),
    body: FutureBuilder(
      future: service.report(reportId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('◇ ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final report = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          children: [
            Text(
              report.project.reference,
              style: const TextStyle(
                color: StrotColors.gold,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: StrotSpacing.md),
            Text(
              '${report.reportDate.day} August ${report.reportDate.year}',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: StrotSpacing.lg),
            _reportCard(context, 'Completed today', report.workCompleted),
            _reportCard(
              context,
              'Planned next',
              report.workPlanned ?? 'None recorded.',
            ),
            _reportCard(
              context,
              'Constraints',
              report.blockers ?? 'None recorded.',
            ),
            Text(
              '${report.workersOnSite} people on site · ${report.weather ?? 'Weather not recorded'}',
              style: const TextStyle(color: StrotColors.charcoalMuted),
            ),
          ],
        );
      },
    ),
  );
  Widget _reportCard(BuildContext context, String title, String body) => Card(
    child: Padding(
      padding: const EdgeInsets.all(StrotSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: StrotSpacing.sm),
          Text(body),
        ],
      ),
    ),
  );
}
