import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/approvals/approval_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/approvals/approvals_screen.dart';

void main() {
  testWidgets('shows the ordered approval sequence and current stage', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: ApprovalsScreen(service: MockApprovalService()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Client authorization'), findsWidgets);
    await tester.tap(find.text('Scope of Work'));
    await tester.pumpAndSettle();
    expect(find.text('Approval sequence'), findsOneWidget);
    expect(find.text('STROT technical review'), findsOneWidget);
    expect(find.text('Ifeoma Eze'), findsOneWidget);
    expect(find.text('Scope and allowances verified.'), findsOneWidget);
  });
}
