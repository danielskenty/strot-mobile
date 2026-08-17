class StrotNotification {
  const StrotNotification({
    required this.id,
    required this.category,
    required this.priority,
    required this.title,
    required this.body,
    required this.actionUrl,
    required this.actionRequired,
    required this.readAt,
    required this.resolvedAt,
    required this.createdAt,
    this.projectName,
    this.projectReference,
    this.senderName,
  });
  final String id, category, priority, title, body;
  final String? actionUrl, projectName, projectReference, senderName;
  final bool actionRequired;
  final DateTime? readAt, resolvedAt;
  final DateTime createdAt;
}

class NotificationPreferences {
  const NotificationPreferences({
    required this.enabledChannels,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.preferredEmail,
    required this.preferredPhone,
    required this.whatsappConsented,
    required this.smsConsented,
    required this.pushPermission,
  });
  final Set<String> enabledChannels;
  final String? quietHoursStart, quietHoursEnd, preferredEmail, preferredPhone;
  final bool whatsappConsented, smsConsented;
  final String pushPermission;
}
