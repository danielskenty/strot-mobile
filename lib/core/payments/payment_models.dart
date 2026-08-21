class PaymentSummary {
  const PaymentSummary({
    required this.approvedMinor,
    required this.paidMinor,
    required this.outstandingMinor,
  });
  final int approvedMinor, paidMinor, outstandingMinor;
}

class StrotPayment {
  const StrotPayment({
    required this.id,
    required this.label,
    required this.amountMinor,
    required this.currency,
    required this.status,
    this.date,
    this.reference,
  });
  final String label, status, currency;
  final int id, amountMinor;
  final DateTime? date;
  final String? reference;
}

class PaymentReceipt {
  const PaymentReceipt({
    required this.status,
    this.receiptNumber,
    this.amountMinor,
    this.currency,
    this.paymentMethod,
    this.transactionReference,
    this.remainingBalanceMinor,
    this.issuedAt,
    this.downloadPath,
  });
  final String status;
  final String? receiptNumber,
      currency,
      paymentMethod,
      transactionReference,
      downloadPath;
  final int? amountMinor, remainingBalanceMinor;
  final DateTime? issuedAt;
  factory PaymentReceipt.fromJson(Map<String, dynamic> value) => PaymentReceipt(
    status: value['status'] as String,
    receiptNumber: value['receipt_number'] as String?,
    amountMinor: value['amount_minor'] as int?,
    currency: value['currency'] as String?,
    paymentMethod: value['payment_method'] as String?,
    transactionReference: value['transaction_reference'] as String?,
    remainingBalanceMinor: value['remaining_balance_minor'] as int?,
    issuedAt: value['issued_at'] == null
        ? null
        : DateTime.parse(value['issued_at'] as String),
    downloadPath: value['download_path'] as String?,
  );
}
