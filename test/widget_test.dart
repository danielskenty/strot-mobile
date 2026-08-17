import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/main.dart';

void main() {
  testWidgets('renders the STROT sign in screen', (tester) async {
    await tester.pumpWidget(const StrotApp());
    await tester.pumpAndSettle();
    expect(find.text('Sign in to your workspace'), findsOneWidget);
    expect(find.text('Sign in securely'), findsOneWidget);
  });
}
