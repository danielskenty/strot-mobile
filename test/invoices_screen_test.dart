import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/invoices/invoice_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/invoices/invoices_screen.dart';

void main() {
  testWidgets('invoice shows reconciliation history', (tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: InvoicesScreen(service: MockInvoiceService()),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Stage two · Scope approval'));
    await tester.pumpAndSettle();
    expect(find.text('Reconciliation history'), findsOneWidget);
    expect(find.textContaining('BANK-260820-01'), findsOneWidget);
    expect(find.text('Outstanding'), findsOneWidget);
  });
}
