class InvoiceTransaction {
  const InvoiceTransaction({
    required this.provider,
    required this.amountMinor,
    required this.status,
    this.reference,
  });
  final String provider, status;
  final int amountMinor;
  final String? reference;
}

class StrotInvoice {
  const StrotInvoice({
    required this.id,
    required this.reference,
    required this.title,
    required this.totalMinor,
    required this.paidMinor,
    required this.outstandingMinor,
    required this.currency,
    required this.status,
    required this.projectReference,
    required this.projectId,
    required this.dueAt,
    required this.transactions,
  });
  final int id, projectId, totalMinor, paidMinor, outstandingMinor;
  final String reference, title, currency, status, projectReference;
  final DateTime? dueAt;
  final List<InvoiceTransaction> transactions;
}
