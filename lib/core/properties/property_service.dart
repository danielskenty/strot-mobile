import '../network/api_client.dart';

class PropertyRecord {
  const PropertyRecord({
    required this.id,
    required this.name,
    required this.reference,
    required this.address,
    required this.location,
    required this.status,
    required this.assets,
    required this.plans,
    required this.requests,
  });
  final int id;
  final String name, reference, address, location, status;
  final List<Map<String, dynamic>> assets, plans, requests;
  factory PropertyRecord.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> rows(String key) => (json[key] as List? ?? [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    return PropertyRecord(
      id: json['id'] as int,
      name: json['name'] as String,
      reference: json['reference'] as String,
      address: json['address'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
      assets: rows('assets'),
      plans: rows('plans'),
      requests: rows('requests'),
    );
  }
}

abstract interface class PropertyService {
  Future<List<PropertyRecord>> list();
  Future<PropertyRecord> get(int id);
}

class ApiPropertyService implements PropertyService {
  ApiPropertyService(this.client);
  final ApiClient client;
  @override
  Future<List<PropertyRecord>> list() async =>
      ((await client.get('/properties'))['data'] as List)
          .map(
            (item) =>
                PropertyRecord.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
  @override
  Future<PropertyRecord> get(int id) async => PropertyRecord.fromJson(
    Map<String, dynamic>.from(
      (await client.get('/properties/$id'))['data'] as Map,
    ),
  );
}

class MockPropertyService implements PropertyService {
  static const record = PropertyRecord(
    id: 1,
    name: 'Oak Residence',
    reference: 'PROP-OAK01',
    address: '12 Alexander Road',
    location: 'Ikoyi, Lagos',
    status: 'active',
    assets: [
      {'name': 'Central air-conditioning', 'status': 'operational'},
    ],
    plans: [
      {'name': 'Essential Property Care', 'next_service_on': '2026-09-15'},
    ],
    requests: [
      {'title': 'Air-conditioning service', 'status': 'scheduled'},
    ],
  );
  @override
  Future<List<PropertyRecord>> list() async => const [record];
  @override
  Future<PropertyRecord> get(int id) async => record;
}
