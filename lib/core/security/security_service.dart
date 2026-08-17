import '../network/api_client.dart';

class SecuritySession {
  const SecuritySession({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.current,
    this.lastUsedAt,
  });
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final bool current;
  factory SecuritySession.fromJson(Map<String, dynamic> json) =>
      SecuritySession(
        id: json['id'] as int,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        lastUsedAt: json['last_used_at'] == null
            ? null
            : DateTime.parse(json['last_used_at'] as String),
        current: json['current'] as bool,
      );
}

abstract interface class SecurityService {
  Future<List<SecuritySession>> sessions();
  Future<void> changePassword({
    required String currentPassword,
    required String password,
  });
  Future<void> revoke(int id);
}

class ApiSecurityService implements SecurityService {
  ApiSecurityService(this.client);
  final ApiClient client;
  @override
  Future<List<SecuritySession>> sessions() async =>
      ((await client.get('/auth/sessions'))['data'] as List)
          .map((item) => SecuritySession.fromJson(item as Map<String, dynamic>))
          .toList();
  @override
  Future<void> changePassword({
    required String currentPassword,
    required String password,
  }) async {
    await client.put('/auth/password', {
      'current_password': currentPassword,
      'password': password,
      'password_confirmation': password,
    });
  }

  @override
  Future<void> revoke(int id) async {
    await client.delete('/auth/sessions/$id');
  }
}

class MockSecurityService implements SecurityService {
  final items = <SecuritySession>[
    SecuritySession(
      id: 1,
      name: 'STROT mobile · iPhone',
      createdAt: DateTime(2026, 8, 17, 8),
      lastUsedAt: DateTime(2026, 8, 17, 11, 30),
      current: true,
    ),
    SecuritySession(
      id: 2,
      name: 'STROT web · Lagos',
      createdAt: DateTime(2026, 8, 10, 9),
      lastUsedAt: DateTime(2026, 8, 16, 18, 20),
      current: false,
    ),
  ];
  @override
  Future<List<SecuritySession>> sessions() async => items;
  @override
  Future<void> changePassword({
    required String currentPassword,
    required String password,
  }) async {}
  @override
  Future<void> revoke(int id) async {
    items.removeWhere((item) => item.id == id);
  }
}
