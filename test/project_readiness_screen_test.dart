import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/projects/project_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/projects/projects_screen.dart';

void main() {
  testWidgets('project detail shows readiness requirements', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: StrotTheme.light, home: ProjectOverviewScreen(project: MockProjectService.project)));
    await tester.pump();
    expect(find.text('Delivery stages'), findsOneWidget);
    expect(find.textContaining('2/3 ready'), findsOneWidget);
    await tester.tap(find.text('Scope & approvals'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Commencement deposit received'), findsOneWidget);
  });
}
