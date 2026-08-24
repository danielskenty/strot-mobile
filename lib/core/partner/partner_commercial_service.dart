import '../network/api_client.dart';

class PartnerCommercialRecord {
  const PartnerCommercialRecord({
    required this.deliverables,
    required this.invoices,
  });
  final List<PartnerDeliverable> deliverables;
  final List<PartnerInvoice> invoices;
}

class PartnerDeliverable {
  const PartnerDeliverable({
    required this.id,
    required this.reference,
    required this.title,
    required this.summary,
    required this.status,
    required this.workOrder,
    required this.evidenceCount,
    required this.mediaAssetIds,
    this.reviewNote,
    this.partnerName,
  });
  final String reference, title, summary, status, workOrder;
  final int id, evidenceCount;
  final List<String> mediaAssetIds;
  final String? reviewNote, partnerName;
  factory PartnerDeliverable.fromJson(
    Map<String, dynamic> json,
  ) => PartnerDeliverable(
    id: json['id'] as int,
    reference: json['reference'] as String,
    title: json['title'] as String,
    summary: json['summary'] as String,
    status: json['status'] as String,
    workOrder: (json['work_order'] as Map<String, dynamic>)['title'] as String,
    evidenceCount: (json['media_asset_ids'] as List).length,
    mediaAssetIds: (json['media_asset_ids'] as List).cast<String>(),
    reviewNote: json['review_note'] as String?,
    partnerName:
        ((json['work_order'] as Map<String, dynamic>)['partner_organization']
                as Map<String, dynamic>?)?['name']
            as String?,
  );
}

class PartnerInvoice {
  const PartnerInvoice({
    required this.id,
    required this.reference,
    required this.invoiceNumber,
    required this.amountMinor,
    required this.currency,
    required this.status,
    required this.workOrder,
    this.partnerName,
    this.payout,
  });
  final String reference, invoiceNumber, currency, status, workOrder;
  final int id, amountMinor;
  final String? partnerName;
  final PartnerPayout? payout;
  factory PartnerInvoice.fromJson(Map<String, dynamic> json) {
    final payouts = json['payouts'] as List;
    return PartnerInvoice(
      id: json['id'] as int,
      reference: json['reference'] as String,
      invoiceNumber: json['partner_invoice_number'] as String,
      amountMinor: json['amount_minor'] as int,
      currency: json['currency'] as String,
      status: json['status'] as String,
      workOrder:
          (json['work_order'] as Map<String, dynamic>)['title'] as String,
      partnerName:
          (json['partner_organization'] as Map<String, dynamic>?)?['name']
              as String?,
      payout: payouts.isEmpty
          ? null
          : PartnerPayout.fromJson(payouts.first as Map<String, dynamic>),
    );
  }
}

class PartnerPayout {
  const PartnerPayout({
    required this.reference,
    required this.status,
    this.scheduledFor,
    this.paymentReference,
  });
  final String reference, status;
  final String? scheduledFor, paymentReference;
  factory PartnerPayout.fromJson(Map<String, dynamic> json) => PartnerPayout(
    reference: json['reference'] as String,
    status: json['status'] as String,
    scheduledFor: json['scheduled_for'] as String?,
    paymentReference: json['payment_reference'] as String?,
  );
}

abstract interface class PartnerCommercialService {
  Future<PartnerCommercialRecord> load();
  Future<void> reviewInvoice(
    int id,
    String status, {
    String? scheduledFor,
    String? paymentReference,
  });
  Future<void> reviewDeliverable(int id, String status, String? note);
  Future<void> reviseDeliverable(
    int id,
    String summary,
    List<String> mediaAssetIds,
  );
}

class ApiPartnerCommercialService implements PartnerCommercialService {
  const ApiPartnerCommercialService(this.client);
  final ApiClient client;
  @override
  Future<PartnerCommercialRecord> load() async {
    final data =
        (await client.get('/partner/commercial'))['data']
            as Map<String, dynamic>;
    return PartnerCommercialRecord(
      deliverables: (data['deliverables'] as List)
          .map(
            (item) => PartnerDeliverable.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      invoices: (data['invoices'] as List)
          .map((item) => PartnerInvoice.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<void> reviewInvoice(
    int id,
    String status, {
    String? scheduledFor,
    String? paymentReference,
  }) async {
    final payload = <String, dynamic>{'status': status};
    if (scheduledFor != null) payload['scheduled_for'] = scheduledFor;
    if (paymentReference != null) {
      payload['payment_reference'] = paymentReference;
    }
    await client.patch('/admin/partner-invoices/$id', payload);
  }

  @override
  Future<void> reviewDeliverable(int id, String status, String? note) async {
    await client.patch('/admin/partner-deliverables/$id', {
      'status': status,
      'review_note': note,
    });
  }

  @override
  Future<void> reviseDeliverable(
    int id,
    String summary,
    List<String> mediaAssetIds,
  ) async {
    await client.patch('/partner/deliverables/$id', {
      'summary': summary,
      'media_asset_ids': mediaAssetIds,
    });
  }
}

class MockPartnerCommercialService implements PartnerCommercialService {
  @override
  Future<void> reviewDeliverable(int id, String status, String? note) async {}
  @override
  Future<void> reviseDeliverable(
    int id,
    String summary,
    List<String> mediaAssetIds,
  ) async {}
  @override
  Future<void> reviewInvoice(
    int id,
    String status, {
    String? scheduledFor,
    String? paymentReference,
  }) async {}

  @override
  Future<PartnerCommercialRecord> load() async => const PartnerCommercialRecord(
    deliverables: [
      PartnerDeliverable(
        id: 1,
        reference: 'DEL-8M2P1',
        title: 'First-fix evidence',
        summary: 'Installation evidence submitted for review.',
        status: 'submitted',
        workOrder: 'Electrical first fix',
        evidenceCount: 4,
        mediaAssetIds: ['00000000-0000-0000-0000-000000000001'],
        partnerName: 'Build Partner',
      ),
    ],
    invoices: [
      PartnerInvoice(
        id: 1,
        reference: 'PINV-4C9K2',
        invoiceNumber: 'VENDOR-104',
        amountMinor: 35000000,
        currency: 'NGN',
        status: 'scheduled',
        workOrder: 'Electrical first fix',
        partnerName: 'Build Partner',
        payout: PartnerPayout(
          reference: 'PAY-104',
          status: 'scheduled',
          scheduledFor: '2026-08-25',
        ),
      ),
    ],
  );
}
