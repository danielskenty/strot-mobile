import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/partner/partner_quotation_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/partner/partner_quotations_screen.dart';

void main() {
  testWidgets('quotation deep link opens the exact quotation record', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: PartnerQuotationsScreen(
          service: MockPartnerQuotationService(),
          initialId: 1,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Quotation #1'), findsOneWidget);
    expect(find.text('Submitted base amount'), findsOneWidget);
    expect(
      find.textContaining('Client pricing and internal STROT margins'),
      findsOneWidget,
    );
  });
}
