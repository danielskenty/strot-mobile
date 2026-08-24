import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/issues/issue_service.dart';
import 'package:strot_app/core/projects/project_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/issues/issues_screen.dart';

void main() {
  testWidgets('opens the exact issue and lets the client confirm resolution', (
    tester,
  ) async {
    final service = MockIssueService();
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: IssuesScreen(
          service: service,
          projectService: MockProjectService(),
          canManage: false,
          canCreate: false,
          initialId: 81,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ISS-260822-STROT'), findsOneWidget);
    expect(find.text('STROT response'), findsOneWidget);
    expect(find.text('Programme recovery'), findsOneWidget);
    expect(find.text('recovered'), findsOneWidget);
    expect(
      find.text(
        'Joinery completion moved by four days without affecting handover.',
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('close-resolved-issue')),
      300,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('close-resolved-issue')));
    await tester.pumpAndSettle();

    expect(service.lastStatus, 'closed');
  });

  testWidgets('administrator can update the structured recovery programme', (
    tester,
  ) async {
    final service = MockIssueService();
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: IssuesScreen(
          service: service,
          projectService: MockProjectService(),
          canManage: true,
          canCreate: false,
          initialId: 81,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Update issue'), 300);
    await tester.tap(find.text('Update issue'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('recovery-impact')), findsOneWidget);
    expect(find.byKey(const Key('recovery-plan')), findsOneWidget);
    expect(find.byKey(const Key('recovery-target')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('recovery-impact')),
      'The critical path remains protected by resequencing.',
    );
    await tester.ensureVisible(find.text('Save update'));
    await tester.tap(find.text('Save update'));
    await tester.pumpAndSettle();

    expect(service.lastStatus, 'in_progress');
    expect(
      service.lastImpactSummary,
      'The critical path remains protected by resequencing.',
    );
    expect(service.lastRecoveryStatus, 'recovered');
    expect(service.lastRecoveryOwnerId, 4);
  });

  testWidgets('raises an issue against an authorized project', (tester) async {
    final service = MockIssueService();
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: IssuesScreen(
          service: service,
          projectService: MockProjectService(),
          canManage: false,
          canCreate: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Raise issue'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('issue-project-select')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oak Residence · STR-24001').last);
    await tester.enterText(find.byKey(const Key('issue-title')), 'Door detail');
    await tester.enterText(
      find.byKey(const Key('issue-description')),
      'Please confirm the approved entrance door detail.',
    );
    await tester.tap(find.text('Submit issue'));
    await tester.pumpAndSettle();

    expect(service.createdProjectId, 1);
    expect(find.text('ISS-260822-STROT'), findsOneWidget);
  });
}
