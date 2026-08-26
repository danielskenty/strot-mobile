import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/main.dart';

void main() {
  testWidgets('renders the STROT sign in screen', (tester) async {
    await tester.pumpWidget(const StrotApp());
    await tester.pumpAndSettle();
    expect(find.text('Sign in to your workspace'), findsOneWidget);
    expect(find.text('Sign in securely'), findsOneWidget);
    const useMocks = bool.fromEnvironment(
      'STROT_USE_MOCKS',
      defaultValue: false,
    );
    expect(
      find.textContaining('strot-demo'),
      useMocks ? findsOneWidget : findsNothing,
    );
    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields[0].controller?.text, isEmpty);
    expect(fields[1].controller?.text, isEmpty);

    final semantics = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.byKey(const Key('sign-in-email'))).label,
      contains('Email address'),
    );
    expect(
      tester.getSemantics(find.byKey(const Key('sign-in-password'))).label,
      contains('Password'),
    );
    semantics.dispose();
  });
}
