import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/smart_property/smart_property_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/smart_property/smart_property_screen.dart';

void main() {
  testWidgets('opens exact smart property with device health and telemetry', (
    tester,
  ) async {
    final service = MockSmartPropertyService();
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: SmartPropertiesScreen(service: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Smart living dashboard'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('smart-property-1')),
      300,
    );
    await tester.tap(find.byKey(const Key('smart-property-1')));
    await tester.pumpAndSettle();

    expect(service.lastOpenedId, 1);
    expect(find.text('Living room'), findsOneWidget);
    expect(find.text('Climate sensor'), findsOneWidget);
    expect(find.byKey(const Key('device-health-41')), findsOneWidget);
    expect(find.text('Battery replacement due'), findsOneWidget);
    expect(find.text('temperature c: 24.5'), findsOneWidget);
  });
}
