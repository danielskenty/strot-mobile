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
import '../../core/payments/payment_collection_service.dart';
import '../../core/payments/payment_admin_service.dart';
import '../../core/payments/bank_account_service.dart';
import '../payments/payments_screen.dart';
import '../payments/payment_admin_screen.dart';
import '../payments/bank_accounts_screen.dart';
import '../partner/partner_work_screen.dart';
import '../../core/partner/partner_commercial_service.dart';
import '../../core/partner/partner_quotation_service.dart';
import '../../core/partner/partner_assignment_service.dart';
import '../partner/partner_commercial_screen.dart';
import '../provider/provider_operations_screen.dart';
import '../admin/admin_overview_screen.dart';
import '../admin/operations_queue_screen.dart';
import '../admin/organizations_screen.dart';
import '../admin/users_screen.dart';
import '../admin/roles_screen.dart';
import '../admin/projects_screen.dart';
import '../admin/partner_deliverables_screen.dart';
import '../../core/admin/work_order_admin_service.dart';
import '../admin/work_order_admin_screen.dart';
import '../../core/admin/provider_dispatch_service.dart';
import '../admin/provider_dispatch_screen.dart';
import '../../core/admin/provider_integration_admin_service.dart';
import '../admin/provider_integrations_admin_screen.dart';
import '../../core/profile/profile_service.dart';
import '../../core/dashboard/client_overview_service.dart';
import '../../core/dashboard/partner_overview_service.dart';
import '../partner/partner_assignments_screen.dart';
import '../partner/partner_quotations_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/profile/organization_profile_service.dart';
import '../profile/organization_profile_screen.dart';
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
import '../../core/access/access_service.dart';
import '../access/access_admin_screen.dart';
import '../../core/sync/sync_outbox.dart';
import '../sync/sync_recovery_screen.dart';
import '../../core/variations/variation_service.dart';
import '../variations/variations_screen.dart';
import '../../core/inspections/inspection_service.dart';
import '../inspections/inspections_screen.dart';
import '../../core/invoices/invoice_service.dart';
import '../invoices/invoices_screen.dart';
import '../../core/property_care/property_care_service.dart';
import '../../core/property_assets/property_asset_service.dart';
import '../../core/care_plans/care_plan_service.dart';
import '../../core/properties/property_service.dart';
import '../../core/provider/provider_service.dart';
import '../../core/admin/admin_service.dart';
import '../../core/admin/organization_service.dart';
import '../../core/admin/user_directory_service.dart';
import '../../core/admin/role_service.dart';
import '../../core/admin/project_directory_service.dart';
import '../../core/aftercare/aftercare_service.dart';
import '../aftercare/aftercare_screen.dart';
import '../property_care/property_care_screen.dart';
import '../../core/insurance/insurance_service.dart';
import '../insurance/insurance_screen.dart';
import '../../core/consultations/consultation_service.dart';
import '../consultations/consultations_screen.dart';
import '../../core/issues/issue_service.dart';
import '../issues/issues_screen.dart';
import '../../core/project_journal/project_journal_service.dart';
import '../project_journal/project_journal_screen.dart';
import '../../core/smart_property/smart_property_service.dart';
import '../smart_property/smart_property_screen.dart';
import '../../core/property_access/property_access_service.dart';
import '../property_access/property_access_screen.dart';
import '../../core/billing/billing_profile_service.dart';
import '../billing/billing_profiles_screen.dart';
import '../../core/team/team_service.dart';
import '../team/team_screen.dart';
import '../../core/partner/partner_payout_profile_service.dart';
import '../partner/partner_payout_settings_screen.dart';
import '../../core/referrals/referral_service.dart';
import '../referrals/referrals_screen.dart';
import '../referrals/referral_admin_screen.dart';

class PortalShell extends StatefulWidget {
  const PortalShell({super.key, required this.session, this.useMocks});
  final AuthSession session;
  final bool? useMocks;
  @override
  State<PortalShell> createState() => _PortalShellState();
}

