import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/consultations/consultation_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/consultations/consultations_screen.dart';

void main() {
  testWidgets('opens exact consultation and submits a reschedule request', (
    tester,
  ) async {
    final service = MockConsultationService();
    await tester.pumpWidget(
      MaterialApp(
        theme: StrotTheme.light,
        home: ConsultationsScreen(service: service, initialId: 37),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CON-260822-STROT'), findsOneWidget);
    expect(find.byKey(const Key('join-consultation')), findsOneWidget);
    await tester.ensureVisible(find.text('Change appointment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change appointment'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('consultation-date')),
      '2026-09-05',
    );
    await tester.enterText(
      find.byKey(const Key('consultation-note')),
      'Please move this appointment to the following week.',
    );
    await tester.tap(find.text('Send request'));
    await tester.pumpAndSettle();

    expect(service.lastAction, 'request_reschedule');
    expect(service.lastPreferredDate, '2026-09-05');
    expect(
      service.lastNote,
      'Please move this appointment to the following week.',
    );
  });
}
