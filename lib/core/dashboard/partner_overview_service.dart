import '../network/api_client.dart';

class PartnerOverviewAction {
  const PartnerOverviewAction({
    required this.id,
    required this.category,
    required this.title,
    required this.context,
    required this.priority,
    required this.deepLink,
  });
  final String id, category, title, context, priority, deepLink;
  factory PartnerOverviewAction.fromJson(Map<String, dynamic> json) =>
      PartnerOverviewAction(
        id: json['id'] as String,
        category: json['category'] as String,
        title: json['title'] as String,
        context: json['context'] as String,
        priority: json['priority'] as String,
        deepLink: json['deep_link'] as String,
      );
}

class PartnerOverviewRecord {
  const PartnerOverviewRecord({
    required this.activeWorkOrders,
    required this.pendingAssignments,
    required this.deliverablesInReview,
    required this.pendingPayoutMinor,
    required this.currency,
    required this.actions,
  });
  final int activeWorkOrders,
      pendingAssignments,
      deliverablesInReview,
      pendingPayoutMinor;
  final String currency;
  final List<PartnerOverviewAction> actions;
  factory PartnerOverviewRecord.fromJson(Map<String, dynamic> json) {
    final m = json['metrics'] as Map<String, dynamic>;
    return PartnerOverviewRecord(
      activeWorkOrders: m['active_work_orders'] as int,
      pendingAssignments: m['pending_assignments'] as int,
      deliverablesInReview: m['deliverables_in_review'] as int,
      pendingPayoutMinor: m['pending_payout_minor'] as int,
      currency: m['currency'] as String,
      actions: (json['priority_actions'] as List)
          .map((x) => PartnerOverviewAction.fromJson(x as Map<String, dynamic>))
          .toList(),
    );
  }
}

abstract interface class PartnerOverviewService {
  Future<PartnerOverviewRecord> load();
}

class ApiPartnerOverviewService implements PartnerOverviewService {
  const ApiPartnerOverviewService(this.client);
  final ApiClient client;
  @override
  Future<PartnerOverviewRecord> load() async => PartnerOverviewRecord.fromJson(
    (await client.get('/partner-overview'))['data'] as Map<String, dynamic>,
  );
}

class MockPartnerOverviewService implements PartnerOverviewService {
  @override
  Future<PartnerOverviewRecord> load() async => const PartnerOverviewRecord(
    activeWorkOrders: 3,
    pendingAssignments: 1,
    deliverablesInReview: 2,
    pendingPayoutMinor: 45000000,
    currency: 'NGN',
    actions: [
      PartnerOverviewAction(
        id: 'work-order-1',
        category: 'assignment',
        title: 'Review joinery package',
        context: 'STR-OAK · Oak Residence',
        priority: 'action_required',
        deepLink: '/portal/work-orders/1',
      ),
    ],
  );
}
