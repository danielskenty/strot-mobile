import '../network/api_client.dart';
import 'invoice_models.dart';

abstract interface class InvoiceService {
  Future<List<StrotInvoice>> list();
}

class MockInvoiceService implements InvoiceService {
  @override
  Future<List<StrotInvoice>> list() async => [
    StrotInvoice(
      id: 1,
      projectId: 1,
      reference: 'INV-260821-A1B2C3',
      title: 'Stage two · Scope approval',
      totalMinor: 1500000000,
      paidMinor: 500000000,
      outstandingMinor: 1000000000,
      currency: 'NGN',
      status: 'partially_paid',
      projectReference: 'STR-24001',
      dueAt: DateTime(2026, 8, 28),
      transactions: const [
        InvoiceTransaction(
          provider: 'Bank transfer',
          amountMinor: 500000000,
          status: 'succeeded',
          reference: 'BANK-260820-01',
        ),
      ],
    ),
  ];
}

class ApiInvoiceService implements InvoiceService {
  ApiInvoiceService(this.client);
  final ApiClient client;
  @override
  Future<List<StrotInvoice>> list() async {
    final result = await client.get('/invoices');
    return (result['data'] as List<dynamic>).map((raw) {
      final v = raw as Map<String, dynamic>;
      final project = v['project'] as Map<String, dynamic>;
      return StrotInvoice(
        id: v['id'] as int,
        projectId: project['id'] as int,
        reference: v['reference'] as String,
        title: v['title'] as String,
        totalMinor: v['total_minor'] as int,
        paidMinor: v['paid_minor'] as int,
        outstandingMinor: v['outstanding_minor'] as int,
        currency: v['currency'] as String,
        status: v['status'] as String,
        projectReference: project['reference'] as String,
        dueAt: v['due_at'] == null
            ? null
            : DateTime.parse(v['due_at'] as String),
        transactions: (v['transactions'] as List<dynamic>? ?? []).map((raw) {
          final t = raw as Map<String, dynamic>;
          return InvoiceTransaction(
            provider: t['provider'] as String,
            amountMinor: t['amount_minor'] as int,
            status: t['status'] as String,
            reference: t['provider_reference'] as String?,
          );
        }).toList(),
      );
    }).toList();
  }
}
