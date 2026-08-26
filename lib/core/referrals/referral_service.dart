import 'dart:math';
import '../network/api_client.dart';
import 'referral_models.dart';

abstract interface class ReferralService {
  Future<ReferralWorkspaceRecord> loadWorkspace();
  Future<ReferralAdminWorkspace> loadAdminWorkspace();
  Future<void> createLink({required String landingPage});
  Future<void> introduce({
    required String name,
    String? email,
    String? phone,
    required String serviceId,
    String? relationship,
    String? note,
  });
  Future<void> requestWithdrawal({
    required int amountMinor,
    required String method,
    required Map<String, String> destination,
  });
  Future<void> review({
    required String category,
    required String id,
    required String decision,
    required String note,
  });
}

class ApiReferralService implements ReferralService {
  const ApiReferralService(this.client);
  final ApiClient client;
  @override
  Future<ReferralWorkspaceRecord> loadWorkspace() async {
    final responses = await Future.wait([
      client.get('/referrals/context'),
      client.get('/referrals/eligible-services'),
      client.get('/referrals/leads'),
      client.get('/referrals/links'),
      client.get('/referrals/wallet'),
      client.get('/referrals/campaigns'),
      client.get('/referrals/analytics'),
    ]);
    final eligible = responses[1]['data'] as Map<String, dynamic>;
    return ReferralWorkspaceRecord(
      context: ReferralMemberContext.fromJson(
        responses[0]['data'] as Map<String, dynamic>,
      ),
      services: (eligible['services'] as List)
          .map(
            (item) =>
                ReferralEligibleService.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      eligibilityNotice: eligible['notice'] as String? ?? '',
      leads: (responses[2]['data'] as List)
          .map(
            (item) => ReferralLeadRecord.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      links: (responses[3]['data'] as List)
          .map(
            (item) => ReferralLinkRecord.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      wallet: ReferralWalletRecord.fromJson(
        responses[4]['data'] as Map<String, dynamic>,
      ),
      campaigns: (responses[5]['data'] as List)
          .map(
            (item) =>
                ReferralCampaignRecord.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      analytics: ReferralAnalyticsRecord.fromJson(
        responses[6]['data'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<ReferralAdminWorkspace> loadAdminWorkspace() async {
    final responses = await Future.wait([
      client.get('/admin/referrals/dashboard'),
      client.get('/admin/referral-services'),
      client.get('/admin/referrals/applications'),
      client.get('/admin/referrals/leads'),
      client.get('/admin/referrals/withdrawals'),
      client.get('/admin/referrals/kyc'),
      client.get('/admin/referrals/fraud-reviews'),
      client.get('/admin/referrals/analytics'),
    ]);
    final dashboard = responses[0]['data'] as Map<String, dynamic>,
        matrix = responses[1]['data'] as Map<String, dynamic>,
        applications = responses[2]['data'] as Map<String, dynamic>;
    final queue = <ReferralAdminQueueItem>[
      ...(applications['expressions_of_interest'] as List).map((item) {
        final row = item as Map<String, dynamic>;
        return ReferralAdminQueueItem(
          id: row['id'] as String,
          title: row['full_name'] as String,
          context: (row['programme'] as Map<String, dynamic>)['name'] as String,
          status: row['status'] as String,
          category: 'interest',
        );
      }),
      ...(responses[3]['data'] as List).map((item) {
        final row = item as Map<String, dynamic>;
        return ReferralAdminQueueItem(
          id: row['id'] as String,
          title: row['prospect_name'] as String,
          context: row['service_interest'] as String? ?? 'STROT service',
          status: row['status'] as String,
          category: 'lead',
        );
      }),
      ...(responses[4]['data'] as List).map((item) {
        final row = item as Map<String, dynamic>;
        return ReferralAdminQueueItem(
          id: row['id'] as String,
          title:
              ((row['member'] as Map<String, dynamic>?)?['name'] as String?) ??
              'Referral member',
          context: '${row['currency']} ${(row['amount_minor'] as int) / 100}',
          status: row['status'] as String,
          category: 'withdrawal',
        );
      }),
      ...(responses[5]['data'] as List).map((item) {
        final row = item as Map<String, dynamic>;
        return ReferralAdminQueueItem(
          id: row['id'] as String,
          title:
              ((row['member'] as Map<String, dynamic>?)?['name'] as String?) ??
              'Referral member',
          context: row['type'] as String,
          status: row['status'] as String,
          category: 'kyc',
        );
      }),
      ...(responses[6]['data'] as List).map((item) {
        final row = item as Map<String, dynamic>,
            lead = row['lead'] as Map<String, dynamic>?;
        return ReferralAdminQueueItem(
          id: row['id'] as String,
          title: lead?['prospect_name'] as String? ?? 'Referral review',
          context: 'Fraud assessment',
          status: row['status'] as String,
          category: 'fraud',
          riskScore: row['risk_score'] as int?,
        );
      }),
    ];
    return ReferralAdminWorkspace(
      metrics: ReferralAdminMetrics.fromJson(
        dashboard['metrics'] as Map<String, dynamic>,
      ),
      programmes: (dashboard['programmes'] as List)
          .map(
            (item) => ReferralProgramme.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      eligibility: (matrix['matrix'] as List).map((item) {
        final row = item as Map<String, dynamic>,
            organization = row['organization'] as Map<String, dynamic>;
        return ReferralEligibilityRow(
          organizationId: organization['id'] as int,
          organizationName: organization['name'] as String,
          organizationType: organization['type'] as String,
          providedServices: (row['provided_services'] as List)
              .map(
                (service) =>
                    (service as Map<String, dynamic>)['name'] as String,
              )
              .toList(),
          excludedCount:
              (row['automatically_excluded_service_ids'] as List).length,
          eligibleCount: (row['eligible_services'] as List).length,
        );
      }).toList(),
      queue: queue,
      analytics: ReferralAnalyticsRecord.fromJson(
        responses[7]['data'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<void> createLink({required String landingPage}) async {
    await client.post('/referrals/links', {'landing_page': landingPage});
  }

  @override
  Future<void> introduce({
    required String name,
    String? email,
    String? phone,
    required String serviceId,
    String? relationship,
    String? note,
  }) async {
    await client.post('/referrals/leads', {
      'prospect_name': name,
      'prospect_email': ?email,
      'prospect_phone': ?phone,
      'service_id': serviceId,
      'referral_category': 'property_opportunity',
      'relationship': ?relationship,
      'note': ?note,
    });
  }

  @override
  Future<void> requestWithdrawal({
    required int amountMinor,
    required String method,
    required Map<String, String> destination,
  }) async {
    await client.post('/referrals/withdrawals', {
      'amount_minor': amountMinor,
      'method': method,
      'destination': destination,
      'idempotency_key':
          'flutter-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}',
    });
  }

  @override
  Future<void> review({
    required String category,
    required String id,
    required String decision,
    required String note,
  }) async {
    final (path, body) = switch (category) {
      'interest' => (
        '/admin/referrals/interests/$id',
        {'status': decision, 'review_note': note},
      ),
      'lead' => (
        '/admin/referrals/leads/$id/status',
        {'status': decision, 'note': note},
      ),
      'withdrawal' => (
        '/admin/referrals/withdrawals/$id',
        {'status': decision, 'review_note': note},
      ),
      'kyc' => (
        '/admin/referrals/kyc/$id',
        {'status': decision, 'review_note': note},
      ),
      'fraud' => (
        '/admin/referrals/fraud-reviews/$id',
        {'decision': decision, 'decision_note': note},
      ),
      _ => throw ArgumentError('Unsupported referral review category.'),
    };
    await client.patch(path, body);
  }
}

class MockReferralService implements ReferralService {
  final introduced = <String>[];
  @override
  Future<ReferralWorkspaceRecord>
  loadWorkspace() async => ReferralWorkspaceRecord(
    context: const ReferralMemberContext(
      accountType: 'service_partner',
      programme: ReferralProgramme(
        id: 'p1',
        key: 'partner_referral',
        name: 'STROT Partner Referrals',
        description: 'Introduce eligible cross-service property opportunities.',
        attributionWindowDays: 90,
      ),
      memberId: 'm1',
      kycStatus: 'verified',
      performanceLevel: 'standard',
      referralCode: 'STROT-PARTNER1',
      capabilities: ['cross_referrals.create'],
    ),
    services: const [
      ReferralEligibleService(
        id: 's1',
        key: 'construction',
        name: 'Construction',
      ),
    ],
    eligibilityNotice:
        'You may earn rewards only for eligible services outside those your organisation provides.',
    leads: [
      ReferralLeadRecord(
        id: 'l1',
        prospectName: 'Chidi Owner',
        prospectContact: 'c***@example.com',
        serviceInterest: 'Construction',
        status: 'prospect_invited',
        createdAt: DateTime(2026, 8, 24),
      ),
    ],
    links: const [
      ReferralLinkRecord(
        id: 'link1',
        shareUrl: 'https://strot.ng/r/example',
        landingPage: '/services',
        visits: 8,
      ),
    ],
    wallet: const ReferralWalletRecord(
      currency: 'NGN',
      pendingMinor: 2500000,
      approvedMinor: 0,
      availableMinor: 5000000,
      paidMinor: 0,
      withheldMinor: 0,
    ),
    campaigns: const [
      ReferralCampaignRecord(
        id: 'c1',
        name: 'Build with confidence',
        description: 'Approved construction referral materials.',
        status: 'active',
        assetCount: 2,
      ),
    ],
    analytics: const ReferralAnalyticsRecord(
      referrals: 1,
      qualified: 0,
      earnedMinor: 0,
      verifiedPaymentBackingMinor: 0,
      currency: 'NGN',
    ),
  );
  @override
  Future<ReferralAdminWorkspace> loadAdminWorkspace() async =>
      const ReferralAdminWorkspace(
        metrics: ReferralAdminMetrics(
          activeMembers: 12,
          openLeads: 4,
          pendingRewardsMinor: 7500000,
          pendingWithdrawals: 1,
        ),
        programmes: [
          ReferralProgramme(
            id: 'p1',
            key: 'refer_strot',
            name: 'Refer STROT',
            description: 'Client referrals.',
            attributionWindowDays: 90,
          ),
        ],
        eligibility: [
          ReferralEligibilityRow(
            organizationId: 2,
            organizationName: 'BuildRight Ltd',
            organizationType: 'partner',
            providedServices: ['Interior design'],
            excludedCount: 3,
            eligibleCount: 8,
          ),
        ],
        queue: [
          ReferralAdminQueueItem(
            id: 'f1',
            title: 'Chidi Owner',
            context: 'Fraud assessment',
            status: 'awaiting_review',
            category: 'fraud',
            riskScore: 65,
          ),
        ],
        analytics: ReferralAnalyticsRecord(
          referrals: 4,
          qualified: 2,
          earnedMinor: 0,
          verifiedPaymentBackingMinor: 15000000,
          currency: 'NGN',
        ),
      );
  @override
  Future<void> createLink({required String landingPage}) async {}
  @override
  Future<void> introduce({
    required String name,
    String? email,
    String? phone,
    required String serviceId,
    String? relationship,
    String? note,
  }) async {
    introduced.add(serviceId);
  }

  @override
  Future<void> requestWithdrawal({
    required int amountMinor,
    required String method,
    required Map<String, String> destination,
  }) async {}
  @override
  Future<void> review({
    required String category,
    required String id,
    required String decision,
    required String note,
  }) async {}
}
