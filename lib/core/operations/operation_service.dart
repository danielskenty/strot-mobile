import '../network/api_client.dart';
import 'operation_models.dart';

abstract interface class OperationService {
  Future<List<ProjectTask>> tasks();
  Future<ProjectTask> task(int id);
  Future<ProjectTask> updateTask(int id, String status);
  Future<List<DailySiteReport>> reports();
  Future<DailySiteReport> report(int id);
  Future<DailySiteReport> submit(NewSiteReport report);
}

class ApiOperationService implements OperationService {
  ApiOperationService(this.client);
  final ApiClient client;
  @override
  Future<List<ProjectTask>> tasks() async =>
      ((await client.get('/tasks'))['data'] as List)
          .map((item) => ProjectTask.fromJson(item as Map<String, dynamic>))
          .toList();
  @override
  Future<ProjectTask> task(int id) async => ProjectTask.fromJson(
    (await client.get('/tasks/$id'))['data'] as Map<String, dynamic>,
  );
  @override
  Future<ProjectTask> updateTask(int id, String status) async =>
      ProjectTask.fromJson(
        (await client.patch('/tasks/$id', {'status': status}))['data']
            as Map<String, dynamic>,
      );
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
  Future<DailySiteReport> submit(NewSiteReport report) async =>
      DailySiteReport.fromJson(
        (await client.post('/site-reports', report.toJson()))['data']
            as Map<String, dynamic>,
      );
}

class MockOperationService implements OperationService {
  ProjectTask sampleTask = ProjectTask(
    id: 1,
    title: 'Inspect first-floor columns',
    description:
        'Verify reinforcement spacing and photograph each completed column before concrete placement.',
    priority: 'urgent',
    status: 'assigned',
    dueAt: DateTime(2026, 8, 18, 15),
    project: const OperationProject(
      id: 1,
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
      id: 1,
      name: 'Oak Residence',
      reference: 'STR-24001',
    ),
    submittedBy: 'Tunde Afolayan',
  );
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
  Future<DailySiteReport> submit(NewSiteReport report) async => sampleReport;
}
