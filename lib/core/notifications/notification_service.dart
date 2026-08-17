import '../network/api_client.dart';
import 'notification_models.dart';

abstract interface class NotificationService {
  Future<(List<StrotNotification>, int)> list();
  Future<void> markRead(String id);
  Future<void> markAllRead();
  Future<NotificationPreferences> preferences();
  Future<void> savePreferences(NotificationPreferences preferences);
  Future<int> registerDevice({
    required String platform,
    required String token,
    required String permission,
  });
  Future<void> revokeDevice(int id);
}

class ApiNotificationService implements NotificationService {
  ApiNotificationService(this.client);
  final ApiClient client;
  @override
  Future<(List<StrotNotification>, int)> list() async {
    final response = await client.get('/notifications');
    final page = response['data'] as Map<String, dynamic>;
    final meta = response['meta'] as Map<String, dynamic>;
    return (
      (page['data'] as List<dynamic>)
          .map((item) => _notification(item as Map<String, dynamic>))
          .toList(),
      meta['unread_count'] as int,
    );
  }

  StrotNotification _notification(Map<String, dynamic> value) {
    final project = value['project'] as Map<String, dynamic>?;
    final sender = value['sender'] as Map<String, dynamic>?;
    return StrotNotification(
      id: value['id'] as String,
      category: value['category'] as String,
      priority: value['priority'] as String,
      title: value['title'] as String,
      body: value['body'] as String,
      actionUrl: value['action_url'] as String?,
      actionRequired: value['action_required'] as bool,
      readAt: value['read_at'] == null
          ? null
          : DateTime.parse(value['read_at'] as String),
      resolvedAt: value['resolved_at'] == null
          ? null
          : DateTime.parse(value['resolved_at'] as String),
      createdAt: DateTime.parse(value['created_at'] as String),
      projectName: project?['name'] as String?,
      projectReference: project?['reference'] as String?,
      senderName: sender?['name'] as String?,
    );
  }

  @override
  Future<void> markRead(String id) async {
    await client.post('/notifications/$id/read', {});
  }

  @override
  Future<void> markAllRead() async {
    await client.post('/notifications/read-all', {});
  }

  @override
  Future<NotificationPreferences> preferences() async {
    final response = await client.get('/notifications/preferences');
    return _preferences(response['data'] as Map<String, dynamic>);
  }

  NotificationPreferences _preferences(Map<String, dynamic> value) =>
      NotificationPreferences(
        enabledChannels: (value['enabled_channels'] as List<dynamic>)
            .cast<String>()
            .toSet(),
        quietHoursStart: value['quiet_hours_start'] as String?,
        quietHoursEnd: value['quiet_hours_end'] as String?,
        preferredEmail: value['preferred_email'] as String?,
        preferredPhone: value['preferred_phone'] as String?,
        whatsappConsented: value['whatsapp_consented'] as bool,
        smsConsented: value['sms_consented'] as bool,
        pushPermission: value['push_permission'] as String,
      );
  @override
  Future<void> savePreferences(NotificationPreferences value) async {
    await client.put('/notifications/preferences', {
      'enabled_channels': value.enabledChannels.toList(),
      'enabled_categories': null,
      'quiet_hours_start': value.quietHoursStart,
      'quiet_hours_end': value.quietHoursEnd,
      'timezone': 'Africa/Lagos',
      'preferred_email': value.preferredEmail,
      'preferred_phone': value.preferredPhone,
      'whatsapp_consented': value.whatsappConsented,
      'sms_consented': value.smsConsented,
      'push_permission': value.pushPermission,
    });
  }

  @override
  Future<int> registerDevice({
    required String platform,
    required String token,
    required String permission,
  }) async {
    final response = await client.post('/notifications/devices', {
      'platform': platform,
      'token': token,
      'permission': permission,
    });
    return (response['data'] as Map<String, dynamic>)['id'] as int;
  }

  @override
  Future<void> revokeDevice(int id) async {
    await client.delete('/notifications/devices/$id');
  }
}

class MockNotificationService implements NotificationService {
  final items = <StrotNotification>[
    StrotNotification(
      id: 'mock-approval',
      category: 'approvals',
      priority: 'action_required',
      title: 'Scope approval required',
      body: 'Review Scope of Work v2.1 before the current stage can proceed.',
      actionUrl: '/portal/approvals/1',
      actionRequired: true,
      readAt: null,
      resolvedAt: null,
      createdAt: DateTime(2026, 8, 17, 9, 42),
      projectName: 'Oak Residence',
      projectReference: 'STR-24001',
      senderName: 'STROT Operations',
    ),
  ];
  @override
  Future<(List<StrotNotification>, int)> list() async =>
      (items, items.where((item) => item.readAt == null).length);
  @override
  Future<void> markAllRead() async {}
  @override
  Future<void> markRead(String id) async {}
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
  Future<void> savePreferences(NotificationPreferences preferences) async {}
  @override
  Future<int> registerDevice({
    required String platform,
    required String token,
    required String permission,
  }) async => 1;
  @override
  Future<void> revokeDevice(int id) async {}
}

abstract interface class PushTokenSource {
  Future<({String token, String platform, String permission})?> current();
}

class NotificationDeviceRegistrar {
  const NotificationDeviceRegistrar(this.service, this.source);
  final NotificationService service;
  final PushTokenSource source;

  Future<int?> synchronize() async {
    final device = await source.current();
    if (device == null) return null;
    return service.registerDevice(
      platform: device.platform,
      token: device.token,
      permission: device.permission,
    );
  }
}
