import '../network/api_client.dart';
import 'property_access_models.dart';

abstract interface class PropertyAccessService {
  Future<List<PropertyAccessRecord>> list();
  Future<PropertyAccessRecord> create({
    required int propertyId,
    required String type,
    required String name,
    String? relationship,
    String? email,
    String? phone,
    required bool emergencyContact,
    required List<String> authorizedAreas,
    String? accessStartsAt,
    String? accessEndsAt,
  });
  Future<void> revoke(int id);
}

class ApiPropertyAccessService implements PropertyAccessService {
  const ApiPropertyAccessService(this.client);
  final ApiClient client;
  @override
  Future<List<PropertyAccessRecord>> list() async =>
      ((await client.get('/property-access'))['data'] as List)
          .map(
            (item) =>
                PropertyAccessRecord.fromJson(item as Map<String, dynamic>),
          )
          .toList();
  @override
  Future<PropertyAccessRecord> create({
    required int propertyId,
    required String type,
    required String name,
    String? relationship,
    String? email,
    String? phone,
    required bool emergencyContact,
    required List<String> authorizedAreas,
    String? accessStartsAt,
    String? accessEndsAt,
  }) async => PropertyAccessRecord.fromJson(
    (await client.post('/property-access', {
          'property_id': propertyId,
          'type': type,
          'name': name,
          'relationship': ?relationship,
          'email': ?email,
          'phone': ?phone,
          'emergency_contact': emergencyContact,
          'authorized_areas': authorizedAreas,
          'access_starts_at': ?accessStartsAt,
          'access_ends_at': ?accessEndsAt,
        }))['data']
        as Map<String, dynamic>,
  );
  @override
  Future<void> revoke(int id) async {
    await client.patch('/property-access/$id/revoke', {});
  }
}

class MockPropertyAccessService implements PropertyAccessService {
  int? createdPropertyId, revokedId;
  static const sample = PropertyAccessRecord(
    id: 1,
    type: 'household',
    name: 'Kelechi Obi',
    relationship: 'Family',
    email: 'kelechi@example.com',
    phone: '+234 800 000 0000',
    emergencyContact: true,
    authorizedAreas: ['Residence', 'Property care'],
    status: 'active',
    propertyId: 1,
    propertyName: 'Oak Residence',
    propertyReference: 'PROP-OAK01',
    createdBy: 'Adaeze Okafor',
  );
  @override
  Future<List<PropertyAccessRecord>> list() async => const [sample];
  @override
  Future<PropertyAccessRecord> create({
    required int propertyId,
    required String type,
    required String name,
    String? relationship,
    String? email,
    String? phone,
    required bool emergencyContact,
    required List<String> authorizedAreas,
    String? accessStartsAt,
    String? accessEndsAt,
  }) async {
    createdPropertyId = propertyId;
    return sample;
  }

  @override
  Future<void> revoke(int id) async {
    revokedId = id;
  }
}
