import '../access/access_models.dart';

class TeamPermission {
  const TeamPermission({required this.key, required this.name});
  final String key, name;
  factory TeamPermission.fromJson(Map<String, dynamic> json) =>
      TeamPermission(key: json['key'] as String, name: json['name'] as String);
}

class TeamRole {
  const TeamRole({
    required this.id,
    required this.key,
    required this.name,
    required this.permissions,
  });
  final int id;
  final String key, name;
  final List<TeamPermission> permissions;
  factory TeamRole.fromJson(Map<String, dynamic> json) => TeamRole(
    id: json['id'] as int,
    key: json['key'] as String,
    name: json['name'] as String,
    permissions: (json['permissions'] as List)
        .map((item) => TeamPermission.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}

class TeamRegister {
  const TeamRegister({
    required this.memberships,
    required this.invitations,
    required this.roles,
  });
  final List<AccessMembership> memberships;
  final List<AccessInvitation> invitations;
  final List<TeamRole> roles;
  factory TeamRegister.fromJson(Map<String, dynamic> json) => TeamRegister(
    memberships: (json['memberships'] as List)
        .map((item) => AccessMembership.fromJson(item as Map<String, dynamic>))
        .toList(),
    invitations: (json['invitations'] as List)
        .map((item) => AccessInvitation.fromJson(item as Map<String, dynamic>))
        .toList(),
    roles: (json['roles'] as List)
        .map((item) => TeamRole.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}
