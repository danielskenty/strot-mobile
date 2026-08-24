import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/team/team_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/team/team_screen.dart';

void main() {
  testWidgets('shows scoped partner members and governed permissions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: TeamScreen(service: MockTeamService()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Team members and roles'), findsOneWidget);
    expect(find.text('Tunde Afolayan'), findsOneWidget);
    expect(find.text('Partner'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Submit reports'), 300);
    expect(find.text('Submit reports'), findsOneWidget);
  });

  testWidgets(
    'keeps team mutations and credentials outside the mobile register',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: StrotTheme.light,
          home: TeamScreen(service: MockTeamService()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('Invitation issuance'),
        400,
      );
      expect(
        find.textContaining(
          'Passwords, invitation tokens and recovery credentials are never displayed',
        ),
        findsOneWidget,
      );
      expect(find.text('Remove access'), findsNothing);
      expect(find.text('Send invitation'), findsNothing);
    },
  );
}
