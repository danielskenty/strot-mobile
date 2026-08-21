import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/access/access_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/access/access_admin_screen.dart';

void main() {
  testWidgets('access centre shows invitations and memberships', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: AccessAdminScreen(service: MockAccessService()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Team access'), findsOneWidget);
    expect(find.text('sitelead@buildright.test'), findsOneWidget);
    expect(find.text('Revoke'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Amara Okoye'), findsOneWidget);
  });
}
