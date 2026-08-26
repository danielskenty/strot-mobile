import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/referrals/referral_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/referrals/referral_admin_screen.dart';
import 'package:strot_app/features/referrals/referrals_screen.dart';

class RecordingReferralService extends MockReferralService {
  String? category, decision, note;
  @override
  Future<void> review({
    required String category,
    required String id,
    required String decision,
    required String note,
  }) async {
    this.category = category;
    this.decision = decision;
    this.note = note;
  }
}

void main() {
  testWidgets(
    'member workspace shows eligible services and never offers own-service override',
    (tester) async {
      final service = MockReferralService();
      await tester.pumpWidget(
        MaterialApp(
          theme: StrotTheme.light,
          home: ReferralsScreen(service: service),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Referral workspace'), findsOneWidget);
      expect(find.text('STROT-PARTNER1'), findsOneWidget);
      final exclusionNotice = find.textContaining(
        'Own services and related service families are never offered',
      );
      await tester.scrollUntilVisible(
        exclusionNotice,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(exclusionNotice, findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const Key('referral-introduce')),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('referral-introduce')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('referral-name')),
        'New Property Owner',
      );
      await tester.enterText(
        find.byKey(const Key('referral-email')),
        'owner@example.com',
      );
      await tester.tap(find.byKey(const Key('referral-service')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Construction').last);
      await tester.ensureVisible(find.text('Send consent invitation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send consent invitation'));
      await tester.pumpAndSettle();
      expect(service.introduced, ['s1']);
    },
  );

  testWidgets(
    'admin governance shows eligibility and records exact fraud review',
    (tester) async {
      final service = RecordingReferralService();
      await tester.pumpWidget(
        MaterialApp(
          theme: StrotTheme.light,
          home: ReferralAdminScreen(service: service),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Referral control plane'), findsOneWidget);
      final eligibilityNotice = find.textContaining(
        'cannot be overridden by an administrator or AI',
      );
      await tester.scrollUntilVisible(
        eligibilityNotice,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(eligibilityNotice, findsOneWidget);
      expect(find.text('BuildRight Ltd\npartner'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const Key('review-f1')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('review-f1')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('referral-review-note')),
        'Identity and contact signals verified independently.',
      );
      await tester.tap(find.text('Record decision'));
      await tester.pumpAndSettle();
      expect(service.category, 'fraud');
      expect(service.decision, 'cleared');
    },
  );
}
