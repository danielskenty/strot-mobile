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
    required this.label,
    required this.amountMinor,
    required this.status,
    this.date,
    this.reference,
  });
  final String label, status;
  final int amountMinor;
  final DateTime? date;
  final String? reference;
}
