import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/properties/property_service.dart';
import 'package:strot_app/core/property_access/property_access_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/property_access/property_access_screen.dart';

void main() {
  testWidgets('shows credential-free access and revokes exact record', (
    tester,
  ) async {
    final service = MockPropertyAccessService();
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: PropertyAccessScreen(
          service: service,
          propertyService: MockPropertyService(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Physical lock credentials are never displayed'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('revoke-access-1')),
      300,
    );
    await tester.tap(find.byKey(const Key('revoke-access-1')));
    await tester.pumpAndSettle();
    expect(service.revokedId, 1);
  });

  testWidgets('adds a household record to an authorized property', (
    tester,
  ) async {
    final service = MockPropertyAccessService();
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: PropertyAccessScreen(
          service: service,
          propertyService: MockPropertyService(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add record'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('access-property-select')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PROP-OAK01 · Oak Residence').last);
    await tester.enterText(find.byKey(const Key('access-name')), 'Nneka Obi');
    await tester.tap(find.text('Add to register'));
    await tester.pumpAndSettle();
    expect(service.createdPropertyId, 1);
  });
}
