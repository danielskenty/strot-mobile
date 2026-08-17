enum StrotRole { client, partner, apiProvider, superAdmin }

class AuthSession {
  const AuthSession({
    required this.name,
    required this.email,
    required this.organization,
    required this.roles,
    required this.permissions,
    this.token,
  });
  final String name;
  final String email;
  final String organization;
  final List<StrotRole> roles;
  final Set<String> permissions;
  final String? token;
}
