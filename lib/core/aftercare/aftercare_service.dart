import '../network/api_client.dart';

class AftercareRecord {
  const AftercareRecord({
    required this.packs,
    required this.warranties,
    required this.defects,
  });
  final List<Map<String, dynamic>> packs, warranties, defects;
}

abstract interface class AftercareService {
  Future<AftercareRecord> list();
}

class ApiAftercareService implements AftercareService {
  ApiAftercareService(this.client);
  final ApiClient client;
  @override
  Future<AftercareRecord> list() async {
    final data =
        (await client.get('/aftercare'))['data'] as Map<String, dynamic>;
    List<Map<String, dynamic>> rows(String key) => (data[key] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    return AftercareRecord(
      packs: rows('handover_packs'),
      warranties: rows('warranties'),
      defects: rows('defects'),
    );
  }
}

class MockAftercareService implements AftercareService {
  @override
  Future<AftercareRecord> list() async => const AftercareRecord(
    packs: [
      {'reference': 'HND-260821-OAK', 'status': 'issued'},
    ],
    warranties: [
      {
        'title': 'Structural workmanship',
        'provider': 'STROT Delivery',
        'expires_on': '2027-08-01',
        'status': 'active',
      },
    ],
    defects: [
      {
        'reference': 'DEF-260821-A1B2C',
        'title': 'Door alignment',
        'status': 'acknowledged',
      },
    ],
  );
}
