import '../network/api_client.dart';

class AdminPaymentReview {
  const AdminPaymentReview({
    required this.id,
    required this.reference,
    required this.status,
    required this.amountMinor,
    required this.expectedMinor,
    required this.currency,
    required this.senderName,
    required this.invoiceReference,
    required this.projectReference,
    this.senderBank,
    this.bankReference,
    this.reviewNote,
    this.proofId,
    this.proofName,
  });
  final String id,
      reference,
      status,
      currency,
      senderName,
      invoiceReference,
      projectReference;
  final int amountMinor, expectedMinor;
  final String? senderBank, bankReference, reviewNote, proofId, proofName;
  factory AdminPaymentReview.fromJson(Map<String, dynamic> value) {
    final invoice = value['invoice'] as Map<String, dynamic>;
    final project = invoice['project'] as Map<String, dynamic>;
    final proof = value['proof'] as Map<String, dynamic>?;
    return AdminPaymentReview(
      id: value['id'].toString(),
      reference: value['reference'] as String,
      status: value['status'] as String,
      amountMinor: value['submitted_amount_minor'] as int,
      expectedMinor: value['expected_amount_minor'] as int,
      currency: value['currency'] as String,
      senderName: value['sender_name'] as String,
      invoiceReference: invoice['reference'] as String,
      projectReference: project['reference'] as String,
      senderBank: value['sender_bank'] as String?,
      bankReference: value['bank_transaction_reference'] as String?,
      reviewNote: value['review_note'] as String?,
      proofId: proof?['id']?.toString(),
      proofName: proof?['original_filename'] as String?,
    );
  }
}

class AdminPaymentRefund {
  const AdminPaymentRefund({
    required this.id,
    required this.reference,
    required this.status,
    required this.amountMinor,
    required this.currency,
    required this.reason,
    required this.invoiceReference,
    required this.projectReference,
    this.providerReference,
  });
  final int id, amountMinor;
  final String reference,
      status,
      currency,
      reason,
      invoiceReference,
      projectReference;
  final String? providerReference;
  factory AdminPaymentRefund.fromJson(Map<String, dynamic> value) {
    final transaction = value['transaction'] as Map<String, dynamic>;
    final invoice = transaction['invoice'] as Map<String, dynamic>;
    final project = invoice['project'] as Map<String, dynamic>;
    return AdminPaymentRefund(
      id: value['id'] as int,
      reference: value['reference'] as String,
      status: value['status'] as String,
      amountMinor: value['amount_minor'] as int,
      currency: value['currency'] as String,
      reason: value['reason'] as String,
      invoiceReference: invoice['reference'] as String,
      projectReference: project['reference'] as String,
      providerReference: value['provider_reference'] as String?,
    );
  }
}

abstract interface class PaymentAdminService {
  Future<List<AdminPaymentReview>> reviews({String? status});
  Future<AdminPaymentReview> review(String id);
  Future<void> decide(
    String id,
    String action, {
    required String note,
    int? confirmedAmountMinor,
    String? bankCreditDate,
    String? confirmedReference,
    bool declaration = false,
  });
  Future<List<AdminPaymentRefund>> refunds();
  Future<void> transitionRefund(
    int id,
    String status, {
    String? providerReference,
  });
}

class ApiPaymentAdminService implements PaymentAdminService {
  ApiPaymentAdminService(this.client);
  final ApiClient client;
  @override
  Future<List<AdminPaymentReview>> reviews({String? status}) async {
    final suffix = status == null
        ? ''
        : '?status=${Uri.encodeQueryComponent(status)}';
    final page =
        (await client.get('/admin/payment-reviews$suffix'))['data']
            as Map<String, dynamic>;
    return (page['data'] as List<dynamic>)
        .map(
          (item) => AdminPaymentReview.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<AdminPaymentReview> review(String id) async =>
      AdminPaymentReview.fromJson(
        (await client.get('/admin/payment-reviews/$id'))['data']
            as Map<String, dynamic>,
      );
  @override
  Future<void> decide(
    String id,
    String action, {
    required String note,
    int? confirmedAmountMinor,
    String? bankCreditDate,
    String? confirmedReference,
    bool declaration = false,
  }) async {
    await client.post('/admin/payment-reviews/$id', {
      'action': action,
      'review_note': note,
      'confirmed_amount_minor': confirmedAmountMinor,
      'bank_credit_date': bankCreditDate,
      'confirmed_bank_reference': confirmedReference,
      'confirmation_declaration': declaration,
    });
  }

  @override
  Future<List<AdminPaymentRefund>> refunds() async {
    final page =
        (await client.get('/admin/payment-refunds'))['data']
            as Map<String, dynamic>;
    return (page['data'] as List<dynamic>)
        .map(
          (item) => AdminPaymentRefund.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> transitionRefund(
    int id,
    String status, {
    String? providerReference,
  }) async {
    await client.patch('/admin/payment-refunds/$id', {
      'status': status,
      'provider_reference': providerReference,
    });
  }
}
