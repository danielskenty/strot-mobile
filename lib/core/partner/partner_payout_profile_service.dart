import '../network/api_client.dart';

class PartnerPayoutProfile {
  const PartnerPayoutProfile({
    required this.id,
    required this.organizationId,
    required this.beneficiaryName,
    required this.bankName,
    required this.currency,
    required this.status,
    required this.accountNumberMasked,
    this.organizationName,
    this.bankCode,
    this.taxType,
    this.taxIdentifierMasked,
    this.verifiedAt,
  });
  final int id, organizationId;
  final String beneficiaryName, bankName, currency, status, accountNumberMasked;
  final String? organizationName,
      bankCode,
      taxType,
      taxIdentifierMasked,
      verifiedAt;
  factory PartnerPayoutProfile.fromJson(Map<String, dynamic> json) =>
      PartnerPayoutProfile(
        id: json['id'] as int,
        organizationId: json['organization_id'] as int,
        beneficiaryName: json['beneficiary_name'] as String,
        bankName: json['bank_name'] as String,
        currency: json['currency'] as String,
        status: json['status'] as String,
        accountNumberMasked: json['account_number_masked'] as String,
        organizationName:
            (json['organization'] as Map<String, dynamic>?)?['name'] as String?,
        bankCode: json['bank_code'] as String?,
        taxType: json['tax_type'] as String?,
        taxIdentifierMasked: json['tax_identifier_masked'] as String?,
        verifiedAt: json['verified_at'] as String?,
      );
}

class PartnerPayoutProfileInput {
  const PartnerPayoutProfileInput({
    required this.organizationId,
    required this.beneficiaryName,
    required this.bankName,
    required this.accountNumber,
    required this.currency,
    required this.taxType,
    this.bankCode,
    this.taxIdentifier,
  });
  final int organizationId;
  final String beneficiaryName, bankName, accountNumber, currency, taxType;
  final String? bankCode, taxIdentifier;
  Map<String, dynamic> toJson() => {
    'organization_id': organizationId,
    'beneficiary_name': beneficiaryName,
    'bank_name': bankName,
    'account_number': accountNumber,
    'bank_code': bankCode,
    'currency': currency,
    'tax_type': taxType,
    'tax_identifier': taxIdentifier,
  };
}

abstract interface class PartnerPayoutProfileService {
  Future<List<PartnerPayoutProfile>> list();
  Future<void> save(PartnerPayoutProfileInput input);
}

class ApiPartnerPayoutProfileService implements PartnerPayoutProfileService {
  const ApiPartnerPayoutProfileService(this.client);
  final ApiClient client;
  @override
  Future<List<PartnerPayoutProfile>> list() async =>
      ((await client.get('/partner/payout-profile'))['data'] as List)
          .map(
            (item) =>
                PartnerPayoutProfile.fromJson(item as Map<String, dynamic>),
          )
          .toList();
  @override
  Future<void> save(PartnerPayoutProfileInput input) =>
      client.post('/partner/payout-profile', input.toJson());
}

class MockPartnerPayoutProfileService implements PartnerPayoutProfileService {
  int? savedOrganizationId;
  @override
  Future<List<PartnerPayoutProfile>> list() async => const [
    PartnerPayoutProfile(
      id: 1,
      organizationId: 2,
      beneficiaryName: 'BuildRight Limited',
      bankName: 'Example Bank',
      currency: 'NGN',
      status: 'pending_review',
      accountNumberMasked: '•••• 6789',
      organizationName: 'BuildRight Ltd',
      bankCode: '999',
      taxType: 'company',
      taxIdentifierMasked: '•••• 5678',
    ),
  ];
  @override
  Future<void> save(PartnerPayoutProfileInput input) async {
    savedOrganizationId = input.organizationId;
  }
}
