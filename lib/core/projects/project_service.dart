import 'project_models.dart';
import '../network/api_client.dart';

abstract interface class ProjectService {
  Future<List<StrotProject>> list();
  Future<StrotProject> get(int id);
}

class MockProjectService implements ProjectService {
  static final project = StrotProject(
    id: 1,
    name: 'Oak Residence',
    reference: 'STR-24001',
    status: 'active',
    type: 'Residential development',
    location: 'Lekki, Lagos',
    summary: const ProjectSummary(
      paidMinor: 25000000,
      currency: 'NGN',
      pendingApprovals: 2,
      evidenceProgress: 68,
    ),
    milestones: [
      const ProjectMilestone(title: 'Consultation & brief', status: 'complete'),
      const ProjectMilestone(title: 'Site verification', status: 'complete'),
      ProjectMilestone(
        title: 'Scope & approvals',
        status: 'active',
        dueAt: DateTime(2026, 8, 21),
      ),
      const ProjectMilestone(title: 'Delivery', status: 'upcoming'),
    ],
  );
  @override
  Future<StrotProject> get(int id) async => project;
  @override
  Future<List<StrotProject>> list() async => [project];
}

class ApiProjectService implements ProjectService {
  ApiProjectService(this.client);
  final ApiClient client;

  @override
  Future<List<StrotProject>> list() async {
    final response = await client.get('/projects');
    return (response['data'] as List<dynamic>)
        .map((item) => _project(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<StrotProject> get(int id) async {
    final response = await client.get('/projects/$id');
    return _project(response['data'] as Map<String, dynamic>);
  }

  StrotProject _project(Map<String, dynamic> json) {
    final property = json['property'] as Map<String, dynamic>? ?? {};
    final summary = json['summary'] as Map<String, dynamic>;
    final milestones = json['milestones'] as List<dynamic>? ?? [];
    return StrotProject(
      id: json['id'] as int,
      name: json['name'] as String,
      reference: json['reference'] as String,
      status: json['status'] as String,
      type: property['type'] as String? ?? 'Property engagement',
      location: property['location'] as String? ?? 'Location restricted',
      summary: ProjectSummary(
        paidMinor: summary['paid_minor'] as int,
        currency: summary['currency'] as String,
        pendingApprovals: summary['pending_approvals'] as int,
        evidenceProgress: summary['evidence_progress'] as int,
      ),
      milestones: milestones.map((item) {
        final value = item as Map<String, dynamic>;
        return ProjectMilestone(
          title: value['title'] as String,
          status: value['status'] as String,
          dueAt: value['due_at'] == null
              ? null
              : DateTime.parse(value['due_at'] as String),
        );
      }).toList(),
    );
  }
}
