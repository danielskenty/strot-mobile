import '../network/api_client.dart';

class AdminUserRecord {
  const AdminUserRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.verified,
    required this.twoFactor,
    required this.sessions,
    required this.organizations,
    required this.roles,
    this.activity = const [],
  });
  final int id, sessions;
  final String name, email;
  final bool verified, twoFactor;
  final List<Map<String, dynamic>> organizations, roles, activity;
  factory AdminUserRecord.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> rows(String key) => (json[key] as List? ?? [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    return AdminUserRecord(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      verified: json['email_verified_at'] != null,
      twoFactor: json['two_factor_enabled'] as bool,
      sessions: json['active_sessions_count'] as int,
      organizations: rows('organizations'),
      roles: rows('roles'),
      activity: rows('recent_activity'),
    );
  }
}

abstract interface class AdminUserDirectoryService {
  Future<List<AdminUserRecord>> list();
  Future<AdminUserRecord> get(int id);
}

class ApiAdminUserDirectoryService implements AdminUserDirectoryService {
  ApiAdminUserDirectoryService(this.client);
  final ApiClient client;
  @override
  Future<List<AdminUserRecord>> list() async =>
      ((await client.get('/admin/users'))['data'] as List)
          .map(
            (item) => AdminUserRecord.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
  @override
  Future<AdminUserRecord> get(int id) async => AdminUserRecord.fromJson(
    Map<String, dynamic>.from(
      (await client.get('/admin/users/$id'))['data'] as Map,
    ),
  );
}

class MockAdminUserDirectoryService implements AdminUserDirectoryService {
  static const user = AdminUserRecord(
    id: 2,
    name: 'Ada Client',
    email: 'ada@example.com',
    verified: true,
    twoFactor: true,
    sessions: 2,
    organizations: [
      {'name': 'Oak Family', 'type': 'client'},
    ],
    roles: [
      {'name': 'Client'},
    ],
    activity: [
      {'event': 'auth.login', 'occurred_at': '2026-08-21'},
    ],
  );
  @override
  Future<List<AdminUserRecord>> list() async => const [user];
  @override
  Future<AdminUserRecord> get(int id) async => user;
}
