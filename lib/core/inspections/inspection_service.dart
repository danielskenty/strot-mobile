import '../network/api_client.dart';
import 'inspection_models.dart';

abstract interface class InspectionService {
  Future<List<SiteInspection>> list();
  Future<void> start(int id);
  Future<void> review(int id, String decision, String? note);
}

class MockInspectionService implements InspectionService {
  static final items = [
    SiteInspection(
      id: 1,
      reference: 'INS-260821-A1B2C3',
      title: 'Foundation reinforcement inspection',
      location: 'Foundation grid A–D',
      scheduledAt: DateTime(2026, 8, 22, 9),
      status: 'submitted',
      projectName: 'Oak Residence',
      projectReference: 'STR-24001',
      assigneeName: 'Tunde Afolayan',
      instructions: 'Verify reinforcement spacing before concrete placement.',
      findings:
          'Installed reinforcement conforms to the issued structural revision.',
      checklist: [
        InspectionCheck(
          key: 'spacing',
          label: 'Reinforcement spacing verified',
          complete: true,
          note: 'Measured at 200 mm centres.',
        ),
        InspectionCheck(
          key: 'cover',
          label: 'Concrete cover blocks confirmed',
          complete: true,
          note: '50 mm cover confirmed.',
        ),
      ],
      evidenceNames: ['foundation-grid-a.jpg', 'reinforcement-spacing.jpg'],
    ),
  ];
  @override
  Future<List<SiteInspection>> list() async => items;
  @override
  Future<void> start(int id) async {}
  @override
  Future<void> review(int id, String decision, String? note) async {}
}

class ApiInspectionService implements InspectionService {
  ApiInspectionService(this.client);
  final ApiClient client;
  @override
  Future<List<SiteInspection>> list() async {
    final result = await client.get('/inspections');
    return (result['data'] as List<dynamic>)
        .map((raw) => _parse(raw as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> start(int id) async {
    await client.post('/inspections/$id/start', {});
  }

  @override
  Future<void> review(int id, String decision, String? note) async {
    await client.patch('/inspections/$id/review', {
      'decision': decision,
      'note': note,
    });
  }

  SiteInspection _parse(Map<String, dynamic> v) {
    final project = v['project'] as Map<String, dynamic>;
    final assignee = v['assignee'] as Map<String, dynamic>;
    return SiteInspection(
      id: v['id'] as int,
      reference: v['reference'] as String,
      title: v['title'] as String,
      location: v['location'] as String,
      scheduledAt: DateTime.parse(v['scheduled_at'] as String),
      status: v['status'] as String,
      projectName: project['name'] as String,
      projectReference: project['reference'] as String,
      assigneeName: assignee['name'] as String,
      instructions: v['instructions'] as String?,
      findings: v['findings'] as String?,
      reviewNote: v['review_note'] as String?,
      checklist: (v['checklist'] as List<dynamic>).map((raw) {
        final item = raw as Map<String, dynamic>;
        return InspectionCheck(
          key: item['key'] as String,
          label: item['label'] as String,
          complete: item['complete'] as bool? ?? false,
          note: item['note'] as String?,
        );
      }).toList(),
      evidenceNames: (v['evidence'] as List<dynamic>? ?? [])
          .map(
            (raw) => (raw as Map<String, dynamic>)['original_name'] as String,
          )
          .toList(),
    );
  }
}
