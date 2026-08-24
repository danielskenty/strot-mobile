import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/partner/partner_commercial_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/partner/partner_commercial_screen.dart';

void main() {
  testWidgets('deliverable correction opens exact record and correction form', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: PartnerCommercialScreen(
          service: _Service(),
          initialDeliverableId: 42,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('DEL-CORRECT'), findsOneWidget);
    expect(
      find.text('STROT review: Replace the blurred evidence image.'),
      findsOneWidget,
    );
    await tester.drag(find.byType(ListView).last, const Offset(0, -700));
    await tester.pump();
    expect(find.text('Submit corrected deliverable'), findsOneWidget);
  });
}

class _Service implements PartnerCommercialService {
  @override
  Future<PartnerCommercialRecord> load() async => const PartnerCommercialRecord(
    invoices: [],
    deliverables: [
      PartnerDeliverable(
        id: 42,
        reference: 'DEL-CORRECT',
        title: 'First-fix correction',
        summary: 'Revised evidence required.',
        status: 'correction_requested',
        workOrder: 'Electrical first fix',
        evidenceCount: 1,
        mediaAssetIds: ['asset-1'],
        reviewNote: 'Replace the blurred evidence image.',
      ),
    ],
  );
  @override
  Future<void> reviseDeliverable(
    int id,
    String summary,
    List<String> mediaAssetIds,
  ) async {}
  @override
  Future<void> reviewDeliverable(int id, String status, String? note) async {}
  @override
  Future<void> reviewInvoice(
    int id,
    String status, {
    String? scheduledFor,
    String? paymentReference,
  }) async {}
}
