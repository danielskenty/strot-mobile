import '../network/api_client.dart';
import 'issue_models.dart';

abstract interface class IssueService {
  Future<List<ProjectIssue>> list();
  Future<ProjectIssue> get(int id);
  Future<ProjectIssue> create({
    required int projectId,
    required String category,
    required String priority,
    required String title,
    required String description,
  });
  Future<void> update({
    required int id,
    required String status,
    String? response,
    String? impactSummary,
    String? recoveryPlan,
    String? recoveryTargetOn,
    String? recoveryStatus,
    int? recoveryOwnerId,
  });
}

class ApiIssueService implements IssueService {
  const ApiIssueService(this.client);
  final ApiClient client;
  @override
  Future<List<ProjectIssue>> list() async =>
      ((await client.get('/issues'))['data'] as List)
          .map((item) => ProjectIssue.fromJson(item as Map<String, dynamic>))
          .toList();
  @override
  Future<ProjectIssue> get(int id) async => ProjectIssue.fromJson(
    (await client.get('/issues/$id'))['data'] as Map<String, dynamic>,
  );
  @override
  Future<ProjectIssue> create({
    required int projectId,
    required String category,
    required String priority,
    required String title,
    required String description,
  }) async => ProjectIssue.fromJson(
    (await client.post('/issues', {
          'project_id': projectId,
          'category': category,
          'priority': priority,
          'title': title,
          'description': description,
        }))['data']
        as Map<String, dynamic>,
  );
  @override
  Future<void> update({
    required int id,
    required String status,
    String? response,
    String? impactSummary,
    String? recoveryPlan,
    String? recoveryTargetOn,
    String? recoveryStatus,
    int? recoveryOwnerId,
  }) async {
    await client.patch('/issues/$id', {
      'status': status,
      'response': ?response,
      'impact_summary': ?impactSummary,
      'recovery_plan': ?recoveryPlan,
      'recovery_target_on': ?recoveryTargetOn,
      'recovery_status': ?recoveryStatus,
      'recovery_owner_id': ?recoveryOwnerId,
    });
  }
}

class MockIssueService implements IssueService {
  static final sample = ProjectIssue(
    id: 81,
    reference: 'ISS-260822-STROT',
    category: 'delay',
    priority: 'urgent',
    title: 'Joinery delivery delay',
    description:
        'The expected joinery delivery has not arrived on the agreed programme date.',
    status: 'resolved',
    response: 'The supplier was replaced and delivery is confirmed for Monday.',
    projectId: 71,
    projectName: 'Oak Residence',
    projectReference: 'STR-24001',
    createdBy: 'Adaeze Okafor',
    respondedBy: 'Amara Okoye',
    resolvedBy: 'Amara Okoye',
    impactSummary:
        'Joinery completion moved by four days without affecting handover.',
    recoveryPlan:
        'Use the replacement supplier, inspect on arrival and add a Saturday installation shift.',
    recoveryTargetOn: DateTime(2026, 8, 26),
    recoveryStatus: 'recovered',
    recoveryOwnerId: 4,
    recoveryOwner: 'Amara Okoye',
    createdAt: DateTime(2026, 8, 22, 10),
  );
  String? lastStatus,
      lastResponse,
      lastImpactSummary,
      lastRecoveryPlan,
      lastRecoveryTargetOn,
      lastRecoveryStatus;
  int? lastRecoveryOwnerId;
  int? createdProjectId;
  @override
  Future<List<ProjectIssue>> list() async => [sample];
  @override
  Future<ProjectIssue> get(int id) async => sample;
  @override
  Future<ProjectIssue> create({
    required int projectId,
    required String category,
    required String priority,
    required String title,
    required String description,
  }) async {
    createdProjectId = projectId;
    return sample;
  }

  @override
  Future<void> update({
    required int id,
    required String status,
    String? response,
    String? impactSummary,
    String? recoveryPlan,
    String? recoveryTargetOn,
    String? recoveryStatus,
    int? recoveryOwnerId,
  }) async {
    lastStatus = status;
    lastResponse = response;
    lastImpactSummary = impactSummary;
    lastRecoveryPlan = recoveryPlan;
    lastRecoveryTargetOn = recoveryTargetOn;
    lastRecoveryStatus = recoveryStatus;
    lastRecoveryOwnerId = recoveryOwnerId;
  }
}