class _PortalShellState extends State<PortalShell> {
  int selected = 0;
  static const compactDestinationCount = 4;
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
      icon: Icon(Icons.change_circle_outlined),
      label: 'Variations',
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
      icon: Icon(Icons.receipt_long_outlined),
      label: 'Invoices',
    ),
    NavigationDestination(
      icon: Icon(Icons.engineering_outlined),
      label: 'Operations',
    ),
    NavigationDestination(
      icon: Icon(Icons.fact_check_outlined),
      label: 'Inspections',
    ),
    NavigationDestination(icon: Icon(Icons.forum_outlined), label: 'Messages'),
    NavigationDestination(
      icon: Icon(Icons.notifications_outlined),
      label: 'Notifications',
    ),
    NavigationDestination(
      icon: Icon(Icons.home_work_outlined),
      label: 'Property care',
    ),
    NavigationDestination(
      icon: Icon(Icons.inventory_2_outlined),
      label: 'Aftercare',
    ),
    NavigationDestination(
      icon: Icon(Icons.shield_outlined),
      label: 'Insurance',
    ),
    NavigationDestination(
      icon: Icon(Icons.event_available_outlined),
      label: 'Consultations',
    ),
    NavigationDestination(
      icon: Icon(Icons.report_problem_outlined),
      label: 'Issues & RFIs',
    ),
    NavigationDestination(
      icon: Icon(Icons.auto_stories_outlined),
      label: 'Project journal',
    ),
    NavigationDestination(
      icon: Icon(Icons.sensors_outlined),
      label: 'Smart home',
    ),
    NavigationDestination(
      icon: Icon(Icons.group_outlined),
      label: 'Household & access',
    ),
    NavigationDestination(
      icon: Icon(Icons.account_balance_wallet_outlined),
      label: 'Billing details',
    ),
    NavigationDestination(
      icon: Icon(Icons.diversity_1_outlined),
      label: 'Referrals',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 720;
    final partner = widget.session.roles.contains(StrotRole.partner);
    final provider = widget.session.roles.contains(StrotRole.apiProvider);
    final admin = widget.session.roles.contains(StrotRole.superAdmin);
    final useMocks =
        widget.useMocks ??
        const bool.fromEnvironment('STROT_USE_MOCKS', defaultValue: false);
    final api = ApiClient(
      baseUrl: ApiClient.defaultBaseUrl,
      token: widget.session.token,
    );
    final outbox = SyncOutbox(api, PreferenceSyncStore());
    final projects = useMocks ? MockProjectService() : ApiProjectService(api);
    final approvals = useMocks
        ? MockApprovalService()
        : ApiApprovalService(api);
    final variations = useMocks
        ? MockVariationService()
        : ApiVariationService(api);
    final inspections = useMocks
        ? MockInspectionService()
        : ApiInspectionService(api);
    final invoices = useMocks ? MockInvoiceService() : ApiInvoiceService(api);
    final notifications = useMocks
        ? MockNotificationService()
        : ApiNotificationService(api);
    final operations = useMocks
        ? MockOperationService()
        : ApiOperationService(api, outbox: outbox);
    final messages = useMocks ? MockMessageService() : ApiMessageService(api);
    final security = useMocks ? MockSecurityService() : ApiSecurityService(api);
    final profile = useMocks ? MockProfileService() : ApiProfileService(api);
    final clientOverview = useMocks
        ? MockClientOverviewService()
        : ApiClientOverviewService(api);
    final partnerOverview = useMocks
        ? MockPartnerOverviewService()
        : ApiPartnerOverviewService(api);
    final organizationProfile = useMocks
        ? MockOrganizationProfileService()
        : ApiOrganizationProfileService(api);
    final access = useMocks ? MockAccessService() : ApiAccessService(api);
    final propertyCare = useMocks
        ? MockPropertyCareService()
        : ApiPropertyCareService(api);
    final propertyAssets = useMocks
        ? MockPropertyAssetService()
        : ApiPropertyAssetService(api);
    final carePlans = useMocks
        ? MockCarePlanService()
        : ApiCarePlanService(api);
    final properties = useMocks
        ? MockPropertyService()
        : ApiPropertyService(api);
    final providerService = useMocks
        ? MockProviderService()
        : ApiProviderService(api);
    final adminService = useMocks ? MockAdminService() : ApiAdminService(api);
    final organizationService = useMocks
        ? MockAdminOrganizationService()
        : ApiAdminOrganizationService(api);
    final userDirectoryService = useMocks
        ? MockAdminUserDirectoryService()
        : ApiAdminUserDirectoryService(api);
    final roleService = useMocks
        ? MockAdminRoleService()
        : ApiAdminRoleService(api);
    final adminProjects = useMocks
        ? MockAdminProjectDirectoryService()
        : ApiAdminProjectDirectoryService(api);
    final bankAccounts = useMocks
        ? MockBankAccountService()
        : ApiBankAccountService(api);
    final aftercare = useMocks
        ? MockAftercareService()
        : ApiAftercareService(api);
    final partnerCommercial = useMocks
        ? MockPartnerCommercialService()
        : ApiPartnerCommercialService(api);
    final partnerQuotations = useMocks
        ? MockPartnerQuotationService()
        : ApiPartnerQuotationService(api);
    final partnerAssignments = useMocks
        ? MockPartnerAssignmentService()
        : ApiPartnerAssignmentService(api);
    final insurance = useMocks
        ? MockInsuranceService()
        : ApiInsuranceService(api);
    final consultations = useMocks
        ? MockConsultationService()
        : ApiConsultationService(api);
    final issues = useMocks ? MockIssueService() : ApiIssueService(api);
    final projectJournal = useMocks
        ? MockProjectJournalService()
        : ApiProjectJournalService(api);
    final smartProperties = useMocks
        ? MockSmartPropertyService()
        : ApiSmartPropertyService(api);
    final propertyAccess = useMocks
        ? MockPropertyAccessService()
        : ApiPropertyAccessService(api);
    final billingProfiles = useMocks
        ? MockBillingProfileService()
        : ApiBillingProfileService(api);
    final team = useMocks ? MockTeamService() : ApiTeamService(api);
    final partnerPayoutProfile = useMocks
        ? MockPartnerPayoutProfileService()
        : ApiPartnerPayoutProfileService(api);
    final referrals = useMocks
        ? MockReferralService()
        : ApiReferralService(api);
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
              label: 'Finance',
            ),
            NavigationDestination(
              icon: Icon(Icons.manage_accounts_outlined),
              label: 'Access',
            ),
            NavigationDestination(
              icon: Icon(Icons.forum_outlined),
              label: 'Messages',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              label: 'Notifications',
            ),
            NavigationDestination(
              icon: Icon(Icons.home_work_outlined),
              label: 'Property care',
            ),
            NavigationDestination(
              icon: Icon(Icons.business_outlined),
              label: 'Organizations',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              label: 'Users',
            ),
            NavigationDestination(
              icon: Icon(Icons.policy_outlined),
              label: 'Roles',
            ),
            NavigationDestination(
              icon: Icon(Icons.domain_outlined),
              label: 'Projects',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_outlined),
              label: 'Bank accounts',
            ),
            NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              label: 'Insurance',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'Aftercare',
            ),
            NavigationDestination(
              icon: Icon(Icons.fact_check_outlined),
              label: 'Document review',
            ),
            NavigationDestination(
              icon: Icon(Icons.payments_outlined),
              label: 'Partner payouts',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_outlined),
              label: 'Partner evidence',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              label: 'Work orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.api_outlined),
              label: 'Provider dispatch',
            ),
            NavigationDestination(
              icon: Icon(Icons.hub_outlined),
              label: 'Integrations',
            ),
            NavigationDestination(
              icon: Icon(Icons.report_problem_outlined),
              label: 'Issues & RFIs',
            ),
            NavigationDestination(
              icon: Icon(Icons.diversity_1_outlined),
              label: 'Referral governance',
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
            NavigationDestination(
              icon: Icon(Icons.diversity_1_outlined),
              label: 'Referrals',
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
              label: 'Deliverables',
            ),
            NavigationDestination(
              icon: Icon(Icons.engineering_outlined),
              label: 'Operations',
            ),
            NavigationDestination(
              icon: Icon(Icons.fact_check_outlined),
              label: 'Inspections',
            ),
            NavigationDestination(
              icon: Icon(Icons.forum_outlined),
              label: 'Messages',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              label: 'Notifications',
            ),
            NavigationDestination(
              icon: Icon(Icons.home_work_outlined),
              label: 'Maintenance',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              label: 'Team & roles',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_outlined),
              label: 'Payout settings',
            ),
            NavigationDestination(
              icon: Icon(Icons.diversity_1_outlined),
              label: 'Referrals',
            ),
          ]
        : destinations;
    final content = admin
        ? (selected == 21
              ? ReferralAdminScreen(service: referrals)
              : selected == 20
              ? IssuesScreen(
                  service: issues,
                  projectService: projects,
                  canManage: true,
                  canCreate: false,
                )
              : selected == 19
              ? ProviderIntegrationsAdminScreen(
                  service: useMocks
                      ? MockProviderIntegrationAdminService()
                      : ApiProviderIntegrationAdminService(api),
                )
              : selected == 18
              ? ProviderDispatchScreen(
                  service: useMocks
                      ? MockProviderDispatchService()
                      : ApiProviderDispatchService(api),
                )
              : selected == 17
              ? WorkOrderAdminScreen(
                  service: useMocks
                      ? MockWorkOrderAdminService()
                      : ApiWorkOrderAdminService(api),
                )
              : selected == 16
              ? PartnerDeliverablesScreen(service: partnerCommercial)
              : selected == 15
              ? PartnerCommercialScreen(
                  service: partnerCommercial,
                  financeMode: true,
                )
              : selected == 14
              ? DocumentsScreen(
                  service: useMocks
                      ? MockDocumentService()
                      : ApiDocumentService(api),
                  projectService: projects,
                  reviewMode: true,
                )
              : selected == 13
              ? AftercareScreen(service: aftercare)
              : selected == 12
              ? InsuranceScreen(service: insurance)
              : selected == 11
              ? BankAccountsScreen(service: bankAccounts)
              : selected == 10
              ? AdminProjectsScreen(service: adminProjects)
              : selected == 9
              ? RolesScreen(service: roleService)
              : selected == 8
              ? UsersScreen(service: userDirectoryService)
              : selected == 7
              ? OrganizationsScreen(service: organizationService)
              : selected == 6
              ? PropertyCareScreen(
                  service: propertyCare,
                  assetService: propertyAssets,
                  planService: carePlans,
                  propertyService: properties,
                  canRequest: true,
                )
              : selected == 5
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
              ? MessagesScreen(service: messages, canManage: true)
              : selected == 3
              ? AccessAdminScreen(service: access)
              : selected == 2
              ? PaymentAdminScreen(
                  service: ApiPaymentAdminService(api),
                  api: api,
                )
              : selected == 1
              ? OperationsQueueScreen(service: adminService)
              : AdminOverviewScreen(service: adminService))
        : provider
        ? (selected == 5
              ? ReferralsScreen(service: referrals)
              : selected == 4
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
              : ProviderOperationsScreen(service: providerService))
        : partner
        ? (selected == 10
              ? ReferralsScreen(service: referrals)
              : selected == 9
              ? PartnerPayoutSettingsScreen(
                  service: partnerPayoutProfile,
                  organizationService: organizationProfile,
                )
              : selected == 8
              ? TeamScreen(service: team)
              : selected == 7
              ? PropertyCareScreen(
                  service: propertyCare,
                  assetService: propertyAssets,
                  planService: carePlans,
                  propertyService: properties,
                  canRequest: false,
                  canWork: true,
                )
              : selected == 6
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
              : selected == 5
              ? MessagesScreen(service: messages, canManage: false)
              : selected == 4
              ? InspectionsScreen(service: inspections)
              : selected == 3
              ? OperationsScreen(service: operations, canSubmit: true)
              : selected == 2
              ? PartnerCommercialScreen(service: partnerCommercial)
              : selected == 1
              ? PartnerWorkScreen(
                  quotationService: partnerQuotations,
                  assignmentService: partnerAssignments,
                )
              : _PartnerOverview(
                  service: partnerOverview,
                  onOpen: (action) {
                    final id = int.tryParse(
                      action.category == 'deliverable'
                          ? action.id.split('-').last
                          : action.deepLink.split('/').last,
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => action.category == 'assignment'
                            ? PartnerAssignmentsScreen(
                                service: partnerAssignments,
                                initialId: id,
                              )
                            : action.category == 'quotation'
                            ? PartnerQuotationsScreen(
                                service: partnerQuotations,
                                initialId: id,
                              )
                            : PartnerCommercialScreen(
                                service: partnerCommercial,
                                initialDeliverableId: id,
                              ),
                      ),
                    );
                  },
                ))
        : switch (selected) {
            1 => ProjectsScreen(service: projects),
            2 => ApprovalsScreen(service: approvals),
            3 => VariationsScreen(service: variations),
            4 => DocumentsScreen(
              service: useMocks
                  ? MockDocumentService()
                  : ApiDocumentService(api),
              projectService: projects,
            ),
            5 => PaymentsScreen(
              service: useMocks ? MockPaymentService() : ApiPaymentService(api),
            ),
            6 => InvoicesScreen(
              service: invoices,
              paymentService: ApiPaymentCollectionService(api),
            ),
            7 => OperationsScreen(service: operations, canSubmit: false),
            8 => InspectionsScreen(service: inspections),
            9 => MessagesScreen(service: messages, canManage: false),
            11 => PropertyCareScreen(
              service: propertyCare,
              assetService: propertyAssets,
              planService: carePlans,
              propertyService: properties,
              canRequest: true,
            ),
            12 => AftercareScreen(service: aftercare),
            13 => InsuranceScreen(service: insurance),
            14 => ConsultationsScreen(service: consultations),
            15 => IssuesScreen(
              service: issues,
              projectService: projects,
              canManage: false,
              canCreate: true,
            ),
            16 => ProjectJournalScreen(
              service: projectJournal,
              onOpen: (deepLink) => _openNotification(
                StrotNotification(
                  id: deepLink,
                  category: 'project_journal',
                  priority: 'informational',
                  title: 'Project journal record',
                  body: 'Open the exact certified project record.',
                  actionUrl: deepLink,
                  actionRequired: false,
                  readAt: DateTime.now(),
                  resolvedAt: null,
                  createdAt: DateTime.now(),
                ),
                projects,
                approvals,
                api,
                useMocks,
                operations,
                messages,
              ),
            ),
            17 => SmartPropertiesScreen(service: smartProperties),
            18 => PropertyAccessScreen(
              service: propertyAccess,
              propertyService: properties,
            ),
            19 => BillingProfilesScreen(
              service: billingProfiles,
              organizationService: organizationProfile,
            ),
            20 => ReferralsScreen(service: referrals),
            10 => NotificationsScreen(
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
            _ => _Overview(
              session: widget.session,
              service: clientOverview,
              onOpen: (action) => _openNotification(
                StrotNotification(
                  id: action.id,
                  category: action.category,
                  priority: action.priority,
                  title: action.title,
                  body: action.context,
                  actionUrl: action.deepLink,
                  actionRequired: true,
                  readAt: null,
                  resolvedAt: null,
                  createdAt: DateTime.now(),
                ),
                projects,
                approvals,
                api,
                useMocks,
                operations,
                messages,
              ),
            ),
          };
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.organization),
        actions: [
          _AccessibleAppBarAction(
            label: 'Organization details',
            icon: const Icon(Icons.business_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    OrganizationProfileScreen(service: organizationProfile),
              ),
            ),
          ),
          _AccessibleAppBarAction(
            label: 'Profile and contact details',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProfileScreen(service: profile),
              ),
            ),
          ),
          _AccessibleAppBarAction(
            label: 'Synchronisation status',
            icon: const Icon(Icons.sync_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SyncRecoveryScreen(outbox: outbox),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: StrotSpacing.md),
            child: _AccessibleAppBarAction(
              label: 'Account security',
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
                LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: NavigationRail(
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
                      ),
                    ),
                  ),
                ),
                Expanded(child: content),
              ],
            )
          : content,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: selected < compactDestinationCount
                  ? selected
                  : compactDestinationCount,
              onDestinationSelected: (value) {
                if (value == compactDestinationCount) {
                  _showDestinationPicker(activeDestinations);
                  return;
                }
                setState(() => selected = value);
              },
              destinations: [
                ...activeDestinations.take(compactDestinationCount),
                const NavigationDestination(
                  icon: Icon(Icons.menu),
                  selectedIcon: Icon(Icons.menu_open),
                  label: 'More',
                ),
              ],
            ),
    );
  }

  Future<void> _showDestinationPicker(
    List<NavigationDestination> destinations,
  ) async {
    final destination = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: StrotColors.cream,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(StrotSpacing.lg),
                child: Text(
                  'All workspace areas',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: destinations.length,
                  itemBuilder: (context, index) {
                    final item = destinations[index];
                    return ListTile(
                      selected: selected == index,
                      leading: selected == index
                          ? item.selectedIcon
                          : item.icon,
                      title: Text(item.label),
                      onTap: () => Navigator.of(context).pop(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (destination != null && mounted) {
      setState(() => selected = destination);
    }
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
    final uri = Uri.parse(item.actionUrl ?? '');
    final segments = uri.pathSegments;
    final referralLink = segments.length >= 2 && segments[1] == 'referrals';
    final adminReferralLink =
        segments.length >= 3 &&
        segments[1] == 'admin' &&
        segments[2] == 'referrals';
    if ((referralLink || adminReferralLink) && mounted) {
      final service = useMocks
          ? MockReferralService()
          : ApiReferralService(api);
      final exact = uri.queryParameters.entries
          .where(
            (entry) => [
              'interest',
              'lead',
              'withdrawal',
              'kyc',
              'fraud',
            ].contains(entry.key),
          )
          .firstOrNull;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => adminReferralLink
              ? ReferralAdminScreen(
                  service: service,
                  initialCategory: exact?.key,
                  initialId: exact?.value,
                )
              : ReferralsScreen(
                  service: service,
                  initialLeadId: uri.queryParameters['lead'],
                ),
        ),
      );
      return;
    }
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
        (segments[1] == 'payments' ||
            segments[1] == 'documents' ||
            segments[1] == 'evidence')) {
      final id = int.tryParse(segments[2]);
      if (id != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => LinkedNotificationItemScreen(
              client: api,
              kind: segments[1] == 'evidence' ? 'documents' : segments[1],
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
    if (segments.length >= 3 && segments[1] == 'consultations') {
      final id = int.tryParse(segments[2]);
      if (id != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ConsultationsScreen(
              service: useMocks
                  ? MockConsultationService()
                  : ApiConsultationService(api),
              initialId: id,
            ),
          ),
        );
        return;
      }
    }
    if (segments.length >= 3 && segments[1] == 'issues') {
      final id = int.tryParse(segments[2]);
      if (id != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => IssuesScreen(
              service: useMocks ? MockIssueService() : ApiIssueService(api),
              projectService: projects,
              canManage: widget.session.roles.contains(StrotRole.superAdmin),
              canCreate: false,
              initialId: id,
            ),
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

class _AccessibleAppBarAction extends StatelessWidget {
  const _AccessibleAppBarAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    onTap: onPressed,
    excludeSemantics: true,
    child: IconButton(tooltip: label, icon: icon, onPressed: onPressed),
  );
}

class _Overview extends StatelessWidget {
  const _Overview({required this.session, required this.service, this.onOpen});
  final AuthSession session;
  final ClientOverviewService service;
  final ValueChanged<ClientOverviewAction>? onOpen;
  @override
  Widget build(BuildContext context) => FutureBuilder<ClientOverviewRecord>(
    future: service.load(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final data = snapshot.requireData;
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'CLIENT WORKSPACE',
            style: TextStyle(
              color: StrotColors.goldText,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(
            'Good day, ${session.name.split(' ').first}.',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: StrotSpacing.sm),
          const Text(
            'Live delivery, decision and finance actions across your projects.',
          ),
          const SizedBox(height: StrotSpacing.xl),
          Wrap(
            spacing: StrotSpacing.md,
            runSpacing: StrotSpacing.md,
            children: [
              _Metric(
                label: 'Active projects',
                value: '${data.activeProjects}',
              ),
              _Metric(
                label: 'Pending decisions',
                value: '${data.pendingApprovals}',
              ),
              _Metric(
                label: 'Outstanding invoices',
                value:
                    '${data.currency} ${(data.outstandingInvoiceMinor / 100).toStringAsFixed(0)}',
              ),
              _Metric(
                label: 'Document readiness',
                value: '${data.documentReadinessPercent}%',
              ),
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
                  if (data.actions.isEmpty)
                    const Text(
                      'You are up to date. No actions require attention.',
                    ),
                  ...data.actions.map(
                    (action) => ListTile(
                      onTap: onOpen == null ? null : () => onOpen!(action),
                      contentPadding: EdgeInsets.zero,
                      title: Text(action.title),
                      subtitle: Text(
                        '${action.context} · ${action.priority.replaceAll('_', ' ')}',
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _PartnerOverview extends StatelessWidget {
  const _PartnerOverview({required this.service, required this.onOpen});
  final PartnerOverviewService service;
  final ValueChanged<PartnerOverviewAction> onOpen;
  @override
  Widget build(BuildContext context) => FutureBuilder<PartnerOverviewRecord>(
    future: service.load(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final data = snapshot.requireData;
      return ListView(
        padding: const EdgeInsets.all(StrotSpacing.lg),
        children: [
          const Text(
            'PARTNER WORKSPACE',
            style: TextStyle(
              color: StrotColors.goldText,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: StrotSpacing.md),
          Text(
            'Delivery command centre',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: StrotSpacing.sm),
          const Text(
            'Live assignments, submissions and payout readiness for your organization.',
          ),
          const SizedBox(height: StrotSpacing.xl),
          Wrap(
            spacing: StrotSpacing.md,
            runSpacing: StrotSpacing.md,
            children: [
              _Metric(
                label: 'Active work orders',
                value: '${data.activeWorkOrders}',
              ),
              _Metric(
                label: 'Pending assignments',
                value: '${data.pendingAssignments}',
              ),
              _Metric(
                label: 'Deliverables in review',
                value: '${data.deliverablesInReview}',
              ),
              _Metric(
                label: 'Pending payout',
                value:
                    '${data.currency} ${(data.pendingPayoutMinor / 100).toStringAsFixed(0)}',
              ),
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
                  if (data.actions.isEmpty)
                    const Text(
                      'No partner action currently requires attention.',
                    ),
                  ...data.actions.map(
                    (action) => ListTile(
                      onTap: () => onOpen(action),
                      contentPadding: EdgeInsets.zero,
                      title: Text(action.title),
                      subtitle: Text(
                        '${action.context} · ${action.priority.replaceAll('_', ' ')}',
                      ),
                      trailing: const Icon(Icons.arrow_forward),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
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
