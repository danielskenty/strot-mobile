import 'approval_models.dart';
import '../network/api_client.dart';

abstract interface class ApprovalService {
  Future<List<StrotApproval>> list();
  Future<void> decide({
    required int id,
    required ApprovalStatus decision,
    String? note,
  });
}

class MockApprovalService implements ApprovalService {
  static final items = [
    StrotApproval(
      id: 1,
      title: 'Scope of Work',
      description:
          'Review the revised scope, responsibilities, material allowances and delivery sequence before work proceeds.',
      version: '2.1',
      projectName: 'Oak Residence',
      projectReference: 'STR-24001',
      dueAt: DateTime(2026, 8, 21),
    ),
    StrotApproval(
      id: 2,
      title: 'Kitchen material selection',
      description:
          'Confirm the proposed stone finish and joinery specification.',
      version: '1.0',
      projectName: 'Oak Residence',
      projectReference: 'STR-24001',
      dueAt: DateTime(2026, 8, 24),
    ),
  ];
  @override
  Future<List<StrotApproval>> list() async => items;
  @override
  Future<void> decide({
    required int id,
    required ApprovalStatus decision,
    String? note,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }
}

class ApiApprovalService implements ApprovalService {
  ApiApprovalService(this.client);
  final ApiClient client;

  @override
  Future<List<StrotApproval>> list() async {
    final response = await client.get('/approvals');
    return (response['data'] as List<dynamic>).map((item) {
      final value = item as Map<String, dynamic>;
      final project = value['project'] as Map<String, dynamic>;
      return StrotApproval(
        id: value['id'] as int,
        title: value['title'] as String,
        description: value['description'] as String? ?? '',
        version: value['version'] as String? ?? '1.0',
        projectName: project['name'] as String,
        projectReference: project['reference'] as String,
        dueAt: value['due_at'] == null
            ? DateTime.now()
            : DateTime.parse(value['due_at'] as String),
        status: _status(value['status'] as String),
      );
    }).toList();
  }

  @override
  Future<void> decide({
    required int id,
    required ApprovalStatus decision,
    String? note,
  }) async {
    await client.put('/approvals/$id', {
      'decision': decision == ApprovalStatus.changesRequested
          ? 'changes_requested'
          : 'approved',
      'note': note,
    });
  }

  ApprovalStatus _status(String value) => switch (value) {
    'approved' => ApprovalStatus.approved,
    'changes_requested' => ApprovalStatus.changesRequested,
    _ => ApprovalStatus.pending,
  };
}
