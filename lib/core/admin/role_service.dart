import '../network/api_client.dart';

class AdminRole {
  const AdminRole({
    required this.id,
    required this.key,
    required this.name,
    required this.assignments,
    required this.permissions,
  });
  final int id, assignments;
  final String key, name;
  final Map<String, List<Map<String, dynamic>>> permissions;
  factory AdminRole.fromJson(Map<String, dynamic> json) => AdminRole(
    id: json['id'] as int,
    key: json['key'] as String,
    name: json['name'] as String,
    assignments: json['assignments_count'] as int,
    permissions: (json['permission_groups'] as Map).map(
      (key, value) => MapEntry(
        key.toString(),
        (value as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList(),
      ),
    ),
  );
}

abstract interface class AdminRoleService {
  Future<List<AdminRole>> list();
  Future<AdminRole> get(int id);
}

class ApiAdminRoleService implements AdminRoleService {
  ApiAdminRoleService(this.client);
  final ApiClient client;
  @override
  Future<List<AdminRole>> list() async =>
      ((await client.get('/admin/roles'))['data'] as List)
          .map(
            (item) =>
                AdminRole.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
  @override
  Future<AdminRole> get(int id) async => AdminRole.fromJson(
    Map<String, dynamic>.from(
      (await client.get('/admin/roles/$id'))['data'] as Map,
    ),
  );
}

class MockAdminRoleService implements AdminRoleService {
  static const role = AdminRole(
    id: 1,
    key: 'client',
    name: 'Client',
    assignments: 12,
    permissions: {
      'projects': [
        {'key': 'projects.view', 'name': 'Projects View'},
      ],
      'documents': [
        {'key': 'documents.view', 'name': 'Documents View'},
      ],
    },
  );
  @override
  Future<List<AdminRole>> list() async => const [role];
  @override
  Future<AdminRole> get(int id) async => role;
}
