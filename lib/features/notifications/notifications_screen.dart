import 'package:flutter/material.dart';
import '../../core/notifications/notification_models.dart';
import '../../core/notifications/notification_service.dart';
import '../../design_system/strot_tokens.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    required this.service,
    required this.onOpen,
  });
  final NotificationService service;
  final Future<void> Function(StrotNotification) onOpen;
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String priority = 'all', category = 'all', state = 'all';
  late Future<(List<StrotNotification>, int)> future;
  @override
  void initState() {
    super.initState();
    future = widget.service.list();
  }

  void refresh() {
    final next = widget.service.list();
    setState(() {
      future = next;
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.hasError) return Center(child: Text('◇ ${snapshot.error}'));
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final (items, unread) = snapshot.data!;
      final filtered = items
          .where(
            (item) =>
                (priority == 'all' || item.priority == priority) &&
                (category == 'all' || item.category == category) &&
                (state == 'all' ||
                    (state == 'unread'
                        ? item.readAt == null
                        : state == 'read'
                        ? item.readAt != null
                        : item.resolvedAt != null)),
          )
          .toList();
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'UPDATES & REQUIRED ACTIONS',
                      style: TextStyle(
                        color: StrotColors.gold,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: StrotSpacing.md),
                    Text(
                      'Notification centre',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    Text('$unread unread'),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () async {
                  await widget.service.markAllRead();
                  refresh();
                },
                child: const Text('Mark all read'),
              ),
            ],
          ),
          const SizedBox(height: StrotSpacing.lg),
          Wrap(
            spacing: StrotSpacing.sm,
            runSpacing: StrotSpacing.sm,
            children: [
              _filter('Priority', priority, const [
                'all',
                'informational',
                'action_required',
                'urgent',
                'critical',
              ], (value) => setState(() => priority = value)),
              _filter('Category', category, const [
                'all',
                'approvals',
                'financial',
                'projects',
                'documents',
                'security',
                'tasks',
              ], (value) => setState(() => category = value)),
              _filter('State', state, const [
                'all',
                'unread',
                'read',
                'resolved',
              ], (value) => setState(() => state = value)),
              OutlinedButton.icon(
                onPressed: () => _preferences(context),
                icon: const Icon(Icons.tune),
                label: const Text('Preferences'),
              ),
            ],
          ),
          const SizedBox(height: StrotSpacing.lg),
          if (filtered.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(StrotSpacing.lg),
                child: Text('No notifications match these filters.'),
              ),
            ),
          ...filtered.map(
            (item) => Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: item.readAt == null
                      ? StrotColors.gold
                      : StrotColors.forestMuted,
                ),
                borderRadius: BorderRadius.circular(StrotRadius.sm),
              ),
              child: Padding(
                padding: const EdgeInsets.all(StrotSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: StrotSpacing.sm,
                      children: [
                        Text(
                          '${item.priority.replaceAll('_', ' ').toUpperCase()} · ${item.category.toUpperCase()}',
                          style: const TextStyle(
                            color: StrotColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        if (item.actionRequired && item.resolvedAt == null)
                          const Text(
                            '◇ ACTION REQUIRED',
                            style: TextStyle(
                              color: StrotColors.forest,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: StrotSpacing.sm),
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: StrotSpacing.sm),
                    Text(item.body),
                    const SizedBox(height: StrotSpacing.md),
                    Text(
                      '${item.projectReference ?? 'STROT'} · From ${item.senderName ?? 'STROT'}',
                      style: const TextStyle(color: StrotColors.charcoalMuted),
                    ),
                    if (item.actionUrl != null) ...[
                      const SizedBox(height: StrotSpacing.md),
                      ElevatedButton(
                        onPressed: () async {
                          await widget.service.markRead(item.id);
                          await widget.onOpen(item);
                          refresh();
                        },
                        child: const Text('Open exact item →'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
  Widget _filter(
    String label,
    String value,
    List<String> values,
    ValueChanged<String> changed,
  ) => SizedBox(
    width: 190,
    child: DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: values
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item.replaceAll('_', ' ')),
            ),
          )
          .toList(),
      onChanged: (value) => changed(value!),
    ),
  );
  Future<void> _preferences(BuildContext context) async {
    final current = await widget.service.preferences();
    if (!context.mounted) return;
    final channels = {...current.enabledChannels};
    var sms = current.smsConsented, whatsapp = current.whatsappConsented;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: const Text('Notification preferences'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Security, financial and legal alerts cannot be completely disabled.',
                ),
                const SizedBox(height: StrotSpacing.md),
                ...['in_app', 'email', 'push', 'sms', 'whatsapp'].map(
                  (channel) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: channels.contains(channel),
                    title: Text(channel.replaceAll('_', ' ')),
                    onChanged: (enabled) => setDialog(
                      () => enabled!
                          ? channels.add(channel)
                          : channels.remove(channel),
                    ),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: sms,
                  title: const Text('SMS consent'),
                  onChanged: (value) => setDialog(() => sms = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: whatsapp,
                  title: const Text('WhatsApp consent'),
                  onChanged: (value) => setDialog(() => whatsapp = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await widget.service.savePreferences(
                  NotificationPreferences(
                    enabledChannels: channels,
                    quietHoursStart: current.quietHoursStart,
                    quietHoursEnd: current.quietHoursEnd,
                    preferredEmail: current.preferredEmail,
                    preferredPhone: current.preferredPhone,
                    whatsappConsented: whatsapp,
                    smsConsented: sms,
                    pushPermission: current.pushPermission,
                  ),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
