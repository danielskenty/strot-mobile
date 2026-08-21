import '../network/api_client.dart';

class PartnerAssignment {
  const PartnerAssignment({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.projectReference,
  });
  final int id;
  final String title, description, status, projectReference;
  factory PartnerAssignment.fromJson(Map<String, dynamic> json) {
    final project = json['project'] as Map<String, dynamic>?;
    return PartnerAssignment(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      projectReference: project?['reference'] as String? ?? 'Unassigned',
    );
  }
}

abstract interface class PartnerAssignmentService {
  Future<List<PartnerAssignment>> list();
  Future<void> respond(int id, String decision, {String? note});
}

class ApiPartnerAssignmentService implements PartnerAssignmentService {
  ApiPartnerAssignmentService(this.client);
  final ApiClient client;
  @override
  Future<List<PartnerAssignment>> list() async =>
      ((await client.get('/partner/work-orders'))['data'] as List)
          .map(
            (item) => PartnerAssignment.fromJson(item as Map<String, dynamic>),
          )
          .toList();
  @override
  Future<void> respond(int id, String decision, {String? note}) async =>
      client.post('/partner/work-orders/$id/response', {
        'decision': decision,
        'note': ?note,
      });
}

class MockPartnerAssignmentService implements PartnerAssignmentService {
  @override
  Future<List<PartnerAssignment>> list() async => const [
    PartnerAssignment(
      id: 1,
      title: 'Structural blockwork',
      description: 'Complete blockwork to approved drawings.',
      status: 'assignment_pending',
      projectReference: 'STR-24001',
    ),
  ];
  @override
  Future<void> respond(int id, String decision, {String? note}) async {}
}
