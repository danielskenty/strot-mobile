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
    required this.reference,
    required this.title,
    required this.summary,
    required this.status,
    required this.workOrder,
    required this.evidenceCount,
  });
  final String reference, title, summary, status, workOrder;
  final int evidenceCount;
  factory PartnerDeliverable.fromJson(Map<String, dynamic> json) =>
      PartnerDeliverable(
        reference: json['reference'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String,
        status: json['status'] as String,
        workOrder:
            (json['work_order'] as Map<String, dynamic>)['title'] as String,
        evidenceCount: (json['media_asset_ids'] as List).length,
      );
}

class PartnerInvoice {
  const PartnerInvoice({
    required this.reference,
    required this.invoiceNumber,
    required this.amountMinor,
    required this.currency,
    required this.status,
    required this.workOrder,
    this.payout,
  });
  final String reference, invoiceNumber, currency, status, workOrder;
  final int amountMinor;
  final PartnerPayout? payout;
  factory PartnerInvoice.fromJson(Map<String, dynamic> json) {
    final payouts = json['payouts'] as List;
    return PartnerInvoice(
      reference: json['reference'] as String,
      invoiceNumber: json['partner_invoice_number'] as String,
      amountMinor: json['amount_minor'] as int,
      currency: json['currency'] as String,
      status: json['status'] as String,
      workOrder:
          (json['work_order'] as Map<String, dynamic>)['title'] as String,
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
}

class MockPartnerCommercialService implements PartnerCommercialService {
  @override
  Future<PartnerCommercialRecord> load() async => const PartnerCommercialRecord(
    deliverables: [
      PartnerDeliverable(
        reference: 'DEL-8M2P1',
        title: 'First-fix evidence',
        summary: 'Installation evidence submitted for review.',
        status: 'submitted',
        workOrder: 'Electrical first fix',
        evidenceCount: 4,
      ),
    ],
    invoices: [
      PartnerInvoice(
        reference: 'PINV-4C9K2',
        invoiceNumber: 'VENDOR-104',
        amountMinor: 35000000,
        currency: 'NGN',
        status: 'scheduled',
        workOrder: 'Electrical first fix',
        payout: PartnerPayout(
          reference: 'PAY-104',
          status: 'scheduled',
          scheduledFor: '2026-08-25',
        ),
      ),
    ],
  );
}
