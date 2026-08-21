import '../network/api_client.dart';

class InsuranceClaim {
  const InsuranceClaim({
    required this.id,
    required this.reference,
    required this.incidentType,
    required this.occurredAt,
    required this.status,
    this.providerClaimNumber,
    this.statusNote,
  });
  final int id;
  final String reference, incidentType, occurredAt, status;
  final String? providerClaimNumber, statusNote;
  factory InsuranceClaim.fromJson(Map<String, dynamic> json) => InsuranceClaim(
    id: json['id'] as int,
    reference: json['reference'] as String,
    incidentType: json['incident_type'] as String,
    occurredAt: json['occurred_at'] as String,
    status: json['status'] as String,
    providerClaimNumber: json['provider_claim_number'] as String?,
    statusNote: json['status_note'] as String?,
  );
}

class InsurancePolicy {
  const InsurancePolicy({
    required this.id,
    required this.reference,
    required this.provider,
    required this.coverageType,
    required this.coverageSummary,
    required this.status,
    required this.propertyName,
    required this.claims,
    this.providerPolicyNumber,
    this.expiresOn,
  });
  final int id;
  final String reference,
      provider,
      coverageType,
      coverageSummary,
      status,
      propertyName;
  final String? providerPolicyNumber, expiresOn;
  final List<InsuranceClaim> claims;
  factory InsurancePolicy.fromJson(
    Map<String, dynamic> json,
  ) => InsurancePolicy(
    id: json['id'] as int,
    reference: json['reference'] as String,
    provider: json['provider'] as String,
    coverageType: json['coverage_type'] as String,
    coverageSummary: json['coverage_summary'] as String,
    status: json['status'] as String,
    propertyName: (json['property'] as Map<String, dynamic>)['name'] as String,
    providerPolicyNumber: json['provider_policy_number'] as String?,
    expiresOn: json['expires_on'] as String?,
    claims: (json['claims'] as List)
        .map((item) => InsuranceClaim.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}

abstract interface class InsuranceService {
  Future<List<InsurancePolicy>> list();
}

class ApiInsuranceService implements InsuranceService {
  const ApiInsuranceService(this.client);
  final ApiClient client;
  @override
  Future<List<InsurancePolicy>> list() async =>
      ((await client.get('/insurance'))['data'] as List)
          .map((item) => InsurancePolicy.fromJson(item as Map<String, dynamic>))
          .toList();
}

class MockInsuranceService implements InsuranceService {
  @override
  Future<List<InsurancePolicy>> list() async => const [
    InsurancePolicy(
      id: 1,
      reference: 'INS-OAK-01',
      provider: 'Licensed Insurance Provider',
      coverageType: 'Building all risks',
      coverageSummary:
          'Building protection subject to the insurer-issued policy wording and exclusions.',
      status: 'active',
      propertyName: 'Oak Residence',
      providerPolicyNumber: 'POL-1004',
      expiresOn: '2027-07-31',
      claims: [],
    ),
  ];
}
