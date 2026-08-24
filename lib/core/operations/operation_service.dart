import '../network/api_client.dart';
import 'operation_models.dart';
import '../sync/sync_outbox.dart';

abstract interface class OperationService {
  Future<List<OperationProject>> reportProjects();
  Future<List<ProjectTask>> tasks();
  Future<ProjectTask> task(int id);
  Future<ProjectTask> updateTask(int id, String status);
  Future<List<DailySiteReport>> reports();
  Future<DailySiteReport> report(int id);
  Future<DailySiteReport> submit(NewSiteReport report);
}

class ApiOperationService implements OperationService {
  ApiOperationService(this.client, {SyncOutbox? outbox})
    : outbox = outbox ?? SyncOutbox(client, PreferenceSyncStore());
  final ApiClient client;
  final SyncOutbox outbox;
  final Map<int, ProjectTask> _taskCache = {};
  @override
  Future<List<OperationProject>> reportProjects() async =>
      ((await client.get('/site-reports/project-options'))['data'] as List)
          .map(
            (item) => OperationProject.fromJson(item as Map<String, dynamic>),
          )
          .toList();

  @override
  Future<List<ProjectTask>> tasks() async {
    final values = ((await client.get('/tasks'))['data'] as List)
        .map((item) => ProjectTask.fromJson(item as Map<String, dynamic>))
        .toList();
    for (final item in values) {
      _taskCache[item.id] = item;
    }
    return values;
  }

  @override
  Future<ProjectTask> task(int id) async {
    try {
      final item = ProjectTask.fromJson(
        (await client.get('/tasks/$id'))['data'] as Map<String, dynamic>,
      );
      _taskCache[id] = item;
      return item;
    } on NetworkUnavailableException {
      final cached = _taskCache[id];
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<ProjectTask> updateTask(int id, String status) async {
    final response = await outbox.sendOrQueue('PATCH', '/tasks/$id', {
      'status': status,
    });
    if (response != null) {
      final item = ProjectTask.fromJson(
        response['data'] as Map<String, dynamic>,
      );
      _taskCache[id] = item;
      return item;
    }
    final cached = _taskCache[id];
    if (cached == null) throw const NetworkUnavailableException();
    final item = ProjectTask(
      id: cached.id,
      title: cached.title,
      description: cached.description,
      priority: cached.priority,
      status: status,
      dueAt: cached.dueAt,
      project: cached.project,
      assignee: cached.assignee,
    );
    _taskCache[id] = item;
    return item;
  }

  @override
  Future<List<DailySiteReport>> reports() async =>
      ((await client.get('/site-reports'))['data'] as List)
          .map((item) => DailySiteReport.fromJson(item as Map<String, dynamic>))
          .toList();
  @override
  Future<DailySiteReport> report(int id) async => DailySiteReport.fromJson(
    (await client.get('/site-reports/$id'))['data'] as Map<String, dynamic>,
  );
  @override
  Future<DailySiteReport> submit(NewSiteReport report) async {
    final response = await outbox.sendOrQueue(
      'POST',
      '/site-reports',
      report.toJson(),
    );
    if (response != null) {
      return DailySiteReport.fromJson(response['data'] as Map<String, dynamic>);
    }
    return DailySiteReport(
      id: -DateTime.now().millisecondsSinceEpoch,
      reportDate: report.reportDate,
      weather: report.weather,
      workersOnSite: report.workersOnSite,
      workCompleted: report.workCompleted,
      workPlanned: report.workPlanned,
      blockers: report.blockers,
      status: 'queued',
      project: OperationProject(
        id: report.projectId,
        name: 'Pending synchronisation',
        reference: 'OFFLINE',
      ),
      submittedBy: 'You',
    );
  }
}

class MockOperationService implements OperationService {
  NewSiteReport? lastSubmitted;
  ProjectTask sampleTask = ProjectTask(
    id: 1,
    title: 'Inspect first-floor columns',
    description:
        'Verify reinforcement spacing and photograph each completed column before concrete placement.',
    priority: 'urgent',
    status: 'assigned',
    dueAt: DateTime(2026, 8, 18, 15),
    project: const OperationProject(
      id: 71,
      name: 'Oak Residence',
      reference: 'STR-24001',
    ),
    assignee: 'Tunde Afolayan',
  );
  final sampleReport = DailySiteReport(
    id: 1,
    reportDate: DateTime(2026, 8, 17),
    weather: 'Clear',
    workersOnSite: 14,
    workCompleted: 'First-floor formwork completed and checked.',
    workPlanned: 'Begin reinforcement checks for concrete placement.',
    blockers: 'Two lintels remain outstanding.',
    status: 'submitted',
    project: const OperationProject(
      id: 71,
      name: 'Oak Residence',
      reference: 'STR-24001',
    ),
    submittedBy: 'Tunde Afolayan',
  );
  @override
  Future<List<OperationProject>> reportProjects() async => [sampleTask.project];
  @override
  Future<List<ProjectTask>> tasks() async => [sampleTask];
  @override
  Future<ProjectTask> task(int id) async => sampleTask;
  @override
  Future<ProjectTask> updateTask(int id, String status) async {
    sampleTask = ProjectTask(
      id: sampleTask.id,
      title: sampleTask.title,
      description: sampleTask.description,
      priority: sampleTask.priority,
      status: status,
      dueAt: sampleTask.dueAt,
      project: sampleTask.project,
      assignee: sampleTask.assignee,
    );
    return sampleTask;
  }

  @override
  Future<List<DailySiteReport>> reports() async => [sampleReport];
  @override
  Future<DailySiteReport> report(int id) async => sampleReport;
  @override
  Future<DailySiteReport> submit(NewSiteReport report) async {
    lastSubmitted = report;
    return sampleReport;
  }
}
