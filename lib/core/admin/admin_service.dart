import '../network/api_client.dart';

class AdminQuotation {
  const AdminQuotation({
    required this.id,
    required this.reference,
    required this.title,
    required this.partnerBaseMinor,
    required this.currency,
    required this.status,
    this.clientTotalMinor,
  });
  final int id, partnerBaseMinor;
  final int? clientTotalMinor;
  final String reference, title, currency, status;
}

class AdminOverviewData {
  const AdminOverviewData({required this.metrics, required this.quotations});
  final Map<String, int> metrics;
  final List<AdminQuotation> quotations;
}

class CommercialDashboardData {
  const CommercialDashboardData({
    required this.summary,
    required this.policies,
  });
  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> policies;
}

class OperationsQueueItem {
  const OperationsQueueItem({
    required this.id,
    required this.category,
    required this.priority,
    required this.title,
    required this.context,
    required this.deepLink,
  });
  final String id, category, priority, title, context, deepLink;
}

class GlobalSearchItem {
  const GlobalSearchItem({
    required this.type,
    required this.title,
    required this.context,
    required this.status,
    required this.deepLink,
  });
  final String type, title, context, status, deepLink;
}

class AuditRecordItem {
  const AuditRecordItem({
    required this.id,
    required this.event,
    required this.record,
    required this.actor,
    required this.occurredAt,
  });
  final String id, event, record, actor, occurredAt;
}

class SystemHealthData {
  const SystemHealthData({required this.status, required this.components});
  final String status;
  final List<Map<String, dynamic>> components;
}

class AdminReportData {
  const AdminReportData({required this.range, required this.metrics});
  final Map<String, dynamic> range, metrics;
}

abstract interface class AdminService {
  Future<AdminOverviewData> overview();
  Future<void> review(
    int id,
    String decision, {
    int? clientTotalMinor,
    String? note,
  });
  Future<CommercialDashboardData> commercialDashboard();
  Future<void> createPolicy(Map<String, dynamic> input);
  Future<void> activatePolicy(int id);
  Future<List<OperationsQueueItem>> operationsQueue();
  Future<List<GlobalSearchItem>> search(String query);
  Future<List<AuditRecordItem>> auditEvents();
  Future<SystemHealthData> systemHealth();
  Future<AdminReportData> report();
}

class ApiAdminService implements AdminService {
  ApiAdminService(this.client);
  final ApiClient client;
  @override
  Future<AdminOverviewData> overview() async {
    final data =
        (await client.get('/admin/overview'))['data'] as Map<String, dynamic>;
    final rawMetrics = data['metrics'] as Map<String, dynamic>;
    return AdminOverviewData(
      metrics: rawMetrics.map((key, value) => MapEntry(key, value as int)),
      quotations: (data['commercial_reviews'] as List).map((value) {
        final item = value as Map<String, dynamic>;
        final project = item['project'] as Map<String, dynamic>?;
        final work = item['work_order'] as Map<String, dynamic>?;
        return AdminQuotation(
          id: item['id'] as int,
          reference: project?['reference'] as String? ?? 'Unassigned',
          title: work?['title'] as String? ?? 'Partner quotation',
          partnerBaseMinor: item['partner_base_minor'] as int,
          clientTotalMinor: item['client_total_minor'] as int?,
          currency: item['currency'] as String,
          status: item['status'] as String,
        );
      }).toList(),
    );
  }

  @override
  Future<void> review(
    int id,
    String decision, {
    int? clientTotalMinor,
    String? note,
  }) async => client.patch('/admin/commercial/quotations/$id', {
    'decision': decision,
    ...clientTotalMinor == null
        ? const <String, dynamic>{}
        : {'client_total_minor': clientTotalMinor},
    ...note == null ? const <String, dynamic>{} : {'review_note': note},
  });

  @override
  Future<CommercialDashboardData> commercialDashboard() async {
    final data =
        (await client.get('/admin/commercial'))['data'] as Map<String, dynamic>;
    return CommercialDashboardData(
      summary: data['summary'] as Map<String, dynamic>,
      policies: (data['policies'] as List).cast<Map<String, dynamic>>(),
    );
  }

  @override
  Future<void> createPolicy(Map<String, dynamic> input) async =>
      client.post('/admin/commercial/policies', input);

  @override
  Future<void> activatePolicy(int id) async =>
      client.patch('/admin/commercial/policies/$id', {'active': true});
  @override
  Future<List<OperationsQueueItem>> operationsQueue() async {
    final data =
        (await client.get('/admin/operations-queue'))['data']
            as Map<String, dynamic>;
    return (data['items'] as List).map((value) {
      final item = value as Map<String, dynamic>;
      return OperationsQueueItem(
        id: item['id'] as String,
        category: item['category'] as String,
        priority: item['priority'] as String,
        title: item['title'] as String,
        context: item['context'] as String? ?? 'Platform',
        deepLink: item['deep_link'] as String,
      );
    }).toList();
  }

