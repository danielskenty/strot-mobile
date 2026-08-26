import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/auth/auth_models.dart';
import 'package:strot_app/features/portal/portal_shell.dart';

void main() {
  testWidgets('desktop toolbar exposes descriptive accessibility labels', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: PortalShell(
          useMocks: true,
          session: AuthSession(
            name: 'Adaeze Okafor',
            email: 'client@strot.test',
            organization: 'Oak Residence',
            roles: [StrotRole.client],
            permissions: {'projects.view', 'payments.view'},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('Organization details'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Profile and contact details'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Synchronisation status'), findsOneWidget);
    expect(find.bySemanticsLabel('Account security'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets(
    'phone navigation exposes remaining workspace areas through More',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: PortalShell(
            useMocks: true,
            session: AuthSession(
              name: 'Adaeze Okafor',
              email: 'client@strot.test',
              organization: 'Oak Residence',
              roles: [StrotRole.client],
              permissions: {'projects.view', 'payments.view'},
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.text('More'), findsOneWidget);
      expect(find.text('Payments'), findsNothing);
      await tester.tap(find.text('More'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('All workspace areas'), findsOneWidget);
      expect(find.text('Payments'), findsOneWidget);
    },
  );
}
