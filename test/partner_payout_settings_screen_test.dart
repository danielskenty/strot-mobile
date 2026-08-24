import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/partner/partner_payout_profile_service.dart';
import 'package:strot_app/core/profile/organization_profile_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/partner/partner_payout_settings_screen.dart';

class PartnerOrganizationService implements OrganizationProfileService {
  @override
  Future<List<OrganizationProfileRecord>> list() async => const [
    OrganizationProfileRecord(
      id: 2,
      name: 'BuildRight Ltd',
      type: 'partner',
      status: 'active',
      country: 'NG',
    ),
  ];
  @override
  Future<void> update(OrganizationProfileRecord item) async {}
}

void main() {
  testWidgets('shows masked payout and explicit non-transfer state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: PartnerPayoutSettingsScreen(
          service: MockPartnerPayoutProfileService(),
          organizationService: PartnerOrganizationService(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('•••• 6789 · NGN'), findsOneWidget);
    expect(
      find.textContaining('Saving details never initiates a transfer'),
      findsOneWidget,
    );
    expect(find.text('0123456789'), findsNothing);
  });
  testWidgets('submits secure replacement for partner organization', (
    tester,
  ) async {
    final service = MockPartnerPayoutProfileService();
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: PartnerPayoutSettingsScreen(
          service: service,
          organizationService: PartnerOrganizationService(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Replace payout details'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('payout-organization-select')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('BuildRight Ltd').last);
    await tester.enterText(
      find.byKey(const Key('payout-beneficiary')),
      'BuildRight Limited',
    );
    await tester.enterText(
      find.byKey(const Key('payout-bank')),
      'Example Bank',
    );
    await tester.enterText(
      find.byKey(const Key('payout-account')),
      '0123456789',
    );
    await tester.ensureVisible(find.text('Save securely'));
    await tester.tap(find.text('Save securely'));
    await tester.pumpAndSettle();
    expect(service.savedOrganizationId, 2);
  });
}
