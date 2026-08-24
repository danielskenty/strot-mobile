import '../network/api_client.dart';
import 'billing_profile_models.dart';

abstract interface class BillingProfileService {
  Future<List<BillingProfileRecord>> list();
  Future<void> create(BillingProfileInput input);
  Future<void> archive(int id);
}

class ApiBillingProfileService implements BillingProfileService {
  const ApiBillingProfileService(this.client);
  final ApiClient client;
  @override
  Future<List<BillingProfileRecord>> list() async =>
      ((await client.get('/billing-profiles'))['data'] as List)
          .map(
            (item) =>
                BillingProfileRecord.fromJson(item as Map<String, dynamic>),
          )
          .toList();
  @override
  Future<void> create(BillingProfileInput input) =>
      client.post('/billing-profiles', input.toJson());
  @override
  Future<void> archive(int id) =>
      client.post('/billing-profiles/$id/archive', const {});
}

class MockBillingProfileService implements BillingProfileService {
  int? createdOrganizationId, archivedId;
  @override
  Future<List<BillingProfileRecord>> list() async => const [
    BillingProfileRecord(
      id: 1,
      organizationId: 1,
      label: 'Primary billing',
      identityType: 'company',
      legalName: 'Oak Residence Limited',
      billingEmail: 'billing@example.com',
      addressLineOne: '12 Marina Road',
      city: 'Lagos',
      state: 'Lagos',
      countryCode: 'NG',
      isDefault: true,
      status: 'active',
      organizationName: 'Oak Residence',
      taxIdentifier: 'TIN-1234',
    ),
    BillingProfileRecord(
      id: 2,
      organizationId: 1,
      label: 'Site office',
      identityType: 'company',
      legalName: 'Oak Residence Limited',
      billingEmail: 'projects@example.com',
      addressLineOne: '8 Admiralty Way',
      city: 'Lagos',
      countryCode: 'NG',
      isDefault: false,
      status: 'active',
      organizationName: 'Oak Residence',
    ),
  ];
  @override
  Future<void> create(BillingProfileInput input) async {
    createdOrganizationId = input.organizationId;
  }

  @override
  Future<void> archive(int id) async {
    archivedId = id;
  }
}
