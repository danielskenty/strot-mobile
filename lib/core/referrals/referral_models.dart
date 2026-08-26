class ReferralProgramme {
  const ReferralProgramme({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    required this.attributionWindowDays,
  });
  final String id, key, name, description;
  final int attributionWindowDays;
  factory ReferralProgramme.fromJson(Map<String, dynamic> json) =>
      ReferralProgramme(
        id: json['id'] as String,
        key: json['key'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        attributionWindowDays: json['attribution_window_days'] as int? ?? 0,
      );
}

class ReferralMemberContext {
  const ReferralMemberContext({
    required this.accountType,
    required this.programme,
    required this.memberId,
    required this.kycStatus,
    required this.performanceLevel,
    required this.referralCode,
    required this.capabilities,
  });
  final String accountType, memberId, kycStatus, performanceLevel, referralCode;
  final ReferralProgramme programme;
  final List<String> capabilities;
  factory ReferralMemberContext.fromJson(Map<String, dynamic> json) {
    final member = json['member'] as Map<String, dynamic>;
    return ReferralMemberContext(
      accountType: json['account_type'] as String,
      programme: ReferralProgramme.fromJson(
        json['programme'] as Map<String, dynamic>,
      ),
      memberId: member['id'] as String,
      kycStatus: member['kyc_status'] as String? ?? 'not_submitted',
      performanceLevel: member['performance_level'] as String? ?? 'standard',
      referralCode: member['referral_code'] as String,
      capabilities: (json['capabilities'] as List).cast<String>(),
    );
  }
}

class ReferralEligibleService {
  const ReferralEligibleService({
    required this.id,
    required this.key,
    required this.name,
  });
  final String id, key, name;
  factory ReferralEligibleService.fromJson(Map<String, dynamic> json) =>
      ReferralEligibleService(
        id: json['id'] as String,
        key: json['key'] as String,
        name: json['name'] as String,
      );
}

class ReferralLeadRecord {
  const ReferralLeadRecord({
    required this.id,
    required this.prospectName,
    required this.prospectContact,
    required this.serviceInterest,
    required this.status,
    required this.createdAt,
  });
  final String id, prospectName, prospectContact, serviceInterest, status;
  final DateTime createdAt;
  factory ReferralLeadRecord.fromJson(Map<String, dynamic> json) =>
      ReferralLeadRecord(
        id: json['id'] as String,
        prospectName: json['prospect_name'] as String,
        prospectContact: json['prospect_contact'] as String,
        serviceInterest: json['service_interest'] as String? ?? 'STROT service',
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class ReferralLinkRecord {
  const ReferralLinkRecord({
    required this.id,
    required this.shareUrl,
    required this.landingPage,
    required this.visits,
    this.expiresAt,
  });
  final String id, shareUrl, landingPage;
  final int visits;
  final DateTime? expiresAt;
  factory ReferralLinkRecord.fromJson(Map<String, dynamic> json) =>
      ReferralLinkRecord(
        id: json['id'] as String,
        shareUrl: json['share_url'] as String,
        landingPage: json['landing_page'] as String,
        visits: json['visits'] as int? ?? 0,
        expiresAt: json['expires_at'] == null
            ? null
            : DateTime.parse(json['expires_at'] as String),
      );
}

class ReferralWalletRecord {
  const ReferralWalletRecord({
    required this.currency,
    required this.pendingMinor,
    required this.approvedMinor,
    required this.availableMinor,
    required this.paidMinor,
    required this.withheldMinor,
  });
  final String currency;
  final int pendingMinor,
      approvedMinor,
      availableMinor,
      paidMinor,
      withheldMinor;
  factory ReferralWalletRecord.fromJson(Map<String, dynamic> json) {
    final balances = json['balances'] as Map<String, dynamic>;
    return ReferralWalletRecord(
      currency: json['currency'] as String,
      pendingMinor: balances['pending_minor'] as int? ?? 0,
      approvedMinor: balances['approved_minor'] as int? ?? 0,
      availableMinor: balances['available_minor'] as int? ?? 0,
      paidMinor: balances['paid_minor'] as int? ?? 0,
      withheldMinor: balances['withheld_minor'] as int? ?? 0,
    );
  }
}

class ReferralCampaignRecord {
  const ReferralCampaignRecord({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.assetCount,
  });
  final String id, name, description, status;
  final int assetCount;
  factory ReferralCampaignRecord.fromJson(Map<String, dynamic> json) =>
      ReferralCampaignRecord(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        status: json['status'] as String,
        assetCount: (json['assets'] as List? ?? const []).length,
      );
}

class ReferralAnalyticsRecord {
  const ReferralAnalyticsRecord({
    required this.referrals,
    required this.qualified,
    required this.earnedMinor,
    required this.verifiedPaymentBackingMinor,
    required this.currency,
  });
  final int referrals, qualified, earnedMinor, verifiedPaymentBackingMinor;
  final String currency;
  factory ReferralAnalyticsRecord.fromJson(Map<String, dynamic> json) {
    final metrics = json['metrics'] as Map<String, dynamic>;
    return ReferralAnalyticsRecord(
      referrals: metrics['referrals'] as int? ?? 0,
      qualified: metrics['qualified'] as int? ?? 0,
      earnedMinor: metrics['earned_minor'] as int? ?? 0,
      verifiedPaymentBackingMinor:
          metrics['verified_payment_backing_minor'] as int? ?? 0,
      currency: metrics['currency'] as String? ?? 'NGN',
    );
  }
}

class ReferralWorkspaceRecord {
  const ReferralWorkspaceRecord({
    required this.context,
    required this.services,
    required this.eligibilityNotice,
    required this.leads,
    required this.links,
    required this.wallet,
    required this.campaigns,
    required this.analytics,
  });
  final ReferralMemberContext context;
  final List<ReferralEligibleService> services;
  final String eligibilityNotice;
  final List<ReferralLeadRecord> leads;
  final List<ReferralLinkRecord> links;
  final ReferralWalletRecord wallet;
  final List<ReferralCampaignRecord> campaigns;
  final ReferralAnalyticsRecord analytics;
}

class ReferralAdminMetrics {
  const ReferralAdminMetrics({
    required this.activeMembers,
    required this.openLeads,
    required this.pendingRewardsMinor,
    required this.pendingWithdrawals,
  });
  final int activeMembers, openLeads, pendingRewardsMinor, pendingWithdrawals;
  factory ReferralAdminMetrics.fromJson(Map<String, dynamic> json) =>
      ReferralAdminMetrics(
        activeMembers: json['active_members'] as int,
        openLeads: json['open_leads'] as int,
        pendingRewardsMinor: json['pending_rewards_minor'] as int,
        pendingWithdrawals: json['pending_withdrawals'] as int,
      );
}

class ReferralAdminQueueItem {
  const ReferralAdminQueueItem({
    required this.id,
    required this.title,
    required this.context,
    required this.status,
    required this.category,
    this.riskScore,
  });
  final String id, title, context, status, category;
  final int? riskScore;
}

class ReferralEligibilityRow {
  const ReferralEligibilityRow({
    required this.organizationId,
    required this.organizationName,
    required this.organizationType,
    required this.providedServices,
    required this.excludedCount,
    required this.eligibleCount,
  });
  final int organizationId, excludedCount, eligibleCount;
  final String organizationName, organizationType;
  final List<String> providedServices;
}

class ReferralAdminWorkspace {
  const ReferralAdminWorkspace({
    required this.metrics,
    required this.programmes,
    required this.eligibility,
    required this.queue,
    required this.analytics,
  });
  final ReferralAdminMetrics metrics;
  final List<ReferralProgramme> programmes;
  final List<ReferralEligibilityRow> eligibility;
  final List<ReferralAdminQueueItem> queue;
  final ReferralAnalyticsRecord analytics;
}
