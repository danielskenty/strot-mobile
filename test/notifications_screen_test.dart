import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strot_app/core/notifications/notification_models.dart';
import 'package:strot_app/core/notifications/notification_service.dart';
import 'package:strot_app/design_system/strot_theme.dart';
import 'package:strot_app/features/notifications/notifications_screen.dart';

void main() {
  testWidgets(
    'notification centre supports read actions, preferences and deep links',
    (tester) async {
      final service = _NotificationService();
      StrotNotification? opened;
      await tester.pumpWidget(
        MaterialApp(
          theme: StrotTheme.light,
          home: Scaffold(
            body: NotificationsScreen(
              service: service,
              onOpen: (item) async => opened = item,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notification centre'), findsOneWidget);
      expect(find.text('1 unread'), findsOneWidget);
      expect(find.text('Scope approval required'), findsOneWidget);

      await tester.tap(find.text('Open exact item →'));
      await tester.pumpAndSettle();
      expect(opened?.actionUrl, '/portal/approvals/1');
      expect(service.readIds, ['notification-1']);

      await tester.tap(find.text('Preferences'));
      await tester.pumpAndSettle();
      expect(find.text('Notification preferences'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();
      expect(service.preferencesSaved, isTrue);

      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();
      expect(service.allRead, isTrue);
    },
  );
}

class _NotificationService implements NotificationService {
  final readIds = <String>[];
  bool allRead = false, preferencesSaved = false;
  final notification = StrotNotification(
    id: 'notification-1',
    category: 'approvals',
    priority: 'action_required',
    title: 'Scope approval required',
    body: 'Review the revised scope.',
    actionUrl: '/portal/approvals/1',
    actionRequired: true,
    readAt: null,
    resolvedAt: null,
    createdAt: DateTime(2026, 8, 17),
    projectName: 'Oak Residence',
    projectReference: 'STR-24001',
    senderName: 'STROT Operations',
  );
  @override
  Future<(List<StrotNotification>, int)> list() async => ([notification], 1);
  @override
  Future<void> markRead(String id) async => readIds.add(id);
  @override
  Future<void> markAllRead() async => allRead = true;
  @override
  Future<NotificationPreferences> preferences() async =>
      const NotificationPreferences(
        enabledChannels: {'in_app', 'email'},
        quietHoursStart: '21:00',
        quietHoursEnd: '07:00',
        preferredEmail: 'client@strot.test',
        preferredPhone: null,
        whatsappConsented: false,
        smsConsented: false,
        pushPermission: 'unknown',
      );
  @override
  Future<void> savePreferences(NotificationPreferences preferences) async =>
      preferencesSaved = true;
  @override
  Future<int> registerDevice({
    required String platform,
    required String token,
    required String permission,
  }) async => 1;
  @override
  Future<void> revokeDevice(int id) async {}
}
