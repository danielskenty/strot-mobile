import '../network/api_client.dart';
import 'consultation_models.dart';

abstract interface class ConsultationService {
  Future<List<ClientConsultation>> list();
  Future<ClientConsultation> get(int id);
  Future<void> act({
    required int id,
    required String action,
    required String note,
    String? preferredDate,
  });
}

class ApiConsultationService implements ConsultationService {
  const ApiConsultationService(this.client);
  final ApiClient client;

  @override
  Future<List<ClientConsultation>> list() async =>
      ((await client.get('/client/consultations'))['data'] as List)
          .map(
            (item) => ClientConsultation.fromJson(item as Map<String, dynamic>),
          )
          .toList();

  @override
  Future<ClientConsultation> get(int id) async => ClientConsultation.fromJson(
    (await client.get('/client/consultations/$id'))['data']
        as Map<String, dynamic>,
  );

  @override
  Future<void> act({
    required int id,
    required String action,
    required String note,
    String? preferredDate,
  }) async {
    await client.patch('/client/consultations/$id/action', {
      'action': action,
      'note': note,
      'preferred_date': preferredDate,
    });
  }
}

class MockConsultationService implements ConsultationService {
  static final sample = ClientConsultation(
    id: 37,
    reference: 'CON-260822-STROT',
    service: 'renovation',
    propertyType: 'Private residence',
    location: 'Lekki, Lagos',
    brief:
        'A structured renovation consultation covering scope, programme and accountable delivery.',
    status: 'confirmed',
    preferredDate: '2026-08-29',
    scheduledAt: DateTime(2026, 8, 29, 10),
    meetingUrl: 'https://meet.example.test/strot-consultation',
    advisorName: 'Amara Okoye',
    createdAt: DateTime(2026, 8, 22, 9),
  );
  String? lastAction, lastNote, lastPreferredDate;

  @override
  Future<List<ClientConsultation>> list() async => [sample];
  @override
  Future<ClientConsultation> get(int id) async => sample;
  @override
  Future<void> act({
    required int id,
    required String action,
    required String note,
    String? preferredDate,
  }) async {
    lastAction = action;
    lastNote = note;
    lastPreferredDate = preferredDate;
  }
}