  @override
  Future<List<GlobalSearchItem>> search(String query) async {
    final data =
        (await client.get(
              '/admin/search?query=${Uri.encodeQueryComponent(query)}',
            ))['data']
            as Map<String, dynamic>;
    return (data['results'] as List).map((value) {
      final item = value as Map<String, dynamic>;
      return GlobalSearchItem(
        type: item['type'] as String,
        title: item['title'] as String,
        context: item['context'] as String? ?? 'Platform',
        status: item['status'] as String? ?? 'recorded',
        deepLink: item['deep_link'] as String,
      );
    }).toList();
  }

  @override
  Future<List<AuditRecordItem>> auditEvents() async {
    final response = await client.get('/admin/audit-events');
    return (response['data'] as List).map((value) {
      final item = value as Map<String, dynamic>,
          actor = item['actor'] as Map<String, dynamic>?;
      return AuditRecordItem(
        id: item['id'] as String,
        event: item['event'] as String,
        record: '${item['record_type']} #${item['record_id']}',
        actor: actor?['name'] as String? ?? 'System',
        occurredAt: item['occurred_at'] as String? ?? '—',
      );
    }).toList();
  }

  @override
  Future<SystemHealthData> systemHealth() async {
    final data =
        (await client.get('/admin/system-health'))['data']
            as Map<String, dynamic>;
    return SystemHealthData(
      status: data['status'] as String,
      components: (data['components'] as List).cast<Map<String, dynamic>>(),
    );
  }

  @override
  Future<AdminReportData> report() async {
    final data =
        (await client.get('/admin/reports'))['data'] as Map<String, dynamic>;
    return AdminReportData(
      range: data['range'] as Map<String, dynamic>,
      metrics: data['metrics'] as Map<String, dynamic>,
    );
  }
}

class MockAdminService implements AdminService {
  @override
  Future<AdminOverviewData> overview() async => const AdminOverviewData(
    metrics: {
      'active_projects': 24,
      'active_organizations': 18,
      'users': 73,
      'pending_approvals': 9,
    },
    quotations: [
      AdminQuotation(
        id: 1,
        reference: 'STR-24001',
        title: 'Structural blockwork',
        partnerBaseMinor: 10000000,
        currency: 'NGN',
        status: 'submitted',
      ),
    ],
  );
  @override
  Future<void> review(
    int id,
    String decision, {
    int? clientTotalMinor,
    String? note,
  }) async {}
  @override
  Future<CommercialDashboardData> commercialDashboard() async =>
      const CommercialDashboardData(
        summary: {
          'client_revenue_minor': 12500000,
          'partner_base_minor': 10000000,
          'gross_margin_minor': 2500000,
          'gross_margin_basis_points': 2000,
          'approved_count': 1,
          'pending_count': 1,
          'currency': 'NGN',
        },
        policies: [],
      );
  @override
  Future<void> createPolicy(Map<String, dynamic> input) async {}
  @override
  Future<void> activatePolicy(int id) async {}
  @override
  Future<List<OperationsQueueItem>> operationsQueue() async => const [
    OperationsQueueItem(
      id: 'approval-1',
      category: 'approvals',
      priority: 'urgent',
      title: 'Approve revised scope',
      context: 'STR-24001',
      deepLink: '/portal/approvals/1',
    ),
  ];
  @override
  Future<List<GlobalSearchItem>> search(String query) async => const [
    GlobalSearchItem(
      type: 'projects',
      title: 'Oak Residence',
      context: 'STR-24001',
      status: 'active',
      deepLink: '/portal/projects/1',
    ),
  ];
  @override
  Future<List<AuditRecordItem>> auditEvents() async => const [
    AuditRecordItem(
      id: 'audit-1',
      event: 'project.updated',
      record: 'Project #1',
      actor: 'STROT Admin',
      occurredAt: '2026-08-21T10:00:00Z',
    ),
  ];
  @override
  Future<SystemHealthData> systemHealth() async => const SystemHealthData(
    status: 'operational',
    components: [
      {
        'name': 'PostgreSQL system of record',
        'status': 'operational',
        'metric': 'Connected',
      },
    ],
  );
  @override
  Future<AdminReportData> report() async => const AdminReportData(
    range: {'from': '2026-08-01', 'to': '2026-08-21'},
    metrics: {
      'projects_created': 4,
      'active_projects': 24,
      'invoices_issued': 8,
      'invoice_total_minor': 50000000,
      'invoice_paid_minor': 30000000,
      'pending_approvals': 3,
      'provider_requests': 5,
      'notification_failures': 0,
      'currency': 'NGN',
    },
  );
}
