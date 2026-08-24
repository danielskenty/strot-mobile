import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/partner/partner_assignment_service.dart';
import 'package:strot_app/core/partner/partner_quotation_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/partner/partner_work_screen.dart';

void main() {
  testWidgets(
    'partner work landing uses service-backed assignments and quotations',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: StrotTheme.light,
          home: PartnerWorkScreen(
            assignmentService: MockPartnerAssignmentService(),
            quotationService: MockPartnerQuotationService(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Awaiting response'), findsOneWidget);
      expect(find.text('Quotation corrections'), findsOneWidget);
      expect(find.text('Review assignments'), findsOneWidget);
      expect(find.text('Quotation register'), findsOneWidget);
      expect(find.text('Submit quotation'), findsNothing);
    },
  );
}
