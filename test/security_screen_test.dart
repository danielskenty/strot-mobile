import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/security/security_service.dart';
import 'package:strot_app/features/security/security_screen.dart';

void main() {
  testWidgets('security settings change password and revoke another session', (
    tester,
  ) async {
    final service = MockSecurityService();
    await tester.pumpWidget(
      MaterialApp(home: SecurityScreen(service: service)),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('STROT web · Lagos'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Revoke'));
    await tester.pumpAndSettle();
    expect(find.text('STROT web · Lagos'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, 700));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Current password'),
      'Old-password1!',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'New password'),
      'New-password2!',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirm new password'),
      'New-password2!',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Change password'));
    await tester.pumpAndSettle();
    expect(
      find.text('Password changed. Other sessions were revoked.'),
      findsOneWidget,
    );
  });
}
