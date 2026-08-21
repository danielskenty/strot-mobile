class AccessInvitation {
  const AccessInvitation({
    required this.id,
    required this.email,
    required this.status,
    required this.organization,
    required this.role,
    required this.expiresAt,
  });
  final int id;
  final String email;
  final String status;
  final String organization;
  final String role;
  final DateTime expiresAt;
  factory AccessInvitation.fromJson(Map<String, dynamic> json) =>
      AccessInvitation(
        id: json['id'] as int,
        email: json['email'] as String,
        status: json['status'] as String,
        organization:
            (json['organization'] as Map<String, dynamic>)['name'] as String,
        role: (json['role'] as Map<String, dynamic>)['name'] as String,
        expiresAt: DateTime.parse(json['expires_at'] as String),
      );
}

class AccessMembership {
  const AccessMembership({
    required this.userId,
    required this.name,
    required this.email,
    required this.organizationId,
    required this.organization,
    required this.roleId,
    required this.role,
  });
  final int userId;
  final String name;
  final String email;
  final int organizationId;
  final String organization;
  final int roleId;
  final String role;
  factory AccessMembership.fromJson(Map<String, dynamic> json) =>
      AccessMembership(
        userId: json['user_id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        organizationId: json['organization_id'] as int,
        organization: json['organization_name'] as String,
        roleId: json['role_id'] as int,
        role: json['role_name'] as String,
      );
}

class AccessCentre {
  const AccessCentre({required this.invitations, required this.memberships});
  final List<AccessInvitation> invitations;
  final List<AccessMembership> memberships;
  factory AccessCentre.fromJson(Map<String, dynamic> json) => AccessCentre(
    invitations: (json['invitations'] as List<dynamic>)
        .map((item) => AccessInvitation.fromJson(item as Map<String, dynamic>))
        .toList(),
    memberships: (json['memberships'] as List<dynamic>)
        .map((item) => AccessMembership.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}
