class PaymentScheduleItem {
  const PaymentScheduleItem({
    required this.id,
    required this.label,
    required this.amountDueMinor,
    required this.status,
    this.dueAt,
  });
  final int id, amountDueMinor;
  final String label, status;
  final DateTime? dueAt;
  factory PaymentScheduleItem.fromJson(Map<String, dynamic> value) =>
      PaymentScheduleItem(
        id: value['id'] as int,
        label: value['label'] as String,
        amountDueMinor: value['amount_due_minor'] as int,
        status: value['status'] as String,
        dueAt: value['due_at'] == null
            ? null
            : DateTime.parse(value['due_at'] as String),
      );
}

class BankTransferInstructions {
  const BankTransferInstructions({
    required this.accountId,
    required this.accountName,
    required this.bankName,
    required this.accountNumber,
    required this.paymentReference,
    required this.amountMinor,
    required this.currency,
    required this.notice,
    this.scheduleId,
  });
  final int accountId, amountMinor;
  final int? scheduleId;
  final String accountName,
      bankName,
      accountNumber,
      paymentReference,
      currency,
      notice;
}

class PaymentAttempt {
  const PaymentAttempt({
    required this.id,
    required this.invoiceId,
    required this.amountMinor,
    required this.currency,
    required this.status,
    this.orderReference,
    this.checkoutUrl,
  });
  final String id, status, currency;
  final int invoiceId, amountMinor;
  final String? orderReference, checkoutUrl;
  factory PaymentAttempt.fromJson(Map<String, dynamic> value) => PaymentAttempt(
    id: value['id'].toString(),
    invoiceId: value['invoice_id'] as int,
    amountMinor: value['expected_amount_minor'] as int,
    currency: value['currency'] as String,
    status: value['status'] as String,
    orderReference: value['provider_order_reference'] as String?,
    checkoutUrl: value['checkout_url'] as String?,
  );
}

class ManualPaymentRecord {
  const ManualPaymentRecord({
    required this.id,
    required this.reference,
    required this.status,
    required this.amountMinor,
    required this.currency,
    required this.invoiceId,
    this.reviewNote,
  });
  final String id, reference, status, currency;
  final int amountMinor, invoiceId;
  final String? reviewNote;
  factory ManualPaymentRecord.fromJson(Map<String, dynamic> value) =>
      ManualPaymentRecord(
        id: value['id'].toString(),
        reference: value['reference'] as String,
        status: value['status'] as String,
        amountMinor: value['submitted_amount_minor'] as int,
        currency: value['currency'] as String,
        invoiceId: (value['invoice'] as Map<String, dynamic>)['id'] as int,
        reviewNote: value['review_note'] as String?,
      );
}
