import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/operations/operation_service.dart';
import 'package:strot_app/features/operations/operations_screen.dart';

void main() {
  testWidgets('opens exact task and report records from operations', (
    tester,
  ) async {
    final service = MockOperationService();
    await tester.pumpWidget(
      MaterialApp(home: OperationsScreen(service: service, canSubmit: true)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inspect first-floor columns'), findsOneWidget);
    await tester.tap(find.text('Inspect first-floor columns'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Verify reinforcement spacing and photograph each completed column before concrete placement.',
      ),
      findsOneWidget,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daily reports'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('First-floor formwork completed and checked.'));
    await tester.pumpAndSettle();
    expect(find.text('Two lintels remain outstanding.'), findsOneWidget);
  });

  testWidgets('submits a site report against the selected project', (
    tester,
  ) async {
    final service = MockOperationService();
    await tester.pumpWidget(
      MaterialApp(home: OperationsScreen(service: service, canSubmit: true)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Site report'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('site-report-project-select')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oak Residence · STR-24001').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Work completed'),
      'Reinforcement inspection completed.',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Workers on site'),
      '12',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
    await tester.pumpAndSettle();

    expect(service.lastSubmitted?.projectId, 71);
    expect(service.lastSubmitted?.workersOnSite, 12);
    expect(
      service.lastSubmitted?.workCompleted,
      'Reinforcement inspection completed.',
    );
  });
}
