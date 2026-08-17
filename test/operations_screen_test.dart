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
}
