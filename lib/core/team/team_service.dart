import '../access/access_models.dart';
import '../network/api_client.dart';
import 'team_models.dart';

abstract interface class TeamService {
  Future<TeamRegister> load();
}

class ApiTeamService implements TeamService {
  const ApiTeamService(this.client);
  final ApiClient client;
  @override
  Future<TeamRegister> load() async => TeamRegister.fromJson(
    (await client.get('/team'))['data'] as Map<String, dynamic>,
  );
}

class MockTeamService implements TeamService {
  @override
  Future<TeamRegister> load() async => TeamRegister(
    memberships: const [
      AccessMembership(
        userId: 2,
        name: 'Tunde Afolayan',
        email: 'partner@example.com',
        organizationId: 2,
        organization: 'BuildRight Ltd',
        roleId: 2,
        role: 'Partner',
      ),
      AccessMembership(
        userId: 7,
        name: 'Nneka Obi',
        email: 'sitelead@example.com',
        organizationId: 2,
        organization: 'BuildRight Ltd',
        roleId: 2,
        role: 'Partner',
      ),
    ],
    invitations: [
      AccessInvitation(
        id: 12,
        email: 'surveyor@example.com',
        status: 'pending',
        organization: 'BuildRight Ltd',
        role: 'Partner',
        expiresAt: DateTime(2026, 8, 29),
      ),
    ],
    roles: const [
      TeamRole(
        id: 2,
        key: 'partner',
        name: 'Partner',
        permissions: [
          TeamPermission(key: 'projects.view', name: 'View projects'),
          TeamPermission(key: 'reports.submit', name: 'Submit reports'),
          TeamPermission(key: 'documents.manage', name: 'Manage documents'),
        ],
      ),
    ],
  );
}
