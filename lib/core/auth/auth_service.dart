import 'auth_models.dart';
import '../network/api_client.dart';

abstract interface class AuthService {
  Future<AuthSession> signIn({required String email, required String password});
  Future<AuthSession> verifyTwoFactor({
    required String challengeToken,
    required String code,
  });
  Future<void> signOut();
}

class MockAuthService implements AuthService {
  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (password != 'strot-demo') {
      throw const AuthException('The provided credentials are not valid.');
    }
    if (email == 'partner@strot.test') {
      return const AuthSession(
        name: 'Tunde Afolayan',
        email: 'partner@strot.test',
        organization: 'BuildRight Ltd',
        roles: [StrotRole.partner],
        permissions: {
          'projects.view',
          'documents.view',
          'documents.manage',
          'quotations.submit',
        },
      );
    }
    if (email == 'provider@strot.test') {
      return const AuthSession(
        name: 'Maya Chen',
        email: 'provider@strot.test',
        organization: 'GeoVerify API',
        roles: [StrotRole.apiProvider],
        permissions: {'projects.view', 'integrations.manage'},
      );
    }
    if (email == 'admin@strot.test') {
      return const AuthSession(
        name: 'Amara Okoye',
        email: 'admin@strot.test',
        organization: 'STROT',
        roles: [StrotRole.superAdmin],
        permissions: {
          'admin.access',
          'pricing.internal',
          'projects.manage',
          'payments.manage',
          'integrations.manage',
        },
      );
    }
    if (email != 'client@strot.test') {
      throw const AuthException('The provided credentials are not valid.');
    }
    return const AuthSession(
      name: 'Adaeze Okafor',
      email: 'client@strot.test',
      organization: 'Oak Residence',
      roles: [StrotRole.client],
      permissions: {
        'projects.view',
        'documents.view',
        'approvals.decide',
        'payments.view',
      },
    );
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthSession> verifyTwoFactor({
    required String challengeToken,
    required String code,
  }) => throw const AuthException(
    'Two-factor authentication is not enabled for demo accounts.',
  );
}

class ApiAuthService implements AuthService {
  ApiAuthService(this.client);
  final ApiClient client;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.post('/auth/login', {
        'email': email,
        'password': password,
        'device_name': 'strot-flutter',
      });
      final data = response['data'] as Map<String, dynamic>;
      if (data['two_factor_required'] == true) {
        throw TwoFactorRequired(data['challenge_token'] as String);
      }
      return _session(response, data);
    } on TwoFactorRequired {
      rethrow;
    } on ApiException catch (exception) {
      throw AuthException(
        exception.statusCode == 422
            ? 'The provided credentials are not valid.'
            : exception.message,
      );
    }
  }

  @override
  Future<AuthSession> verifyTwoFactor({
    required String challengeToken,
    required String code,
  }) async {
    try {
      final response = await client.post('/auth/two-factor/challenge', {
        'challenge_token': challengeToken,
        'code': code,
      });
      return _session(response, response['data'] as Map<String, dynamic>);
    } on ApiException catch (exception) {
      throw AuthException(exception.message);
    }
  }

  AuthSession _session(
    Map<String, dynamic> response,
    Map<String, dynamic> data,
  ) {
    final organizations = data['organizations'] as List<dynamic>;
    return AuthSession(
      name: (data['user'] as Map<String, dynamic>)['name'] as String,
      email: (data['user'] as Map<String, dynamic>)['email'] as String,
      organization: organizations.isEmpty
          ? 'STROT'
          : (organizations.first as Map<String, dynamic>)['name'] as String,
      roles: (data['roles'] as List<dynamic>)
          .map((role) => _role(role as String))
          .toList(),
      permissions: (data['permissions'] as List<dynamic>)
          .cast<String>()
          .toSet(),
      token: response['token'] as String,
    );
  }

  StrotRole _role(String role) => switch (role) {
    'partner' => StrotRole.partner,
    'api_provider' => StrotRole.apiProvider,
    'super_admin' => StrotRole.superAdmin,
    _ => StrotRole.client,
  };

  @override
  Future<void> signOut() async {}
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
}

class TwoFactorRequired implements Exception {
  const TwoFactorRequired(this.challengeToken);
  final String challengeToken;
}
