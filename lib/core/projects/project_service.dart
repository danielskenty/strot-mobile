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
      approvedTotalMinor: 48000000,
      milestoneProgress: 50,
    ),
    milestones: [
      const ProjectMilestone(
        id: 1,
        title: 'Consultation & brief',
        status: 'complete',
        ownerLabel: 'STROT Advisory',
        requirements: [
          MilestoneRequirement(
            key: 'brief',
            label: 'Client brief accepted',
            complete: true,
          ),
        ],
      ),
      const ProjectMilestone(
        id: 2,
        title: 'Site verification',
        status: 'complete',
        ownerLabel: 'STROT Operations',
        requirements: [
          MilestoneRequirement(
            key: 'evidence',
            label: 'Site evidence verified',
            complete: true,
          ),
        ],
      ),
      ProjectMilestone(
        id: 3,
        title: 'Scope & approvals',
        status: 'active',
        description: 'Resolve the decisions required before work commencement.',
        ownerLabel: 'Client & STROT',
        dueAt: DateTime(2026, 8, 21),
        requirements: const [
          MilestoneRequirement(
            key: 'scope',
            label: 'Final scope approved',
            complete: true,
          ),
          MilestoneRequirement(
            key: 'deposit',
            label: 'Commencement deposit received',
            complete: false,
          ),
          MilestoneRequirement(
            key: 'drawings',
            label: 'Construction drawings verified',
            complete: true,
          ),
        ],
      ),
      const ProjectMilestone(
        id: 4,
        title: 'Delivery',
        status: 'upcoming',
        ownerLabel: 'STROT Delivery',
        requirements: [
          MilestoneRequirement(
            key: 'prior',
            label: 'Scope and approvals complete',
            complete: false,
          ),
        ],
      ),
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
        approvedTotalMinor: summary['approved_total_minor'] as int? ?? 0,
        milestoneProgress: summary['milestone_progress'] as int? ?? 0,
      ),
      milestones: milestones.map((item) {
        final value = item as Map<String, dynamic>;
        return ProjectMilestone(
          id: value['id'] as int,
          title: value['title'] as String,
          status: value['status'] as String,
          description: value['description'] as String?,
          ownerLabel: value['owner_label'] as String?,
          dueAt: value['due_at'] == null
              ? null
              : DateTime.parse(value['due_at'] as String),
          completedAt: value['completed_at'] == null
              ? null
              : DateTime.parse(value['completed_at'] as String),
          completionNote: value['completion_note'] as String?,
          requirements: ((value['requirements'] as List<dynamic>?) ?? []).map((
            entry,
          ) {
            final requirement = entry as Map<String, dynamic>;
            return MilestoneRequirement(
              key: requirement['key'] as String,
              label: requirement['label'] as String,
              complete: requirement['complete'] as bool? ?? false,
              deepLink: requirement['deep_link'] as String?,
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
