import '../network/api_client.dart';
import 'project_journal_models.dart';

abstract interface class ProjectJournalService {
  Future<ProjectJournal> get({int? projectId});
}

class ApiProjectJournalService implements ProjectJournalService {
  const ApiProjectJournalService(this.client);
  final ApiClient client;
  @override
  Future<ProjectJournal> get({int? projectId}) async {
    final suffix = projectId == null ? '' : '?project_id=$projectId';
    return ProjectJournal.fromJson(
      (await client.get('/project-journal$suffix'))['data']
          as Map<String, dynamic>,
    );
  }
}

class MockProjectJournalService implements ProjectJournalService {
  int? lastProjectId;
  static const project = ProjectJournalProject(
    id: 1,
    name: 'Oak Residence',
    reference: 'STR-24001',
  );
  @override
  Future<ProjectJournal> get({int? projectId}) async {
    lastProjectId = projectId;
    return ProjectJournal(
      projects: const [project],
      summary: const ProjectJournalSummary(
        total: 3,
        certified: 2,
        siteUpdates: 1,
        inspections: 1,
      ),
      entries: [
        ProjectJournalEntry(
          id: 'site-report-12',
          type: 'site_report',
          title: 'Daily site update',
          summary:
              'Ground-floor wall finishes completed and joinery setting-out verified.',
          status: 'submitted',
          occurredAt: DateTime(2026, 8, 22, 16),
          project: project,
          deepLink: '/portal/site-reports/12',
          certified: false,
          secondary: 'No active blockers.',
          actor: 'Chidi Eze',
        ),
        ProjectJournalEntry(
          id: 'inspection-8',
          type: 'inspection',
          title: 'Interior finishes hold point',
          summary:
              'Completed work was inspected against the approved material schedule.',
          status: 'approved',
          occurredAt: DateTime(2026, 8, 21, 13),
          project: project,
          deepLink: '/portal/inspections/8',
          certified: true,
          secondary: 'Accepted for continuation.',
          actor: 'Amara Okoye',
        ),
      ],
    );
  }
}
