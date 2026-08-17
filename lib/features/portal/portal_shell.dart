import 'package:flutter/material.dart';
import '../../core/auth/auth_models.dart';
import '../../design_system/strot_tokens.dart';
import '../../core/projects/project_service.dart';
import '../projects/projects_screen.dart';
import '../../core/approvals/approval_service.dart';
import '../approvals/approvals_screen.dart';
import '../../core/documents/document_service.dart';
import '../documents/documents_screen.dart';
import '../../core/payments/payment_service.dart';
import '../payments/payments_screen.dart';
import '../partner/partner_work_screen.dart';
import '../provider/provider_operations_screen.dart';
import '../admin/admin_overview_screen.dart';
import '../../core/network/api_client.dart';
import '../../core/notifications/notification_models.dart';
import '../../core/notifications/notification_service.dart';
import '../notifications/notifications_screen.dart';
import '../notifications/linked_item_screen.dart';
import '../../core/operations/operation_service.dart';
import '../operations/operations_screen.dart';
import '../../core/messages/message_service.dart';
import '../messages/messages_screen.dart';
import '../../core/security/security_service.dart';
import '../security/security_screen.dart';

class PortalShell extends StatefulWidget {
  const PortalShell({super.key, required this.session});
  final AuthSession session;
  @override
  State<PortalShell> createState() => _PortalShellState();
}

