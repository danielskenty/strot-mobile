import '../network/api_client.dart';
import 'access_models.dart';

abstract interface class AccessService {
  Future<AccessCentre> load();
  Future<void> revokeInvitation(int id);
  Future<void> revokeMembership(AccessMembership membership);
}

class ApiAccessService implements AccessService {
  const ApiAccessService(this.client);
  final ApiClient client;
  @override
  Future<AccessCentre> load() async => AccessCentre.fromJson(
    (await client.get('/admin/access'))['data'] as Map<String, dynamic>,
  );
  @override
  Future<void> revokeInvitation(int id) async {
    await client.delete('/admin/invitations/$id');
  }

  @override
  Future<void> revokeMembership(AccessMembership item) async {
    await client.delete(
      '/admin/organizations/${item.organizationId}/users/${item.userId}/roles/${item.roleId}',
    );
  }
}

class MockAccessService implements AccessService {
  final List<AccessInvitation> _invitations = [
    AccessInvitation(
      id: 12,
      email: 'sitelead@buildright.test',
      status: 'pending',
      organization: 'BuildRight Ltd',
      role: 'Partner',
      expiresAt: DateTime(2026, 8, 27),
    ),
  ];
  final List<AccessMembership> _memberships = [
    const AccessMembership(
      userId: 4,
      name: 'Amara Okoye',
      email: 'admin@strot.test',
      organizationId: 4,
      organization: 'STROT',
      roleId: 5,
      role: 'Super Admin',
    ),
    const AccessMembership(
      userId: 2,
      name: 'Tunde Afolayan',
      email: 'partner@strot.test',
      organizationId: 2,
      organization: 'BuildRight Ltd',
      roleId: 2,
      role: 'Partner',
    ),
  ];
  @override
  Future<AccessCentre> load() async => AccessCentre(
    invitations: List.of(_invitations),
    memberships: List.of(_memberships),
  );
  @override
  Future<void> revokeInvitation(int id) async =>
      _invitations.removeWhere((item) => item.id == id);
  @override
  Future<void> revokeMembership(AccessMembership membership) async =>
      _memberships.removeWhere(
        (item) =>
            item.userId == membership.userId &&
            item.organizationId == membership.organizationId &&
            item.roleId == membership.roleId,
      );
}
