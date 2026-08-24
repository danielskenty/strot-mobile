import '../network/api_client.dart';

class AdminOrganization {
  const AdminOrganization({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.members,
    required this.projects,
    required this.properties,
  });
  final int id;
  final String name, type, status;
  final List<Map<String, dynamic>> members, projects, properties;
  factory AdminOrganization.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> rows(String key) => (json[key] as List? ?? [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    return AdminOrganization(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      members: rows('members'),
      projects: rows('client_projects'),
      properties: rows('properties'),
    );
  }
}

abstract interface class AdminOrganizationService {
  Future<List<AdminOrganization>> list();
  Future<AdminOrganization> get(int id);
}

class ApiAdminOrganizationService implements AdminOrganizationService {
  ApiAdminOrganizationService(this.client);
  final ApiClient client;
  @override
  Future<List<AdminOrganization>> list() async =>
      ((await client.get('/admin/organizations'))['data'] as List)
          .map(
            (item) => AdminOrganization.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
  @override
  Future<AdminOrganization> get(int id) async => AdminOrganization.fromJson(
    Map<String, dynamic>.from(
      (await client.get('/admin/organizations/$id'))['data'] as Map,
    ),
  );
}

class MockAdminOrganizationService implements AdminOrganizationService {
  static const item = AdminOrganization(
    id: 1,
    name: 'Oak Family',
    type: 'client',
    status: 'active',
    members: [
      {'name': 'Ada Client', 'email': 'ada@example.com', 'role': 'client'},
    ],
    projects: [
      {'name': 'Oak Residence', 'reference': 'STR-24001'},
    ],
    properties: [
      {'name': 'Oak Residence', 'reference': 'PROP-OAK01'},
    ],
  );
  @override
  Future<List<AdminOrganization>> list() async => const [item];
  @override
  Future<AdminOrganization> get(int id) async => item;
}
