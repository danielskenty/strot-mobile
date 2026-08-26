import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/auth/auth_models.dart';
import 'package:strot_app/core/auth/auth_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/auth/sign_in_screen.dart';
import 'package:strot_app/features/portal/portal_shell.dart';

const _session = AuthSession(
  name: 'Adaeze Okafor',
  email: 'client@strot.test',
  organization: 'Oak Residence',
  roles: [StrotRole.client],
  permissions: {'projects.view', 'payments.view'},
);

Widget _app(Widget home, {double textScale = 1}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: StrotTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: home,
);

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  await tester.pump();
}

void main() {
  setUpAll(() async {
    final inter = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Inter-SemiBold.ttf'));
    final playfair = FontLoader('Playfair Display')
      ..addFont(rootBundle.load('assets/fonts/PlayfairDisplay-SemiBold.ttf'));
    final materialIcons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await Future.wait([inter.load(), playfair.load(), materialIcons.load()]);
  });

  tearDown(() {});

  testWidgets('captures desktop sign-in and authenticated client overview', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _setSurface(tester, const Size(800, 628));

    await tester.pumpWidget(
      _app(
        SignInScreen(authService: MockAuthService(), showMockCredentials: true),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile(
        '../audits/flutter-device-accessibility-2026-08-26/01-sign-in-desktop.png',
      ),
    );

    await tester.pumpWidget(
      _app(const PortalShell(session: _session, useMocks: true)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PortalShell), findsOneWidget);
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile(
        '../audits/flutter-device-accessibility-2026-08-26/02-client-overview-desktop.png',
      ),
    );
  });

  testWidgets('captures compact client navigation and More destinations', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(const PortalShell(session: _session, useMocks: true)),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile(
        '../audits/flutter-device-accessibility-2026-08-26/03-client-overview-phone.png',
      ),
    );

    await tester.tap(find.text('More'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('All workspace areas'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile(
        '../audits/flutter-device-accessibility-2026-08-26/04-client-more-phone.png',
      ),
    );
  });

  testWidgets('sign-in remains operable at 200 percent text scaling', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(
        SignInScreen(authService: MockAuthService(), showMockCredentials: true),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign in securely'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile(
        '../audits/flutter-device-accessibility-2026-08-26/05-sign-in-phone-large-text.png',
      ),
    );
    await tester.ensureVisible(find.text('Sign in securely'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in securely').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sign-in meets Flutter label, target, and contrast guidelines', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    await _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      _app(
        SignInScreen(authService: MockAuthService(), showMockCredentials: true),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });
}
