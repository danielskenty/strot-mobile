import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/features/legal/legal_documents_screen.dart';
import 'package:strot_app/design_system/strot_theme.dart';

void main() {
  testWidgets('legal hub exposes every approved policy and deletion request', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: StrotTheme.light, home: const LegalDocumentsScreen()),
    );

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms of Use'), findsOneWidget);
    expect(
      find.text('Data rights, account deletion and retention'),
      findsOneWidget,
    );
    expect(find.text('Email the Privacy Team'), findsOneWidget);

    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.textContaining('STROT LIMITED'), findsOneWidget);
    expect(find.textContaining('26 August 2026'), findsOneWidget);
    expect(find.textContaining('We do not sell personal data'), findsOneWidget);
  });
}
