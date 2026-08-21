import '../network/api_client.dart';
import 'variation_models.dart';

abstract interface class VariationService {
  Future<List<ProjectVariation>> list();
  Future<void> decide({
    required int id,
    required String decision,
    String? note,
  });
}

class MockVariationService implements VariationService {
  static const items = [
    ProjectVariation(
      id: 1,
      reference: 'VAR-260821-A1B2C3',
      title: 'Foundation reinforcement',
      reason: 'Site conditions require additional reinforcement.',
      scopeDescription:
          'Supply and install the revised reinforcement schedule, including additional steel and supervised placement.',
      amountDeltaMinor: 250000000,
      currency: 'NGN',
      scheduleDeltaDays: 4,
      status: 'submitted',
      projectName: 'Oak Residence',
      projectReference: 'STR-24001',
    ),
    ProjectVariation(
      id: 2,
      reference: 'VAR-260812-D4E5F6',
      title: 'Joinery finish upgrade',
      reason: 'Client-selected material enhancement.',
      scopeDescription: 'Upgrade wardrobe fronts from laminate to oak veneer.',
      amountDeltaMinor: 85000000,
      currency: 'NGN',
      scheduleDeltaDays: 2,
      status: 'approved',
      projectName: 'Oak Residence',
      projectReference: 'STR-24001',
      decisionNote: 'Approved for the principal bedroom only.',
    ),
  ];
  @override
  Future<List<ProjectVariation>> list() async => items;
  @override
  Future<void> decide({
    required int id,
    required String decision,
    String? note,
  }) async {}
}

class ApiVariationService implements VariationService {
  ApiVariationService(this.client);
  final ApiClient client;
  @override
  Future<List<ProjectVariation>> list() async {
    final response = await client.get('/variations');
    return (response['data'] as List<dynamic>)
        .map((raw) => _fromJson(raw as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> decide({
    required int id,
    required String decision,
    String? note,
  }) => client.patch('/variations/$id/decision', {
    'decision': decision,
    'note': note,
  });
  ProjectVariation _fromJson(Map<String, dynamic> value) {
    final project = value['project'] as Map<String, dynamic>;
    return ProjectVariation(
      id: value['id'] as int,
      reference: value['reference'] as String,
      title: value['title'] as String,
      reason: value['reason'] as String,
      scopeDescription: value['scope_description'] as String,
      amountDeltaMinor: value['amount_delta_minor'] as int,
      currency: value['currency'] as String,
      scheduleDeltaDays: value['schedule_delta_days'] as int,
      status: value['status'] as String,
      projectName: project['name'] as String,
      projectReference: project['reference'] as String,
      decisionNote: value['decision_note'] as String?,
    );
  }
}
