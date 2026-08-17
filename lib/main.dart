import 'package:flutter/material.dart';

import 'design_system/strot_theme.dart';
import 'core/auth/auth_service.dart';
import 'core/network/api_client.dart';
import 'features/auth/sign_in_screen.dart';

void main() => runApp(const StrotApp());

class StrotApp extends StatelessWidget {
  const StrotApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'STROT',
    debugShowCheckedModeBanner: false,
    theme: StrotTheme.light,
    home: SignInScreen(
      authService:
          const bool.fromEnvironment('STROT_USE_MOCKS', defaultValue: false)
          ? MockAuthService()
          : ApiAuthService(ApiClient(baseUrl: ApiClient.defaultBaseUrl)),
    ),
  );
}
