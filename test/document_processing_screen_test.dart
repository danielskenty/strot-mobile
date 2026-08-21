import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/documents/document_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/documents/documents_screen.dart';

void main() {
  testWidgets('document centre exposes processing and retry states', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: DocumentsScreen(service: MockDocumentService()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Scope-of-Work-v2.1.pdf'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();
    expect(find.text('Preparing preview and metadata'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('foundation-evidence.jpg'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsWidgets);
  });
}
