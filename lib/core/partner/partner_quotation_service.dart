import '../network/api_client.dart';

class PartnerQuotationRecord {
  const PartnerQuotationRecord({
    required this.id,
    required this.amountMinor,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.projectReference,
    required this.projectName,
    required this.workTitle,
    required this.workDescription,
    this.reviewNote,
  });
  final int id, amountMinor;
  final String currency,
      status,
      createdAt,
      projectReference,
      projectName,
      workTitle,
      workDescription;
  final String? reviewNote;
  factory PartnerQuotationRecord.fromJson(Map<String, dynamic> json) {
    final project = json['project'] as Map<String, dynamic>?;
    final work = json['work_order'] as Map<String, dynamic>?;
    return PartnerQuotationRecord(
      id: json['id'] as int,
      amountMinor: json['amount_minor'] as int,
      currency: json['currency'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      projectReference: project?['reference'] as String? ?? 'Unassigned',
      projectName: project?['name'] as String? ?? 'Project',
      workTitle: work?['title'] as String? ?? 'Work order',
      workDescription: work?['description'] as String? ?? '',
      reviewNote: json['review_note'] as String?,
    );
  }
}

abstract interface class PartnerQuotationService {
  Future<List<PartnerQuotationRecord>> list();
}

class ApiPartnerQuotationService implements PartnerQuotationService {
  ApiPartnerQuotationService(this.client);
  final ApiClient client;
  @override
  Future<List<PartnerQuotationRecord>> list() async =>
      ((await client.get('/partner/quotations'))['data'] as List)
          .map(
            (item) =>
                PartnerQuotationRecord.fromJson(item as Map<String, dynamic>),
          )
          .toList();
}

class MockPartnerQuotationService implements PartnerQuotationService {
  @override
  Future<List<PartnerQuotationRecord>> list() async => const [
    PartnerQuotationRecord(
      id: 1,
      amountMinor: 12500000,
      currency: 'NGN',
      status: 'submitted',
      createdAt: '2026-08-21T10:00:00Z',
      projectReference: 'STR-24001',
      projectName: 'Oak Residence',
      workTitle: 'Structural blockwork',
      workDescription: 'Complete blockwork to approved drawings.',
    ),
  ];
}
