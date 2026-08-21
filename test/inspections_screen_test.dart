import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/inspections/inspection_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/inspections/inspections_screen.dart';

void main() {
  testWidgets('inspection shows checklist findings and evidence', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: InspectionsScreen(service: MockInspectionService()),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Foundation reinforcement inspection'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Checklist · 2/2'), findsOneWidget);
    expect(find.text('Measured at 200 mm centres.'), findsOneWidget);
    expect(find.text('foundation-grid-a.jpg'), findsOneWidget);
  });
}
