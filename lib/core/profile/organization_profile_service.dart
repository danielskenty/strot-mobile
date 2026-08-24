import '../network/api_client.dart';

class OrganizationProfileRecord {
  const OrganizationProfileRecord({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.country,
    this.legalName,
    this.registrationNumber,
    this.email,
    this.phone,
    this.website,
    this.address,
    this.city,
  });
  final int id;
  final String name, type, status, country;
  final String? legalName,
      registrationNumber,
      email,
      phone,
      website,
      address,
      city;
  factory OrganizationProfileRecord.fromJson(Map<String, dynamic> json) =>
      OrganizationProfileRecord(
        id: json['id'] as int,
        name: json['name'] as String,
        type: json['type'] as String,
        status: json['status'] as String,
        country: json['country'] as String,
        legalName: json['legal_name'] as String?,
        registrationNumber: json['registration_number'] as String?,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        website: json['website'] as String?,
        address: json['address'] as String?,
        city: json['city'] as String?,
      );
  Map<String, dynamic> toJson() => {
    'name': name,
    'legal_name': legalName,
    'registration_number': registrationNumber,
    'email': email,
    'phone': phone,
    'website': website,
    'address': address,
    'city': city,
    'country': country,
  };
}

abstract interface class OrganizationProfileService {
  Future<List<OrganizationProfileRecord>> list();
  Future<void> update(OrganizationProfileRecord item);
}

class ApiOrganizationProfileService implements OrganizationProfileService {
  const ApiOrganizationProfileService(this.client);
  final ApiClient client;
  @override
  Future<List<OrganizationProfileRecord>> list() async =>
      ((await client.get('/organization-profile'))['data'] as List)
          .map(
            (x) =>
                OrganizationProfileRecord.fromJson(x as Map<String, dynamic>),
          )
          .toList();
  @override
  Future<void> update(OrganizationProfileRecord item) =>
      client.patch('/organization-profile/${item.id}', item.toJson());
}

class MockOrganizationProfileService implements OrganizationProfileService {
  @override
  Future<List<OrganizationProfileRecord>> list() async => [
    const OrganizationProfileRecord(
      id: 1,
      name: 'Oak Residence',
      legalName: 'Oak Residence Limited',
      registrationNumber: 'RC 123456',
      email: 'office@example.com',
      phone: '+2348012345678',
      website: 'https://example.com',
      address: '12 Marina Road',
      city: 'Lagos',
      country: 'NG',
      type: 'client',
      status: 'active',
    ),
  ];
  @override
  Future<void> update(OrganizationProfileRecord item) async {}
}
