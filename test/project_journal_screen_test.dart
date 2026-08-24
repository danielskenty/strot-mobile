import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/project_journal/project_journal_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/project_journal/project_journal_screen.dart';

void main() {
  testWidgets('shows certified progress and opens the exact journal record', (
    tester,
  ) async {
    final service = MockProjectJournalService();
    String? opened;
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: Scaffold(
          body: ProjectJournalScreen(
            service: service,
            onOpen: (deepLink) async => opened = deepLink,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Project journal'), findsOneWidget);
    expect(find.text('Certified'), findsWidgets);
    expect(
      find.text(
        'Ground-floor wall finishes completed and joinery setting-out verified.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('journal-entry-site-report-12')));
    await tester.pump();
    expect(opened, '/portal/site-reports/12');
  });

  testWidgets('filters the journal by an authorized project', (tester) async {
    final service = MockProjectJournalService();
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: Scaffold(
          body: ProjectJournalScreen(service: service, onOpen: (_) async {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('journal-project-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('STR-24001 · Oak Residence').last);
    await tester.pumpAndSettle();

    expect(service.lastProjectId, 1);
  });
}