class _PortalShellState extends State<PortalShell> {
  int selected = 0;
  static const destinations = [
    NavigationDestination(
      icon: Icon(Icons.space_dashboard_outlined),
      selectedIcon: Icon(Icons.space_dashboard),
      label: 'Overview',
    ),
    NavigationDestination(
      icon: Icon(Icons.apartment_outlined),
      label: 'Projects',
    ),
    NavigationDestination(
      icon: Icon(Icons.approval_outlined),
      label: 'Approvals',
    ),
    NavigationDestination(
      icon: Icon(Icons.folder_outlined),
      label: 'Documents',
    ),
    NavigationDestination(
      icon: Icon(Icons.payments_outlined),
      label: 'Payments',
    ),
    NavigationDestination(
      icon: Icon(Icons.engineering_outlined),
      label: 'Operations',
    ),
    NavigationDestination(icon: Icon(Icons.forum_outlined), label: 'Messages'),
    NavigationDestination(
      icon: Icon(Icons.notifications_outlined),
      label: 'Notifications',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    final partner = widget.session.roles.contains(StrotRole.partner);
    final provider = widget.session.roles.contains(StrotRole.apiProvider);
    final admin = widget.session.roles.contains(StrotRole.superAdmin);
    final useMocks = const bool.fromEnvironment(
      'STROT_USE_MOCKS',
      defaultValue: false,
    );
    final api = ApiClient(
      baseUrl: ApiClient.defaultBaseUrl,
      token: widget.session.token,
    );
    final projects = useMocks ? MockProjectService() : ApiProjectService(api);
    final approvals = useMocks
        ? MockApprovalService()
        : ApiApprovalService(api);
    final notifications = useMocks
        ? MockNotificationService()
        : ApiNotificationService(api);
    final operations = useMocks
        ? MockOperationService()
        : ApiOperationService(api);
    final messages = useMocks ? MockMessageService() : ApiMessageService(api);
    final security = useMocks ? MockSecurityService() : ApiSecurityService(api);
    final activeDestinations = admin
        ? const [
            NavigationDestination(
              icon: Icon(Icons.space_dashboard_outlined),
              label: 'Overview',
            ),
            NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined),
              label: 'Operations',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              label: 'Governance',
            ),
            NavigationDestination(
              icon: Icon(Icons.forum_outlined),
              label: 'Messages',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              label: 'Notifications',
            ),
          ]
        : provider
        ? const [
            NavigationDestination(
              icon: Icon(Icons.space_dashboard_outlined),
              label: 'Overview',
            ),
            NavigationDestination(
              icon: Icon(Icons.api_outlined),
              label: 'Requests',
            ),
            NavigationDestination(
              icon: Icon(Icons.monitor_heart_outlined),
              label: 'Integrations',
            ),
            NavigationDestination(
              icon: Icon(Icons.forum_outlined),
              label: 'Messages',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              label: 'Notifications',
            ),
          ]
        : partner
        ? const [
            NavigationDestination(
              icon: Icon(Icons.space_dashboard_outlined),
              label: 'Overview',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              label: 'Work orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.upload_file_outlined),
              label: 'Evidence',
            ),
            NavigationDestination(
              icon: Icon(Icons.engineering_outlined),
              label: 'Operations',
            ),
            NavigationDestination(
              icon: Icon(Icons.forum_outlined),
              label: 'Messages',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              label: 'Notifications',
            ),
          ]
        : destinations;
    final content = admin
        ? (selected == 4
              ? NotificationsScreen(
                  service: notifications,
                  onOpen: (item) => _openNotification(
                    item,
                    projects,
                    approvals,
                    api,
                    useMocks,
                    operations,
                    messages,
                  ),
                )
              : selected == 3
              ? MessagesScreen(service: messages, canManage: true)
              : const AdminOverviewScreen())
        : provider
        ? (selected == 4
              ? NotificationsScreen(
                  service: notifications,
                  onOpen: (item) => _openNotification(
                    item,
                    projects,
                    approvals,
                    api,
                    useMocks,
                    operations,
                    messages,
                  ),
                )
              : selected == 3
              ? MessagesScreen(service: messages, canManage: false)
              : const ProviderOperationsScreen())
        : partner
        ? (selected == 5
              ? NotificationsScreen(
                  service: notifications,
                  onOpen: (item) => _openNotification(
                    item,
                    projects,
                    approvals,
                    api,
                    useMocks,
                    operations,
                    messages,
                  ),
                )
              : selected == 4
              ? MessagesScreen(service: messages, canManage: false)
              : selected == 3
              ? OperationsScreen(service: operations, canSubmit: true)
              : selected == 1
              ? const PartnerWorkScreen()
              : _Overview(session: widget.session))
        : switch (selected) {
            1 => ProjectsScreen(service: projects),
            2 => ApprovalsScreen(service: approvals),
            3 => DocumentsScreen(service: MockDocumentService()),
            4 => PaymentsScreen(service: MockPaymentService()),
            5 => OperationsScreen(service: operations, canSubmit: false),
            6 => MessagesScreen(service: messages, canManage: false),
            7 => NotificationsScreen(
              service: notifications,
              onOpen: (item) => _openNotification(
                item,
                projects,
                approvals,
                api,
                useMocks,
                operations,
                messages,
              ),
            ),
            _ => _Overview(session: widget.session),
          };
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.organization),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: StrotSpacing.md),
            child: IconButton(
              tooltip: 'Account security',
              icon: const Icon(Icons.verified_user_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SecurityScreen(service: security),
                ),
              ),
            ),
          ),
        ],
      ),
      body: wide
          ? Row(
              children: [
                NavigationRail(
                  backgroundColor: StrotColors.forest,
                  indicatorColor: StrotColors.goldMuted,
                  selectedIconTheme: const IconThemeData(
                    color: StrotColors.gold,
                  ),
                  unselectedIconTheme: const IconThemeData(
                    color: StrotColors.cream,
                  ),
                  selectedLabelTextStyle: const TextStyle(
                    color: StrotColors.gold,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    color: StrotColors.cream,
                  ),
                  extended: MediaQuery.sizeOf(context).width >= 1100,
                  selectedIndex: selected,
                  onDestinationSelected: (value) =>
                      setState(() => selected = value),
                  destinations: activeDestinations
                      .map(
                        (item) => NavigationRailDestination(
                          icon: item.icon,
                          selectedIcon: item.selectedIcon,
                          label: Text(item.label),
                        ),
                      )
                      .toList(),
                ),
                Expanded(child: content),
              ],
            )
          : content,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: selected,
              onDestinationSelected: (value) =>
                  setState(() => selected = value),
              destinations: activeDestinations,
            ),
    );
  }

  Future<void> _openNotification(
    StrotNotification item,
    ProjectService projects,
    ApprovalService approvals,
    ApiClient api,
    bool useMocks,
    OperationService operations,
    MessageService messages,
  ) async {
    final segments = Uri.parse(item.actionUrl ?? '').pathSegments;
    if (segments.length >= 3 && segments[1] == 'approvals') {
      final id = int.tryParse(segments[2]);
      final matches = await approvals.list();
      final approval = matches.where((value) => value.id == id).firstOrNull;
      if (approval != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                ApprovalReviewScreen(approval: approval, service: approvals),
          ),
        );
        return;
      }
    }
    if (segments.length >= 3 && segments[1] == 'projects') {
      final id = int.tryParse(segments[2]);
      if (id != null) {
        final project = await projects.get(id);
        if (mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ProjectOverviewScreen(project: project),
            ),
          );
          return;
        }
      }
    }
    if (segments.length >= 3 &&
        (segments[1] == 'payments' || segments[1] == 'documents')) {
      final id = int.tryParse(segments[2]);
      if (id != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => LinkedNotificationItemScreen(
              client: api,
              kind: segments[1],
              id: id,
              useMocks: useMocks,
            ),
          ),
        );
        return;
      }
    }
    if (segments.length >= 3 && segments[1] == 'tasks') {
      final id = int.tryParse(segments[2]);
      if (id != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TaskDetailScreen(taskId: id, service: operations),
          ),
        );
        return;
      }
    }
    if (segments.length >= 3 && segments[1] == 'site-reports') {
      final id = int.tryParse(segments[2]);
      if (id != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                SiteReportDetailScreen(reportId: id, service: operations),
          ),
        );
        return;
      }
    }
    if (segments.length >= 3 && segments[1] == 'messages') {
      final id = int.tryParse(segments[2]);
      if (id != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ConversationScreen(
              id: id,
              service: messages,
              canManage: widget.session.permissions.contains('support.manage'),
            ),
          ),
        );
        return;
      }
    }
    if (segments.length >= 2 && segments[1] == 'payments' && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PaymentsScreen(service: MockPaymentService()),
        ),
      );
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The linked item is no longer available.'),
        ),
      );
    }
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.session});
  final AuthSession session;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(StrotSpacing.lg),
    children: [
      const Text(
        'MONDAY, 17 AUGUST',
        style: TextStyle(
          color: StrotColors.gold,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
      const SizedBox(height: StrotSpacing.md),
      Text(
        'Good morning, ${session.name.split(' ').first}.',
        style: Theme.of(context).textTheme.displayMedium,
      ),
      const SizedBox(height: StrotSpacing.sm),
      const Text('Here is what needs your attention across Oak Residence.'),
      const SizedBox(height: StrotSpacing.xl),
      Wrap(
        spacing: StrotSpacing.md,
        runSpacing: StrotSpacing.md,
        children: const [
          _Metric(label: 'Active projects', value: '01'),
          _Metric(label: 'Pending decisions', value: '02'),
          _Metric(label: 'Verified evidence', value: '68%'),
        ],
      ),
      const SizedBox(height: StrotSpacing.xl),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(StrotSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Priority actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(height: StrotSpacing.xl),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Approve revised scope of work'),
                subtitle: Text('Oak Residence · Version 2.1'),
                trailing: Icon(Icons.arrow_forward),
              ),
              const Divider(),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Confirm site inspection payment'),
                subtitle: Text('Inspection scheduled after confirmation'),
                trailing: Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 210,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: StrotSpacing.lg),
            Text(value, style: Theme.of(context).textTheme.displayMedium),
          ],
        ),
      ),
    ),
  );
}
