import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/messages/message_service.dart';
import 'package:strot_app/features/messages/messages_screen.dart';

void main() {
  testWidgets('message centre opens exact support thread and reply controls', (
    tester,
  ) async {
    final service = MockMessageService();
    await tester.pumpWidget(
      MaterialApp(home: MessagesScreen(service: service, canManage: true)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Document signature assistance'), findsOneWidget);
    await tester.tap(find.text('Document signature assistance'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'The signature control is unavailable on the current scope document.',
      ),
      findsOneWidget,
    );
    await tester.drag(find.byType(ListView).last, const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Mark resolved'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Reply'), findsOneWidget);
  });
}
