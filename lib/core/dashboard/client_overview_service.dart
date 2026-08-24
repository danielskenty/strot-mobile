import '../network/api_client.dart';

class ClientOverviewAction {
  const ClientOverviewAction({
    required this.id,
    required this.category,
    required this.title,
    required this.context,
    required this.priority,
    required this.deepLink,
  });
  final String id, category, title, context, priority, deepLink;
  factory ClientOverviewAction.fromJson(Map<String, dynamic> json) =>
      ClientOverviewAction(
        id: json['id'] as String,
        category: json['category'] as String,
        title: json['title'] as String,
        context: json['context'] as String,
        priority: json['priority'] as String,
        deepLink: json['deep_link'] as String,
      );
}

class ClientOverviewRecord {
  const ClientOverviewRecord({
    required this.activeProjects,
    required this.pendingApprovals,
    required this.outstandingInvoiceMinor,
    required this.currency,
    required this.documentReadinessPercent,
    required this.actions,
  });
  final int activeProjects,
      pendingApprovals,
      outstandingInvoiceMinor,
      documentReadinessPercent;
  final String currency;
  final List<ClientOverviewAction> actions;
  factory ClientOverviewRecord.fromJson(Map<String, dynamic> json) {
    final metrics = json['metrics'] as Map<String, dynamic>;
    return ClientOverviewRecord(
      activeProjects: metrics['active_projects'] as int,
      pendingApprovals: metrics['pending_approvals'] as int,
      outstandingInvoiceMinor: metrics['outstanding_invoice_minor'] as int,
      currency: metrics['currency'] as String,
      documentReadinessPercent: metrics['document_readiness_percent'] as int,
      actions: (json['priority_actions'] as List)
          .map((x) => ClientOverviewAction.fromJson(x as Map<String, dynamic>))
          .toList(),
    );
  }
}

abstract interface class ClientOverviewService {
  Future<ClientOverviewRecord> load();
}

class ApiClientOverviewService implements ClientOverviewService {
  const ApiClientOverviewService(this.client);
  final ApiClient client;
  @override
  Future<ClientOverviewRecord> load() async => ClientOverviewRecord.fromJson(
    (await client.get('/client-overview'))['data'] as Map<String, dynamic>,
  );
}

class MockClientOverviewService implements ClientOverviewService {
  @override
  Future<ClientOverviewRecord> load() async => const ClientOverviewRecord(
    activeProjects: 1,
    pendingApprovals: 2,
    outstandingInvoiceMinor: 75000000,
    currency: 'NGN',
    documentReadinessPercent: 68,
    actions: [
      ClientOverviewAction(
        id: 'approval-1',
        category: 'approval',
        title: 'Approve revised scope of work',
        context: 'STR-OAK · Oak Residence',
        priority: 'action_required',
        deepLink: '/portal/approvals/1',
      ),
    ],
  );
}
