import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/variations/variation_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/variations/variations_screen.dart';

void main() {
  testWidgets('variation review records a commercial decision', (tester) async {
    tester.view.physicalSize = const Size(1200, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: VariationsScreen(service: MockVariationService()),
      ),
    );
    await tester.pump();
    expect(find.text('Variations'), findsOneWidget);
    await tester.tap(find.text('Foundation reinforcement'));
    await tester.pumpAndSettle();
    expect(find.text('Commercial impact'), findsOneWidget);
    await tester.ensureVisible(find.text('Record decision'));
    await tester.tap(find.text('Record decision'));
    await tester.pump();
    expect(
      find.text('Decision recorded in the audit history.'),
      findsOneWidget,
    );
  });
}
