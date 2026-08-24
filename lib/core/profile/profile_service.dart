import '../network/api_client.dart';

class ProfileRecord {
  const ProfileRecord({
    required this.name,
    required this.loginEmail,
    required this.preferredEmail,
    required this.preferredPhone,
    required this.preferredContact,
    required this.timezone,
  });
  final String name, loginEmail, preferredContact, timezone;
  final String? preferredEmail, preferredPhone;
  factory ProfileRecord.fromJson(Map<String, dynamic> json) => ProfileRecord(
    name: json['name'] as String,
    loginEmail: json['login_email'] as String,
    preferredEmail: json['preferred_email'] as String?,
    preferredPhone: json['preferred_phone'] as String?,
    preferredContact: json['preferred_contact'] as String,
    timezone: json['timezone'] as String,
  );
}

abstract interface class ProfileService {
  Future<ProfileRecord> load();
  Future<void> update(ProfileRecord profile);
}

class ApiProfileService implements ProfileService {
  const ApiProfileService(this.client);
  final ApiClient client;
  @override
  Future<ProfileRecord> load() async => ProfileRecord.fromJson(
    (await client.get('/auth/profile'))['data'] as Map<String, dynamic>,
  );
  @override
  Future<void> update(ProfileRecord p) async {
    await client.patch('/auth/profile', {
      'name': p.name,
      'preferred_email': p.preferredEmail,
      'preferred_phone': p.preferredPhone,
      'preferred_contact': p.preferredContact,
      'timezone': p.timezone,
    });
  }
}

class MockProfileService implements ProfileService {
  @override
  Future<ProfileRecord> load() async => const ProfileRecord(
    name: 'Ada Nwosu',
    loginEmail: 'ada@example.com',
    preferredEmail: 'ada@example.com',
    preferredPhone: '+2348012345678',
    preferredContact: 'email',
    timezone: 'Africa/Lagos',
  );
  @override
  Future<void> update(ProfileRecord profile) async {}
}
