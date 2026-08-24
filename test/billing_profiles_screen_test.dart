import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/billing/billing_profile_service.dart';
import 'package:strot_app/core/profile/organization_profile_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/billing/billing_profiles_screen.dart';

void main() {
  testWidgets('shows protected default and archives exact secondary address', (
    tester,
  ) async {
    final service = MockBillingProfileService();
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: BillingProfilesScreen(
          service: service,
          organizationService: MockOrganizationProfileService(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Default'), findsOneWidget);
    expect(find.text('Primary billing'), findsOneWidget);
    expect(find.byKey(const Key('archive-billing-1')), findsNothing);
    await tester.scrollUntilVisible(
      find.byKey(const Key('archive-billing-2')),
      300,
    );
    await tester.drag(find.byType(ListView), const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('archive-billing-2')));
    await tester.pumpAndSettle();
    expect(service.archivedId, 2);
  });

  testWidgets('creates billing profile for an authorized organization', (
    tester,
  ) async {
    final service = MockBillingProfileService();
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: BillingProfilesScreen(
          service: service,
          organizationService: MockOrganizationProfileService(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('billing-organization-select')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oak Residence').last);
    await tester.enterText(
      find.byKey(const Key('billing-label')),
      'Project billing',
    );
    await tester.enterText(
      find.byKey(const Key('billing-legal')),
      'Oak Residence Limited',
    );
    await tester.enterText(
      find.byKey(const Key('billing-email')),
      'billing@oak.test',
    );
    await tester.enterText(
      find.byKey(const Key('billing-address1')),
      '12 Marina Road',
    );
    await tester.enterText(find.byKey(const Key('billing-city')), 'Lagos');
    await tester.ensureVisible(find.text('Save billing profile'));
    await tester.tap(find.text('Save billing profile'));
    await tester.pumpAndSettle();
    expect(service.createdOrganizationId, 1);
  });
}
