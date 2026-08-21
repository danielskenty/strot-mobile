import '../network/api_client.dart';

class CareRequest {
  const CareRequest({
    required this.id,
    required this.reference,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.scheduledAt,
    this.visits = const [],
  });
  final int id;
  final String reference, title, description, priority, status;
  final DateTime? scheduledAt;
  final List<CareVisit> visits;
}

class CareVisit {
  const CareVisit({
    required this.id,
    required this.status,
    required this.checklist,
  });
  final int id;
  final String status;
  final List<CareChecklistItem> checklist;
}

class CareChecklistItem {
  const CareChecklistItem({required this.label, required this.complete});
  final String label;
  final bool complete;
}

class CareProperty {
  const CareProperty({
    required this.id,
    required this.name,
    required this.location,
    required this.requests,
  });
  final int id;
  final String name, location;
  final List<CareRequest> requests;
}

abstract interface class PropertyCareService {
  Future<List<CareProperty>> list();
  Future<void> request({
    required int propertyId,
    required String title,
    required String description,
    required String category,
    required String priority,
  });
  Future<void> updateVisit({
    required int visitId,
    required String action,
    List<CareChecklistItem>? checklist,
    String? resolutionNote,
  });
}

class MockPropertyCareService implements PropertyCareService {
  @override
  Future<List<CareProperty>> list() async => [
    CareProperty(
      id: 1,
      name: 'Oak Residence',
      location: 'Ikoyi, Lagos',
      requests: [
        CareRequest(
          id: 1,
          reference: 'MNT-260821-A1B2C',
          title: 'Air-conditioning service',
          description: 'Reduced cooling in the principal bedroom.',
          priority: 'action required',
          status: 'scheduled',
          scheduledAt: DateTime(2026, 8, 24, 9),
          visits: const [
            CareVisit(
              id: 1,
              status: 'scheduled',
              checklist: [
                CareChecklistItem(label: 'Inspect filters', complete: false),
                CareChecklistItem(
                  label: 'Test cooling output',
                  complete: false,
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];
  @override
  Future<void> request({
    required int propertyId,
    required String title,
    required String description,
    required String category,
    required String priority,
  }) async {}
  @override
  Future<void> updateVisit({
    required int visitId,
    required String action,
    List<CareChecklistItem>? checklist,
    String? resolutionNote,
  }) async {}
}

class ApiPropertyCareService implements PropertyCareService {
  ApiPropertyCareService(this.client);
  final ApiClient client;
  @override
  Future<List<CareProperty>> list() async {
    final body = await client.get('/property-care');
    return (body['data'] as List).map((raw) {
      final p = raw as Map<String, dynamic>;
      return CareProperty(
        id: p['id'] as int,
        name: p['name'] as String,
        location: p['location'] as String,
        requests: (p['requests'] as List).map((value) {
          final r = value as Map<String, dynamic>;
          return CareRequest(
            id: r['id'] as int,
            reference: r['reference'] as String,
            title: r['title'] as String,
            description: r['description'] as String,
            priority: (r['priority'] as String).replaceAll('_', ' '),
            status: r['status'] as String,
            scheduledAt: r['scheduled_at'] == null
                ? null
                : DateTime.parse(r['scheduled_at'] as String),
            visits: ((r['visits'] as List?) ?? const []).map((value) {
              final visit = value as Map<String, dynamic>;
              return CareVisit(
                id: visit['id'] as int,
                status: visit['status'] as String,
                checklist: ((visit['checklist'] as List?) ?? const []).map((
                  value,
                ) {
                  final item = value as Map<String, dynamic>;
                  return CareChecklistItem(
                    label: item['label'] as String? ?? 'Checklist item',
                    complete: item['complete'] as bool? ?? false,
                  );
                }).toList(),
              );
            }).toList(),
          );
        }).toList(),
      );
    }).toList();
  }

  @override
  Future<void> request({
    required int propertyId,
    required String title,
    required String description,
    required String category,
    required String priority,
  }) async {
    await client.post('/maintenance-requests', {
      'property_id': propertyId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
    });
  }

  @override
  Future<void> updateVisit({
    required int visitId,
    required String action,
    List<CareChecklistItem>? checklist,
    String? resolutionNote,
  }) async {
    await client.patch('/maintenance-visits/$visitId', {
      'action': action,
      if (checklist != null)
        'checklist': checklist
            .map((item) => {'label': item.label, 'complete': item.complete})
            .toList(),
      ...resolutionNote == null
          ? const <String, dynamic>{}
          : {'resolution_note': resolutionNote},
    });
  }
}
